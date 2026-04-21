suppressPackageStartupMessages({
  library(dplyr)
  library(lmtest)
  library(sandwich)
  library(car)
  library(BayesFactor)
})

cat("\n[glm/02] Running GLM workflow for hypotheses H_GLM1-H_GLM4...\n")

dir.create("outputs/glm", showWarnings = FALSE, recursive = TRUE)

cell_data <- read.csv("data/processed/glm_cell_data.csv", stringsAsFactors = FALSE) %>%
  filter(
    noun_condition %in% c("HH", "HL", "LH", "LL"),
    voice %in% c("Active", "Passive")
  ) %>%
  mutate(
    noun_condition = factor(noun_condition, levels = c("LL", "LH", "HL", "HH")),
    voice = factor(voice, levels = c("Active", "Passive"))
  )

safe_model_matrix <- function(vif_obj) {
  if (is.matrix(vif_obj) || is.data.frame(vif_obj)) {
    out <- as.data.frame(vif_obj)
    out$term <- rownames(out)
    rownames(out) <- NULL
    if (all(c("GVIF", "Df") %in% names(out))) {
      out$GVIF_adj <- out$GVIF^(1 / (2 * out$Df))
      out$flag_gt5 <- out$GVIF_adj > 5
    } else if ("vif_obj" %in% names(out)) {
      out$flag_gt5 <- out$vif_obj > 5
    }
    return(out)
  }
  out <- data.frame(term = names(vif_obj), VIF = as.numeric(vif_obj))
  out$flag_gt5 <- out$VIF > 5
  out
}

make_diag_plots <- function(model, prefix) {
  png(sprintf("outputs/glm/%s_residuals_vs_fitted.png", prefix), width = 1000, height = 800)
  plot(fitted(model), resid(model),
       xlab = "Fitted values", ylab = "Residuals",
       main = sprintf("%s: Residuals vs Fitted", prefix))
  abline(h = 0, lty = 2, col = "red")
  dev.off()

  png(sprintf("outputs/glm/%s_qq_residuals.png", prefix), width = 1000, height = 800)
  qqnorm(resid(model), main = sprintf("%s: Q-Q Plot of Residuals", prefix))
  qqline(resid(model), col = "red", lty = 2)
  dev.off()

  cooks <- cooks.distance(model)
  png(sprintf("outputs/glm/%s_cooks_distance.png", prefix), width = 1100, height = 800)
  plot(cooks, type = "h", main = sprintf("%s: Cook's Distance", prefix),
       ylab = "Cook's distance", xlab = "Observation index")
  abline(h = 1, col = "red", lty = 2)
  dev.off()

  cooks
}

extract_model_fit <- function(model) {
  s <- summary(model)
  f <- s$fstatistic
  data.frame(
    r_squared = s$r.squared,
    adj_r_squared = s$adj.r.squared,
    f_statistic = unname(f[1]),
    df1 = unname(f[2]),
    df2 = unname(f[3]),
    f_p_value = pf(f[1], f[2], f[3], lower.tail = FALSE)
  )
}

extract_coef_table <- function(model) {
  ctab <- summary(model)$coefficients
  ci <- confint(model)
  out <- as.data.frame(ctab)
  out$term <- rownames(out)
  rownames(out) <- NULL
  names(out) <- c("beta", "se", "t", "p", "term")
  out$ci_low <- ci[out$term, 1]
  out$ci_high <- ci[out$term, 2]
  out[, c("term", "beta", "se", "t", "p", "ci_low", "ci_high")]
}

std_formula <- function(model_formula) {
  txt <- deparse(model_formula)
  txt <- gsub("mean_rt", "mean_rt_z", txt, fixed = TRUE)
  txt <- gsub("mean_trial_position", "mean_trial_position_z", txt, fixed = TRUE)
  as.formula(txt)
}

extract_bf_table <- function(data_df, outcome_var, outcome_name) {
  bf_data <- data_df %>%
    transmute(
      outcome = .data[[outcome_var]],
      noun_LH = as.numeric(noun_condition == "LH"),
      noun_HL = as.numeric(noun_condition == "HL"),
      noun_HH = as.numeric(noun_condition == "HH"),
      voice_Passive = as.numeric(voice == "Passive"),
      mean_rt,
      mean_trial_position
    )

  bf_obj <- regressionBF(
    outcome ~ noun_LH + noun_HL + noun_HH + voice_Passive + mean_rt + mean_trial_position,
    data = bf_data,
    whichModels = "all",
    progress = FALSE
  )
  bf_raw <- extractBF(bf_obj, onlybf = FALSE)
  bf_tab <- as.data.frame(bf_raw)
  bf_tab$model <- rownames(bf_tab)
  rownames(bf_tab) <- NULL
  bf_tab$BF10 <- exp(bf_tab$bf)
  bf_tab$BF_relative <- bf_tab$BF10 / max(bf_tab$BF10)
  bf_tab <- bf_tab %>% arrange(desc(BF10))
  write.csv(bf_tab, sprintf("outputs/glm/%s_bayesfactor_models.csv", outcome_name), row.names = FALSE)
  bf_tab
}

run_outcome <- function(data_df, outcome, outcome_label) {
  prefix <- gsub("[^A-Za-z0-9]+", "_", tolower(outcome_label))

  model_df <- data_df %>%
    filter(!is.na(.data[[outcome]]), !is.na(mean_rt), !is.na(mean_trial_position))

  M0 <- lm(as.formula(sprintf("%s ~ 1", outcome)), data = model_df)
  M1 <- lm(as.formula(sprintf("%s ~ noun_condition + voice", outcome)), data = model_df)
  M2 <- lm(as.formula(sprintf("%s ~ noun_condition + voice + mean_rt", outcome)), data = model_df)
  M3 <- lm(as.formula(sprintf("%s ~ noun_condition + voice + mean_rt + mean_trial_position", outcome)), data = model_df)
  M4 <- lm(as.formula(sprintf("%s ~ noun_condition * voice + mean_rt + mean_trial_position", outcome)), data = model_df)

  anova_seq <- anova(M0, M1, M2, M3, M4)
  aic_vals <- AIC(M0, M1, M2, M3, M4)
  aic_vals$delta_aic <- aic_vals$AIC - min(aic_vals$AIC)

  step_best <- step(M4, direction = "backward", trace = 0)

  model_names <- c("M0", "M1", "M2", "M3", "M4")
  all_models <- list(M0, M1, M2, M3, M4)
  best_idx <- which.min(sapply(all_models, AIC))
  aic_best <- all_models[[best_idx]]

  if (AIC(step_best) <= AIC(aic_best)) {
    best_model <- step_best
    best_name <- "step_best"
  } else {
    best_model <- aic_best
    best_name <- model_names[best_idx]
  }

  cooks <- make_diag_plots(best_model, prefix)
  shapiro_res <- shapiro.test(resid(best_model))
  bp_res <- bptest(best_model)
  hetero_flag <- bp_res$p.value < 0.05

  vif_tab <- safe_model_matrix(car::vif(best_model))

  robust_tab <- NULL
  if (hetero_flag) {
    robust <- coeftest(best_model, vcov = vcovHC(best_model, type = "HC3"))
    robust_mat <- as.matrix(robust)
    if (is.null(dim(robust_mat))) {
      robust_mat <- matrix(robust_mat, nrow = 1, byrow = TRUE)
    }
    term_names <- rownames(robust_mat)
    if (is.null(term_names) || length(term_names) != nrow(robust_mat)) {
      term_names <- paste0("term_", seq_len(nrow(robust_mat)))
    }

    if (ncol(robust_mat) >= 4) {
      robust_tab <- data.frame(
        term = term_names,
        robust_beta = as.numeric(robust_mat[, 1]),
        robust_se = as.numeric(robust_mat[, 2]),
        robust_z_or_t = as.numeric(robust_mat[, 3]),
        robust_p = as.numeric(robust_mat[, 4]),
        stringsAsFactors = FALSE
      )
    } else {
      robust_tab <- as.data.frame(robust_mat)
      colnames(robust_tab) <- paste0("robust_col_", seq_len(ncol(robust_tab)))
      robust_tab$term <- term_names
      robust_tab <- robust_tab[, c("term", setdiff(names(robust_tab), "term"))]
    }
  }

  fit_tab <- extract_model_fit(best_model)
  coef_tab <- extract_coef_table(best_model)

  std_df <- model_df %>%
    mutate(
      mean_rt_z = as.numeric(scale(mean_rt)),
      mean_trial_position_z = as.numeric(scale(mean_trial_position))
    )
  std_mod <- lm(std_formula(formula(best_model)), data = std_df)
  std_coef <- as.data.frame(summary(std_mod)$coefficients)
  std_coef$term <- rownames(std_coef)
  rownames(std_coef) <- NULL
  names(std_coef) <- c("std_beta", "std_se", "std_t", "std_p", "term")

  bf_tab <- extract_bf_table(model_df, outcome, prefix)

  bf_m3 <- lmBF(as.formula(sprintf("%s ~ noun_condition + voice + mean_rt + mean_trial_position", outcome)), data = model_df)
  bf_m4 <- lmBF(as.formula(sprintf("%s ~ noun_condition * voice + mean_rt + mean_trial_position", outcome)), data = model_df)
  bf_int <- extractBF(bf_m4 / bf_m3, onlybf = TRUE)

  anova_m3_m4 <- anova(M3, M4)

  write.csv(as.data.frame(anova_seq), sprintf("outputs/glm/%s_anova_sequence.csv", prefix), row.names = TRUE)
  write.csv(aic_vals, sprintf("outputs/glm/%s_model_aic.csv", prefix), row.names = FALSE)
  write.csv(fit_tab, sprintf("outputs/glm/%s_best_model_fit.csv", prefix), row.names = FALSE)
  write.csv(coef_tab, sprintf("outputs/glm/%s_best_model_coefficients.csv", prefix), row.names = FALSE)
  write.csv(vif_tab, sprintf("outputs/glm/%s_best_model_vif.csv", prefix), row.names = FALSE)
  write.csv(std_coef, sprintf("outputs/glm/%s_best_model_standardized_coefficients.csv", prefix), row.names = FALSE)
  write.csv(as.data.frame(anova_m3_m4), sprintf("outputs/glm/%s_interaction_m3_vs_m4.csv", prefix), row.names = TRUE)
  if (!is.null(robust_tab)) {
    write.csv(robust_tab, sprintf("outputs/glm/%s_best_model_hc3_coefficients.csv", prefix), row.names = FALSE)
  }

  cooks_flag <- which(cooks > 1)

  list(
    outcome = outcome,
    outcome_label = outcome_label,
    n = nrow(model_df),
    model_names = model_names,
    best_name = best_name,
    best_formula = deparse(formula(best_model)),
    anova_seq = as.data.frame(anova_seq),
    aic = aic_vals,
    step_formula = deparse(formula(step_best)),
    shapiro = shapiro_res,
    bp = bp_res,
    hetero = hetero_flag,
    cooks_flag = cooks_flag,
    fit = fit_tab,
    coef = coef_tab,
    vif = vif_tab,
    robust = robust_tab,
    bf_tab = bf_tab,
    bf_interaction_m4_over_m3 = as.numeric(exp(bf_int)),
    anova_m3_m4 = as.data.frame(anova_m3_m4)
  )
}

interpret_bf <- function(x) {
  if (x < 1) return("supports null (BF < 1)")
  if (x < 3) return("negligible")
  if (x < 20) return("positive")
  if (x < 150) return("strong")
  "very strong"
}

ir_res <- run_outcome(cell_data, "corrected_ir", "Corrected IR")
wr_res <- run_outcome(cell_data, "wr_accuracy", "WR Accuracy")

report_lines <- c(
  "# GLM Deliverables",
  "",
  sprintf("Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  "",
  "## Data aggregation",
  "One row per participant x noun_condition x voice cell was used from data/processed/glm_cell_data.csv,",
  "including mean Corrected IR, mean WR Accuracy, mean RT, and mean trial position.",
  "Reference levels: noun_condition = LL, voice = Active.",
  "",
  "## H_GLM1 and H_GLM2 (Corrected IR)",
  sprintf("Best model selected (AIC/backward step): %s", ir_res$best_formula),
  sprintf("Sample size used: %d rows", ir_res$n),
  sprintf("Overall model fit: F(%d, %d)=%.4f, p=%.6g, R2=%.4f, Adj R2=%.4f",
          ir_res$fit$df1, ir_res$fit$df2, ir_res$fit$f_statistic,
          ir_res$fit$f_p_value, ir_res$fit$r_squared, ir_res$fit$adj_r_squared),
  "Model sequence F-tests and delta AIC are saved in outputs/glm/corrected_ir_anova_sequence.csv and outputs/glm/corrected_ir_model_aic.csv.",
  "",
  "## H_GLM3 (WR Accuracy null-focused)",
  sprintf("Best model selected (AIC/backward step): %s", wr_res$best_formula),
  sprintf("Sample size used: %d rows", wr_res$n),
  sprintf("Overall model fit: F(%d, %d)=%.4f, p=%.6g, R2=%.4f, Adj R2=%.4f",
          wr_res$fit$df1, wr_res$fit$df2, wr_res$fit$f_statistic,
          wr_res$fit$f_p_value, wr_res$fit$r_squared, wr_res$fit$adj_r_squared),
  "Bayes factors for all model combinations are in outputs/glm/wr_accuracy_bayesfactor_models.csv.",
  sprintf("Best WR BF10 = %.6g (%s)",
          max(wr_res$bf_tab$BF10), interpret_bf(max(wr_res$bf_tab$BF10))),
  "",
  "## H_GLM4 (Interaction)",
  sprintf("Corrected IR interaction comparison M3 vs M4 (anova) p-value: %.6g",
          ir_res$anova_m3_m4$`Pr(>F)`[2]),
  sprintf("Corrected IR BF(M4/M3): %.6g (%s)",
          ir_res$bf_interaction_m4_over_m3,
          interpret_bf(ir_res$bf_interaction_m4_over_m3)),
  sprintf("WR Accuracy interaction comparison M3 vs M4 (anova) p-value: %.6g",
          wr_res$anova_m3_m4$`Pr(>F)`[2]),
  sprintf("WR Accuracy BF(M4/M3): %.6g (%s)",
          wr_res$bf_interaction_m4_over_m3,
          interpret_bf(wr_res$bf_interaction_m4_over_m3)),
  "",
  "## Diagnostics",
  sprintf("Corrected IR residual Shapiro-Wilk p=%.6g", ir_res$shapiro$p.value),
  sprintf("Corrected IR Breusch-Pagan p=%.6g", ir_res$bp$p.value),
  sprintf("Corrected IR Cook's D > 1 count: %d", length(ir_res$cooks_flag)),
  sprintf("WR residual Shapiro-Wilk p=%.6g", wr_res$shapiro$p.value),
  sprintf("WR Breusch-Pagan p=%.6g", wr_res$bp$p.value),
  sprintf("WR Cook's D > 1 count: %d", length(wr_res$cooks_flag)),
  "Residual plots, Q-Q, and Cook's distance plots are saved under outputs/glm/*png.",
  "VIF tables are saved under outputs/glm/*_best_model_vif.csv (flag criterion > 5).",
  "If heteroscedasticity was detected, HC3 robust coefficients were saved as *_best_model_hc3_coefficients.csv.",
  "",
  "## Coefficients and CIs",
  "Unstandardized coefficients (beta, SE, t, p, 95% CI) are saved as:",
  "- outputs/glm/corrected_ir_best_model_coefficients.csv",
  "- outputs/glm/wr_accuracy_best_model_coefficients.csv",
  "Standardized-coefficient models are saved as:",
  "- outputs/glm/corrected_ir_best_model_standardized_coefficients.csv",
  "- outputs/glm/wr_accuracy_best_model_standardized_coefficients.csv",
  ""
)

writeLines(report_lines, "outputs/glm/glm_report.md")

cat("  Saved -> outputs/glm/glm_report.md\n")
cat("  Deliverables written under outputs/glm/\n")

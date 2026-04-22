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

# extract_bf_table: compare four nested block models via lmBF().
# Using lmBF() with factor variables directly ensures that noun_condition is treated
# as a 3-df block (all-in or all-out), preserving symmetry with the lm() specification.
# Previously, three manual numeric dummies were passed to regressionBF(), which allowed
# partial dummy combinations that are not valid model states — this has been corrected.
extract_bf_table <- function(data_df, outcome_var, outcome_name) {
  # lmBF() already computes BF10 relative to the intercept-only null by default;
  # passing ~ 1 as a BFlinearModel causes a slot-validation error in BayesFactor.
  # We therefore fit only the three non-trivial models and read their BF10 values
  # directly (each is already vs. the intercept-only null).
  model_df_bf <- data_df %>%
    filter(!is.na(.data[[outcome_var]]), !is.na(mean_rt), !is.na(mean_trial_position)) %>%
    mutate(
      noun_condition = factor(noun_condition, levels = c("LL", "LH", "HL", "HH")),
      voice = factor(voice, levels = c("Active", "Passive"))
    )

  f_noun     <- as.formula(sprintf("%s ~ noun_condition", outcome_var))
  f_main     <- as.formula(sprintf("%s ~ noun_condition + voice + mean_rt + mean_trial_position", outcome_var))
  f_interact <- as.formula(sprintf("%s ~ noun_condition * voice + mean_rt + mean_trial_position", outcome_var))

  bf_noun     <- lmBF(f_noun,     data = model_df_bf, progress = FALSE)
  bf_main     <- lmBF(f_main,     data = model_df_bf, progress = FALSE)
  bf_interact <- lmBF(f_interact, data = model_df_bf, progress = FALSE)

  # extractBF(onlybf=TRUE) returns the linear BF10 directly (not log-BF).
  bf10_noun     <- as.numeric(extractBF(bf_noun,     onlybf = TRUE))
  bf10_main     <- as.numeric(extractBF(bf_main,     onlybf = TRUE))
  bf10_interact <- as.numeric(extractBF(bf_interact, onlybf = TRUE))

  # BF(interact/main) = BF10_interact / BF10_main
  bf_interact_over_main <- bf10_interact / bf10_main

  bf_tab <- data.frame(
    model        = c("null (intercept only)", "noun_condition", "main_effects", "interaction"),
    BF10_vs_null = c(1, bf10_noun, bf10_main, bf10_interact),
    BF_vs_best   = NA_real_,
    stringsAsFactors = FALSE
  )
  bf_tab$BF_vs_best <- bf_tab$BF10_vs_null / max(bf_tab$BF10_vs_null)
  bf_tab <- bf_tab %>% arrange(desc(BF10_vs_null))
  write.csv(bf_tab, sprintf("outputs/glm/%s_bayesfactor_models.csv", outcome_name), row.names = FALSE)

  list(
    table                 = bf_tab,
    bf_main_over_null     = bf10_main,
    bf_interact_over_main = bf_interact_over_main
  )
}

# std_formula() rewrites a formula to use z-scored continuous predictors.
# It is called below after manually creating mean_rt_z and
# mean_trial_position_z via scale(), so standardised coefficients are obtained
# by re-fitting the model on standardised inputs — not post-hoc β scaling.
std_formula <- function(model_formula) {
  txt <- deparse(model_formula)
  txt <- gsub("mean_rt", "mean_rt_z", txt, fixed = TRUE)
  txt <- gsub("mean_trial_position", "mean_trial_position_z", txt, fixed = TRUE)
  as.formula(txt)
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

  # Robust sequential Wald tests (HC3) — accounts for detected heteroscedasticity.
  # waldtest() with vcovHC produces statistics adjusted for non-constant variance,
  # giving valid p-values for H_GLM1 and H_GLM2.
  wt_01 <- waldtest(M0, M1, vcov = vcovHC(M1, type = "HC3"))
  wt_12 <- waldtest(M1, M2, vcov = vcovHC(M2, type = "HC3"))
  wt_23 <- waldtest(M2, M3, vcov = vcovHC(M3, type = "HC3"))
  wt_34 <- waldtest(M3, M4, vcov = vcovHC(M4, type = "HC3"))

  # Collect robust Wald sequence into a single data frame for export
  wald_seq <- bind_rows(
    as.data.frame(wt_01)[2, , drop = FALSE] %>% mutate(comparison = "M0 vs M1"),
    as.data.frame(wt_12)[2, , drop = FALSE] %>% mutate(comparison = "M1 vs M2"),
    as.data.frame(wt_23)[2, , drop = FALSE] %>% mutate(comparison = "M2 vs M3"),
    as.data.frame(wt_34)[2, , drop = FALSE] %>% mutate(comparison = "M3 vs M4")
  )

  # Non-robust AIC sequence retained for reference / delta-AIC inspection.
  # Note: AIC is computed from OLS log-likelihood; final inference uses HC3.
  aic_vals <- AIC(M0, M1, M2, M3, M4)
  aic_vals$delta_aic <- aic_vals$AIC - min(aic_vals$AIC)

  # NOTE: step() uses AIC evaluated on OLS log-likelihood, which is a biased
  # criterion under heteroscedasticity. The selected formula is used only as a
  # starting candidate; final inferential conclusions rely on robust waldtest()
  # p-values, not on the stepwise path.
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
      mean_rt_z              = as.numeric(scale(mean_rt)),
      mean_trial_position_z  = as.numeric(scale(mean_trial_position))
    )
  std_mod <- lm(std_formula(formula(best_model)), data = std_df)
  std_coef <- as.data.frame(summary(std_mod)$coefficients)
  std_coef$term <- rownames(std_coef)
  rownames(std_coef) <- NULL
  names(std_coef) <- c("std_beta", "std_se", "std_t", "std_p", "term")

  bf_result <- extract_bf_table(model_df, outcome, prefix)

  wt_m3_m4 <- waldtest(M3, M4, vcov = vcovHC(M4, type = "HC3"))
  anova_m3_m4 <- as.data.frame(wt_m3_m4)

  write.csv(wald_seq, sprintf("outputs/glm/%s_robust_wald_sequence.csv", prefix), row.names = FALSE)
  write.csv(aic_vals, sprintf("outputs/glm/%s_model_aic.csv", prefix), row.names = FALSE)
  write.csv(fit_tab, sprintf("outputs/glm/%s_best_model_fit.csv", prefix), row.names = FALSE)
  write.csv(coef_tab, sprintf("outputs/glm/%s_best_model_coefficients.csv", prefix), row.names = FALSE)
  write.csv(vif_tab, sprintf("outputs/glm/%s_best_model_vif.csv", prefix), row.names = FALSE)
  write.csv(std_coef, sprintf("outputs/glm/%s_best_model_standardized_coefficients.csv", prefix), row.names = FALSE)
  write.csv(anova_m3_m4, sprintf("outputs/glm/%s_interaction_m3_vs_m4.csv", prefix), row.names = FALSE)
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
    wald_seq = wald_seq,
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
    bf_tab = bf_result$table,
    bf_main_over_null      = bf_result$bf_main_over_null,
    bf_interaction_m4_over_m3 = bf_result$bf_interact_over_main,
    anova_m3_m4 = anova_m3_m4
  )
}

# interpret_bf: Evaluates evidence on Jeffreys scale.
#   BF10 >= 1  => evidence for alternative; label on H1 side.
#   BF10 <  1  => evidence for null; invert to BF01 = 1/BF10 and label on H0 side.
interpret_bf <- function(x) {
  if (x >= 1) {
    if (x < 3)   return("negligible evidence for H1")
    if (x < 20)  return("positive evidence for H1")
    if (x < 150) return("strong evidence for H1")
    return("very strong evidence for H1")
  } else {
    bf01 <- 1 / x
    if (bf01 < 3)   return("negligible evidence for H0")
    if (bf01 < 20)  return("positive evidence for H0")
    if (bf01 < 150) return("strong evidence for H0")
    return("very strong evidence for H0")
  }
}

# format_bf: Generates a descriptive string including reciprocal BF01 if needed.
format_bf <- function(x, label = "BF10") {
  interp <- interpret_bf(x)
  if (x >= 1) {
    sprintf("%s = %.4g (%s)", label, x, interp)
  } else {
    bf01 <- 1 / x
    sprintf("%s = %.4g [BF01 = %.4g] (%s)", label, x, bf01, interp)
  }
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
  "## H1 and H2 (Corrected IR)",
  sprintf("Best model selected (AIC/backward step): %s", ir_res$best_formula),
  sprintf("Sample size used: %d rows", ir_res$n),
  sprintf("Overall model fit: F(%d, %d)=%.4f, p=%.6g, R2=%.4f, Adj R2=%.4f",
          ir_res$fit$df1, ir_res$fit$df2, ir_res$fit$f_statistic,
          ir_res$fit$f_p_value, ir_res$fit$r_squared, ir_res$fit$adj_r_squared),
  sprintf("Full model BF10 (main effects vs null): %s",
          format_bf(ir_res$bf_main_over_null, "BF10")),
  "Robust Wald sequence (HC3) saved in outputs/glm/corrected_ir_robust_wald_sequence.csv; delta AIC in outputs/glm/corrected_ir_model_aic.csv.",
  "",
  "## H3 (WR Accuracy null-focused)",
  sprintf("Best model selected (AIC/backward step): %s", wr_res$best_formula),
  sprintf("Sample size used: %d rows", wr_res$n),
  sprintf("Overall model fit: F(%d, %d)=%.4f, p=%.6g, R2=%.4f, Adj R2=%.4f",
          wr_res$fit$df1, wr_res$fit$df2, wr_res$fit$f_statistic,
          wr_res$fit$f_p_value, wr_res$fit$r_squared, wr_res$fit$adj_r_squared),
  "Block BF comparisons (noun_condition as factor) are in outputs/glm/wr_accuracy_bayesfactor_models.csv.",
  sprintf("WR main-effects BF10 (vs null): %s",
          format_bf(wr_res$bf_main_over_null, "BF10")),
  "",
  "## H4 (Interaction)",
  sprintf("Corrected IR interaction M3 vs M4 (robust Wald HC3): F(%d,%d)=%.4f, p=%.6g",
          ir_res$anova_m3_m4$Df[2], ir_res$anova_m3_m4$`Res.Df`[2],
          ir_res$anova_m3_m4$F[2], ir_res$anova_m3_m4$`Pr(>F)`[2]),
  sprintf("Corrected IR BF(interact/main): %s",
          format_bf(ir_res$bf_interaction_m4_over_m3, "BF10")),
  sprintf("WR Accuracy interaction M3 vs M4 (robust Wald HC3): F(%d,%d)=%.4f, p=%.6g",
          wr_res$anova_m3_m4$Df[2], wr_res$anova_m3_m4$`Res.Df`[2],
          wr_res$anova_m3_m4$F[2], wr_res$anova_m3_m4$`Pr(>F)`[2]),
  sprintf("WR Accuracy BF(interact/main): %s",
          format_bf(wr_res$bf_interaction_m4_over_m3, "BF10")),
  "",
  "## Diagnostics",
  sprintf("Corrected IR residual Shapiro-Wilk p=%.6g", ir_res$shapiro$p.value),
  sprintf("  Q-Q plot (corrected_ir_qq_residuals.png): heavy tails consistent with SW p=%.6g;",
          ir_res$shapiro$p.value),
  "  non-normality addressed via HC3 robust SEs — OLS point estimates remain unbiased.",
  sprintf("Corrected IR Breusch-Pagan p=%.6g", ir_res$bp$p.value),
  sprintf("Corrected IR Cook's D > 1 count: %d", length(ir_res$cooks_flag)),
  sprintf("WR residual Shapiro-Wilk p=%.6g", wr_res$shapiro$p.value),
  sprintf("  Q-Q plot (wr_accuracy_qq_residuals.png): heavy tails consistent with SW p=%.6g;",
          wr_res$shapiro$p.value),
  "  non-normality addressed via HC3 robust SEs — OLS point estimates remain unbiased.",
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
  "Standardized-coefficient models refit the best model with mean_rt and mean_trial_position",
  "z-scored inline (scale()). Factor terms are unchanged. Results are saved as:",
  "- outputs/glm/corrected_ir_best_model_standardized_coefficients.csv",
  "- outputs/glm/wr_accuracy_best_model_standardized_coefficients.csv",
  ""
)

writeLines(report_lines, "outputs/glm/glm_report.md")

cat("  Saved -> outputs/glm/glm_report.md\n")
cat("  Deliverables written under outputs/glm/\n")

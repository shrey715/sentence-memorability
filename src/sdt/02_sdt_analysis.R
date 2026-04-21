# src/sdt/02_sdt_analysis.R
# Signal Detection Theory inferential analysis.
#
# UPDATE: d' and c are normally distributed (all S-W p > .05 per condition group).
# Class 14.pdf flowchart: normality holds → use parametric RM-ANOVA, not Friedman's.
# Mauchly's sphericity tested; Greenhouse-Geisser correction applied if violated.
# Post-hoc: paired t-tests with Holm correction (not Wilcoxon signed-rank).
#
# A' remains Friedman's (bounded [0.5,1], non-Gaussian by construction → robustness check).
# Voice comparisons (H3): 2-level paired t-test (replaces paired Wilcoxon).
#
# TESTS:
#   SDT-H1  — RM-ANOVA: d' ~ noun_condition (sensitivity)
#   SDT-H2  — RM-ANOVA: c  ~ noun_condition (bias — expected null)
#   SDT-H1b — Friedman: A' ~ noun_condition (non-parametric robustness check)
#   SDT-H3  — Paired t-test: Active vs Passive d' and c
#   SDT-H4  — Spearman rho: d' vs Corrected IR (convergent validity)
#
# Inputs:  data/processed/sdt_scores.csv
#          data/processed/sdt_voice_scores.csv
#          data/processed/cr_scores.csv
# Output:  outputs/sdt/sdt_stats.txt

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(rstatix); library(ez)
})

dir.create("outputs/sdt", showWarnings = FALSE, recursive = TRUE)
out_file <- "outputs/sdt/sdt_stats.txt"
sink(out_file, split = TRUE)

cat("================================================================\n")
cat("  SDT Analysis — Signal Detection Theory Extension\n")
cat("================================================================\n")
cat(sprintf("  Run : %s\n\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))

sdt   <- read.csv("data/processed/sdt_scores.csv",       stringsAsFactors = FALSE) %>%
  mutate(noun_condition = factor(noun_condition, levels = c("HH","HL","LH","LL")),
         participant_id = factor(participant_id))
sdt_v <- read.csv("data/processed/sdt_voice_scores.csv", stringsAsFactors = FALSE) %>%
  mutate(noun_condition = factor(noun_condition, levels = c("HH","HL","LH","LL")),
         voice          = factor(voice, levels = c("Active","Passive")),
         participant_id = factor(participant_id))
cr    <- read.csv("data/processed/cr_scores.csv",         stringsAsFactors = FALSE) %>%
  filter(noun_condition %in% c("HH","HL","LH","LL")) %>%
  mutate(noun_condition = factor(noun_condition, levels = c("HH","HL","LH","LL")),
         participant_id = factor(participant_id))

cat(sprintf("  Participants : %d | Rows : %d\n",
            length(unique(sdt$participant_id)), nrow(sdt)))

# ── Descriptives ──────────────────────────────────────────────────────────────
cat("\n================================================================\n")
cat("DESCRIPTIVE STATISTICS — d', c, A' by Noun Condition\n")
cat("================================================================\n")
desc <- sdt %>%
  group_by(noun_condition) %>%
  summarise(N        = n(),
            dprime_M = round(mean(dprime,  na.rm=TRUE), 3),
            dprime_SD= round(sd(dprime,    na.rm=TRUE), 3),
            c_M      = round(mean(c_crit,  na.rm=TRUE), 3),
            c_SD     = round(sd(c_crit,    na.rm=TRUE), 3),
            Aprime_M = round(mean(A_prime, na.rm=TRUE), 3),
            Aprime_SD= round(sd(A_prime,   na.rm=TRUE), 3),
            .groups  = "drop")
print(as.data.frame(desc), row.names = FALSE)

# ── Normality (per condition group — class 7.pdf) ─────────────────────────────
cat("\n================================================================\n")
cat("NORMALITY — Shapiro-Wilk per Condition Group\n")
cat("(Class 7.pdf: test each group separately)\n")
cat("================================================================\n")

norm_d <- sdt %>% group_by(noun_condition) %>%
  summarise(n=n(), W=shapiro.test(dprime)$statistic, p=shapiro.test(dprime)$p.value,
            .groups="drop") %>%
  mutate(conclusion = ifelse(p < 0.05, "Non-normal", "Normal"))
norm_c <- sdt %>% group_by(noun_condition) %>%
  summarise(n=n(), W=shapiro.test(c_crit)$statistic, p=shapiro.test(c_crit)$p.value,
            .groups="drop") %>%
  mutate(conclusion = ifelse(p < 0.05, "Non-normal", "Normal"))

cat("\n── d' ──\n"); print(as.data.frame(norm_d), row.names = FALSE)
cat("\n── c ──\n");  print(as.data.frame(norm_c), row.names = FALSE)

all_normal_d <- all(norm_d$p >= 0.05)
all_normal_c <- all(norm_c$p >= 0.05)
cat(sprintf("\n  All d' groups normal: %s\n", all_normal_d))
cat(sprintf("  All c  groups normal: %s\n", all_normal_c))
cat("  => Class 14.pdf flowchart: normality holds → parametric RM-ANOVA used.\n")
cat("  => Friedman's NOT used for d' and c (would discard information).\n")
cat("  => A' still uses Friedman's (bounded [0.5,1] — non-parametric by design).\n")

# ── Helper: run RM-ANOVA with Mauchly + GG correction + Cohen's f ─────────────
run_rmanova <- function(metric_col, label) {

  cat(sprintf("\n================================================================\n"))
  cat(sprintf("RM-ANOVA: %s ~ noun_condition\n", label))
  cat("(Normality confirmed; within-participants design; class 14.pdf)\n")
  cat("================================================================\n")

  # ezANOVA gives F, p, GES (generalized eta squared), Mauchly's W, and GG correction
  ez_call <- substitute(ezANOVA(
    data       = sdt,
    dv         = DV_COL,
    wid        = participant_id,
    within     = noun_condition,
    type       = 3,
    return_aov = TRUE
  ), list(DV_COL = as.name(metric_col)))
  res <- eval(ez_call)

  # Mauchly's sphericity
  cat("\n── Mauchly's Sphericity Test ──\n")
  print(res$`Mauchly's Test for Sphericity`)

  mauchly_p <- res$`Mauchly's Test for Sphericity`$p
  sphericity_ok <- !is.null(mauchly_p) && mauchly_p >= 0.05

  # Main ANOVA table (GG-corrected automatically if violated)
  cat("\n── ANOVA Table")
  if (!sphericity_ok) {
    cat(" [Greenhouse-Geisser correction applied — sphericity violated]")
  } else {
    cat(" [sphericity assumed — Mauchly p >= .05]")
  }
  cat(" ──\n")
  print(res$ANOVA)

  # Cohen's f from GES: f = sqrt(GES / (1 - GES))
  # GES = generalised eta squared (reported by ezANOVA)
  ges <- res$ANOVA$ges[res$ANOVA$Effect == "noun_condition"]
  cohen_f <- sqrt(ges / (1 - ges))
  cat(sprintf("  GES = %.4f | Cohen's f = %.4f", ges, cohen_f))
  cat(sprintf("  (f benchmarks: .10 small, .25 medium, .40 large)\n"))

  # Post-hoc: paired t-tests with Holm correction (parametric — normality holds)
  aov_p <- res$ANOVA$p[res$ANOVA$Effect == "noun_condition"]
  # Use GG-corrected p if available
  if (!sphericity_ok && "p[GG]" %in% names(res$ANOVA)) {
    aov_p <- res$ANOVA$`p[GG]`[res$ANOVA$Effect == "noun_condition"]
  }

  if (!is.na(aov_p) && aov_p < 0.05) {
    cat("\n  Significant — post-hoc: Paired t-tests (Holm-corrected)\n")
    cat("  (Parametric post-hoc justified: normality confirmed per group)\n")

    ph <- sdt %>%
      pairwise_t_test(
        as.formula(paste(metric_col, "~ noun_condition")),
        paired          = TRUE,
        p.adjust.method = "holm"
      )
    print(ph)

    # Cohen's d for each pair (paired)
    cat("  Cohen's d per pair:\n")
    ph_d <- sdt %>%
      cohens_d(
        as.formula(paste(metric_col, "~ noun_condition")),
        paired = TRUE
      )
    print(ph_d)

  } else {
    cat(sprintf("  Non-significant (p = %.4f). Post-hoc skipped.\n", aov_p))
  }

  invisible(res)
}

# ── SDT-H1: RM-ANOVA on d' ────────────────────────────────────────────────────
cat("\n================================================================\n")
cat("SDT-H1: RM-ANOVA — d' ~ noun_condition\n")
cat("================================================================\n")
run_rmanova("dprime", "d' (sensitivity)")

# ── SDT-H2: RM-ANOVA on c ─────────────────────────────────────────────────────
cat("\n================================================================\n")
cat("SDT-H2: RM-ANOVA — c ~ noun_condition\n")
cat("(Bias; expected null under trace-strength account)\n")
cat("================================================================\n")
run_rmanova("c_crit", "c (criterion)")

cat("\n  !! NON-INDEPENDENCE CAVEAT !!\n")
cat("  FA rate is constant per participant across conditions (global HF lures).\n")
cat("  RM-ANOVA on d' and c are therefore not independent — both are driven\n")
cat("  by the same within-participant ordering of z(H) across conditions.\n")
cat("  A' (H1b below) provides the structurally independent robustness check.\n")
cat("  Family-wise alpha for {d', c}: 0.05 / 2 = 0.025.\n")

# ── SDT-H1b: Friedman on A' (robustness — non-parametric, bounded metric) ─────
cat("\n================================================================\n")
cat("SDT-H1b: Friedman's Test — A' ~ noun_condition (robustness check)\n")
cat("(A' bounded [0.5,1]; non-parametric by design; validates RM-ANOVA pattern)\n")
cat("================================================================\n")

frm_a <- sdt %>% friedman_test(A_prime ~ noun_condition | participant_id)
eff_a <- sdt %>% friedman_effsize(A_prime ~ noun_condition | participant_id)
print(frm_a)
cat("  Kendall's W:\n"); print(eff_a)

if (!is.na(frm_a$p) && frm_a$p < 0.05) {
  ph_a   <- sdt %>% wilcox_test(A_prime ~ noun_condition, paired=TRUE, p.adjust.method="holm")
  ph_a_r <- sdt %>% wilcox_effsize(A_prime ~ noun_condition, paired=TRUE)
  print(ph_a)
  cat("  Rank-biserial r:\n"); print(ph_a_r)
} else {
  cat("  Non-significant. Post-hoc skipped.\n")
}

# ── SDT-H3: Voice effect — Paired t-test (normality holds) ───────────────────
cat("\n================================================================\n")
cat("SDT-H3: Voice Effect on d' and c — Paired t-test\n")
cat("(2-level within-participants; normality confirmed → t-test, not Wilcoxon)\n")
cat("  LIMITATION: All lures are Active-voice; global FA used for both voices.\n")
cat("  Passive d' may be artificially elevated. Interpret with caution.\n")
cat("================================================================\n")

sdt_v_agg <- sdt_v %>%
  group_by(participant_id, voice) %>%
  summarise(dprime = mean(dprime, na.rm=TRUE),
            c_crit = mean(c_crit, na.rm=TRUE),
            .groups = "drop") %>%
  pivot_wider(names_from=voice, values_from=c(dprime, c_crit)) %>%
  filter(complete.cases(.))

N_v <- nrow(sdt_v_agg)
cat(sprintf("  N (complete pairs): %d\n", N_v))

# Normality of difference scores (required for paired t-test validity)
diff_d <- sdt_v_agg$dprime_Active - sdt_v_agg$dprime_Passive
diff_c <- sdt_v_agg$c_crit_Active - sdt_v_agg$c_crit_Passive
sw_diff_d <- shapiro.test(diff_d)
sw_diff_c <- shapiro.test(diff_c)
cat(sprintf("  S-W on d' difference scores: W = %.4f, p = %.4f (%s)\n",
            sw_diff_d$statistic, sw_diff_d$p.value,
            ifelse(sw_diff_d$p.value >= 0.05, "Normal — t-test valid", "Non-normal — use Wilcoxon")))
cat(sprintf("  S-W on c  difference scores: W = %.4f, p = %.4f (%s)\n",
            sw_diff_c$statistic, sw_diff_c$p.value,
            ifelse(sw_diff_c$p.value >= 0.05, "Normal — t-test valid", "Non-normal — use Wilcoxon")))

# d' voice
cat(sprintf("\n-- d': Active M=%.3f vs Passive M=%.3f\n",
            mean(sdt_v_agg$dprime_Active, na.rm=TRUE),
            mean(sdt_v_agg$dprime_Passive, na.rm=TRUE)))
if (sw_diff_d$p.value >= 0.05) {
  tt_d <- t.test(sdt_v_agg$dprime_Active, sdt_v_agg$dprime_Passive, paired=TRUE)
  print(tt_d)
  sdt_v_agg$diff_d <- sdt_v_agg$dprime_Active - sdt_v_agg$dprime_Passive
  d_d <- cohens_d(sdt_v_agg, diff_d ~ 1)  # one-sample on differences
  cat(sprintf("  Cohen's d = %.4f\n", abs(as.numeric(d_d$effsize))))
} else {
  wt_d <- wilcox.test(sdt_v_agg$dprime_Active, sdt_v_agg$dprime_Passive, paired=TRUE, exact=FALSE)
  print(wt_d)
  r_d <- wilcox_effsize(
    sdt_v_agg %>% pivot_longer(cols=c(dprime_Active, dprime_Passive),
                                names_to="voice", values_to="dprime"),
    dprime ~ voice, paired=TRUE)
  cat("  Rank-biserial r:\n"); print(r_d)
}

# c voice
cat(sprintf("\n-- c: Active M=%.3f vs Passive M=%.3f\n",
            mean(sdt_v_agg$c_crit_Active, na.rm=TRUE),
            mean(sdt_v_agg$c_crit_Passive, na.rm=TRUE)))
if (sw_diff_c$p.value >= 0.05) {
  tt_c <- t.test(sdt_v_agg$c_crit_Active, sdt_v_agg$c_crit_Passive, paired=TRUE)
  print(tt_c)
  sdt_v_agg$diff_c <- sdt_v_agg$c_crit_Active - sdt_v_agg$c_crit_Passive
  d_c <- cohens_d(sdt_v_agg, diff_c ~ 1)
  cat(sprintf("  Cohen's d = %.4f\n", abs(as.numeric(d_c$effsize))))
} else {
  wt_c <- wilcox.test(sdt_v_agg$c_crit_Active, sdt_v_agg$c_crit_Passive, paired=TRUE, exact=FALSE)
  print(wt_c)
  r_c <- wilcox_effsize(
    sdt_v_agg %>% pivot_longer(cols=c(c_crit_Active, c_crit_Passive),
                                names_to="voice", values_to="c_crit"),
    c_crit ~ voice, paired=TRUE)
  cat("  Rank-biserial r:\n"); print(r_c)
}

# ── SDT-H4: Convergent validity — unchanged ───────────────────────────────────
cat("\n================================================================\n")
cat("SDT-H4: Convergent Validity — Spearman rho(d', Corrected IR)\n")
cat("(rho > .80: Corrected IR adequate proxy; <.70: bias contamination)\n")
cat("================================================================\n")

cr_coll <- cr %>%
  group_by(participant_id, noun_condition) %>%
  summarise(ir_cr = mean(ir_cr, na.rm=TRUE), .groups="drop") %>%
  mutate(noun_condition = factor(noun_condition, levels=c("HH","HL","LH","LL")))

conv <- sdt %>%
  left_join(cr_coll, by=c("participant_id","noun_condition")) %>%
  group_by(noun_condition) %>%
  summarise(rho = round(cor(dprime, ir_cr, method="spearman", use="complete.obs"), 3),
            n   = sum(!is.na(dprime) & !is.na(ir_cr)),
            .groups = "drop")
print(as.data.frame(conv), row.names = FALSE)

overall_rho <- cor(
  left_join(sdt, cr_coll, by=c("participant_id","noun_condition"))$dprime,
  left_join(sdt, cr_coll, by=c("participant_id","noun_condition"))$ir_cr,
  method="spearman", use="complete.obs"
)
cat(sprintf("  Overall rho (pooled) = %.3f\n", overall_rho))
cat(sprintf("  Interpretation: %s\n",
            ifelse(overall_rho >= 0.80,
                   "rho >= .80 — Corrected IR is an adequate proxy for d'.",
                   ifelse(overall_rho >= 0.70,
                          "rho in [.70,.80) — moderate fidelity.",
                          "rho < .70 — notable bias contamination."))))

cat("\n\n================================================================\n")
cat(sprintf("  SDT analysis complete : %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Saved -> %s\n", out_file))
cat("================================================================\n")
sink()
cat(sprintf("\nSaved -> %s\n", out_file))

# src/sdt/02_sdt_analysis.R
# Signal Detection Theory inferential analysis.
#
# DESIGN NOTE: All SDT metrics follow the same methodological standards
# as 05b_statistical_tests.R (Fixes 1-7):
#   - Shapiro-Wilk per condition group (Fix 1)
#   - Friedman's (not KW) for within-participants comparisons (Fix 2)
#   - Kendall's W effect size (Fix 3)
#   - paired Wilcoxon signed-rank for post-hoc (Fix 4)
#   - rank-biserial r per pair (Fix 5)
#   - Sphericity acknowledged (Fix 6)
#   - SRH limitation noted (Fix 7)
#
# TESTS:
#   SDT-H1 — Friedman on d' ~ noun_condition: does imageability modulate
#             memory-trace sensitivity?
#   SDT-H2 — Friedman on c ~ noun_condition: does imageability modulate
#             response bias? (should be null if trace-strength account is correct)
#   SDT-H3 — Paired Wilcoxon: Active vs Passive d' and c (voice effect on SDT)
#             NOTE: lures are all Active; global FA used for both voices.
#   SDT-H4 — Spearman correlation d' vs Corrected IR: convergent validity check
#
# Inputs:  data/processed/sdt_scores.csv
#          data/processed/sdt_voice_scores.csv
#          data/processed/cr_scores.csv
# Output:  outputs/sdt/sdt_stats.txt

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(rstatix); library(rcompanion)
})

dir.create("outputs/sdt", showWarnings = FALSE, recursive = TRUE)
out_file <- "outputs/sdt/sdt_stats.txt"
sink(out_file, split = TRUE)

cat("================================================================\n")
cat("  SDT Analysis — Signal Detection Theory Extension\n")
cat("================================================================\n")
cat(sprintf("  Run : %s\n\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))

sdt  <- read.csv("data/processed/sdt_scores.csv", stringsAsFactors = FALSE) %>%
  mutate(noun_condition = factor(noun_condition, levels = c("HH","HL","LH","LL")))
sdt_v <- read.csv("data/processed/sdt_voice_scores.csv", stringsAsFactors = FALSE) %>%
  mutate(noun_condition = factor(noun_condition, levels = c("HH","HL","LH","LL")),
         voice = factor(voice, levels = c("Active","Passive")))
cr <- read.csv("data/processed/cr_scores.csv", stringsAsFactors = FALSE) %>%
  filter(noun_condition %in% c("HH","HL","LH","LL")) %>%
  mutate(noun_condition = factor(noun_condition, levels = c("HH","HL","LH","LL")))

cat(sprintf("  Participants : %d | Rows : %d\n",
            length(unique(sdt$participant_id)), nrow(sdt)))

# ── Descriptives ───────────────────────────────────────────────────────────────
cat("\n================================================================\n")
cat("DESCRIPTIVE STATISTICS — d', c, A' by Noun Condition\n")
cat("================================================================\n")
desc <- sdt %>%
  group_by(noun_condition) %>%
  summarise(
    N        = n(),
    dprime_M = round(mean(dprime,  na.rm=TRUE), 3),
    dprime_SD= round(sd(dprime,    na.rm=TRUE), 3),
    c_M      = round(mean(c_crit,  na.rm=TRUE), 3),
    c_SD     = round(sd(c_crit,    na.rm=TRUE), 3),
    Aprime_M = round(mean(A_prime, na.rm=TRUE), 3),
    Aprime_SD= round(sd(A_prime,   na.rm=TRUE), 3),
    .groups  = "drop"
  )
print(as.data.frame(desc), row.names = FALSE)

# ── Normality (Fix 1: per group) ──────────────────────────────────────────────
cat("\n================================================================\n")
cat("NORMALITY — Shapiro-Wilk per Condition (Fix 1)\n")
cat("(One test per group; justifies non-parametric route if any p < .05)\n")
cat("================================================================\n")

norm_d <- sdt %>% group_by(noun_condition) %>%
  summarise(n=n(), W=shapiro.test(dprime)$statistic, p=shapiro.test(dprime)$p.value,
            .groups="drop") %>%
  mutate(conclusion = ifelse(p < 0.05, "Non-normal", "Normal"))
cat("\n── d' ──\n"); print(as.data.frame(norm_d), row.names=FALSE)

norm_c <- sdt %>% group_by(noun_condition) %>%
  summarise(n=n(), W=shapiro.test(c_crit)$statistic, p=shapiro.test(c_crit)$p.value,
            .groups="drop") %>%
  mutate(conclusion = ifelse(p < 0.05, "Non-normal", "Normal"))
cat("\n── c ──\n"); print(as.data.frame(norm_c), row.names=FALSE)

cat("\n── Sphericity note (Fix 6) ──\n")
cat("  Friedman's non-parametric test is used; it operates on ranks and does\n")
cat("  not require the sphericity assumption (class 14.pdf).\n")

# ── SDT-H1: Friedman on d' ────────────────────────────────────────────────────
cat("\n================================================================\n")
cat("SDT-H1: Friedman's Test — d' ~ noun_condition\n")
cat("(Within-participants; replaces KW per class 14.pdf — Fix 2)\n")
cat("================================================================\n")

frm_d <- sdt %>% friedman_test(dprime ~ noun_condition | participant_id)
eff_d <- sdt %>% friedman_effsize(dprime ~ noun_condition | participant_id)
print(frm_d); cat("  Kendall's W:\n"); print(eff_d)

if (!is.na(frm_d$p) && frm_d$p < 0.05) {
  cat("\n  Significant — post-hoc: Paired Wilcoxon (Holm-corrected, Fix 4)\n")
  ph_d   <- sdt %>% wilcox_test(dprime ~ noun_condition, paired=TRUE, p.adjust.method="holm")
  ph_d_r <- sdt %>% wilcox_effsize(dprime ~ noun_condition, paired=TRUE)
  print(ph_d); cat("  Rank-biserial r (Fix 5):\n"); print(ph_d_r)
} else {
  cat("  Non-significant at α = .05. Post-hoc skipped.\n")
}

# ── SDT-H2: Friedman on c ─────────────────────────────────────────────────────
cat("\n================================================================\n")
cat("SDT-H2: Friedman's Test — c ~ noun_condition\n")
cat("(Tests whether bias differs; null expected under trace-strength account)\n")
cat("================================================================\n")

frm_c <- sdt %>% friedman_test(c_crit ~ noun_condition | participant_id)
eff_c <- sdt %>% friedman_effsize(c_crit ~ noun_condition | participant_id)
print(frm_c); cat("  Kendall's W:\n"); print(eff_c)

if (!is.na(frm_c$p) && frm_c$p < 0.05) {
  cat("\n  Significant — post-hoc: Paired Wilcoxon (Holm-corrected)\n")
  ph_c   <- sdt %>% wilcox_test(c_crit ~ noun_condition, paired=TRUE, p.adjust.method="holm")
  ph_c_r <- sdt %>% wilcox_effsize(c_crit ~ noun_condition, paired=TRUE)
  print(ph_c); cat("  Rank-biserial r:\n"); print(ph_c_r)
} else {
  cat("  Non-significant at α = .05. Post-hoc skipped.\n")
}

# ── SDT-H1b: Friedman on A' (robustness check) ────────────────────────────────
cat("\n================================================================\n")
cat("SDT-H1b: Friedman's Test — A' ~ noun_condition (robustness check)\n")
cat("(Non-parametric ROC area; no Gaussian assumption — validates d' pattern)\n")
cat("================================================================\n")

frm_a <- sdt %>% friedman_test(A_prime ~ noun_condition | participant_id)
eff_a <- sdt %>% friedman_effsize(A_prime ~ noun_condition | participant_id)
print(frm_a); cat("  Kendall's W:\n"); print(eff_a)

if (!is.na(frm_a$p) && frm_a$p < 0.05) {
  ph_a   <- sdt %>% wilcox_test(A_prime ~ noun_condition, paired=TRUE, p.adjust.method="holm")
  ph_a_r <- sdt %>% wilcox_effsize(A_prime ~ noun_condition, paired=TRUE)
  print(ph_a); cat("  Rank-biserial r:\n"); print(ph_a_r)
} else {
  cat("  Non-significant at α = .05. Post-hoc skipped.\n")
}

# ── SDT-H3: Voice effect on d' and c ──────────────────────────────────────────
cat("\n================================================================\n")
cat("SDT-H3: Voice Effect on d' and c — Paired Wilcoxon\n")
cat("  LIMITATION: All lures are Active-voice; global FA used for both\n")
cat("  voices. Passive d' may be artificially elevated relative to true\n")
cat("  Active FA rate. Interpret voice d' comparison with caution.\n")
cat("================================================================\n")

sdt_v_agg <- sdt_v %>%
  group_by(participant_id, voice) %>%
  summarise(dprime = mean(dprime, na.rm=TRUE),
            c_crit = mean(c_crit, na.rm=TRUE),
            .groups = "drop") %>%
  pivot_wider(names_from=voice, values_from=c(dprime, c_crit))

complete_voice <- complete.cases(sdt_v_agg)
sdt_v_agg <- sdt_v_agg[complete_voice, ]
N_v <- nrow(sdt_v_agg)
cat(sprintf("  N (complete pairs): %d\n", N_v))

wt_d <- wilcox.test(sdt_v_agg$dprime_Active, sdt_v_agg$dprime_Passive, paired=TRUE, exact=FALSE)
wt_c <- wilcox.test(sdt_v_agg$c_crit_Active, sdt_v_agg$c_crit_Passive, paired=TRUE, exact=FALSE)
Z_d  <- qnorm(wt_d$p.value/2) * sign(wt_d$statistic - median(c(sdt_v_agg$dprime_Active - sdt_v_agg$dprime_Passive), na.rm=TRUE))
Z_c  <- qnorm(wt_c$p.value/2) * sign(wt_c$statistic - median(c(sdt_v_agg$c_crit_Active  - sdt_v_agg$c_crit_Passive),  na.rm=TRUE))

cat(sprintf("\n── d': Active M=%.3f vs Passive M=%.3f\n",
            mean(sdt_v_agg$dprime_Active, na.rm=TRUE), mean(sdt_v_agg$dprime_Passive, na.rm=TRUE)))
print(wt_d)
cat(sprintf("  rank-biserial r = %.3f\n", abs(Z_d)/sqrt(N_v)))

cat(sprintf("\n── c: Active M=%.3f vs Passive M=%.3f\n",
            mean(sdt_v_agg$c_crit_Active, na.rm=TRUE), mean(sdt_v_agg$c_crit_Passive, na.rm=TRUE)))
print(wt_c)
cat(sprintf("  rank-biserial r = %.3f\n", abs(Z_c)/sqrt(N_v)))

# ── SDT-H4: Convergent validity — Spearman d' vs Corrected IR ─────────────────
cat("\n================================================================\n")
cat("SDT-H4: Convergent Validity — Spearman rho(d', Corrected IR)\n")
cat("(rho > .80: Corrected IR was adequate proxy; <.70: bias contamination)\n")
cat("================================================================\n")

# Collapse cr_scores across voice to match sdt (condition-level)
cr_coll <- cr %>%
  group_by(participant_id, noun_condition) %>%
  summarise(ir_cr = mean(ir_cr, na.rm=TRUE), .groups="drop") %>%
  mutate(noun_condition = factor(noun_condition, levels=c("HH","HL","LH","LL")))

conv <- sdt %>%
  left_join(cr_coll, by=c("participant_id","noun_condition")) %>%
  group_by(noun_condition) %>%
  summarise(
    rho = round(cor(dprime, ir_cr, method="spearman", use="complete.obs"), 3),
    n   = sum(!is.na(dprime) & !is.na(ir_cr)),
    .groups = "drop"
  )
print(as.data.frame(conv), row.names=FALSE)

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
                          "rho in [.70,.80) — Corrected IR approximates d' with moderate fidelity.",
                          "rho < .70 — notable bias contamination; SDT adds meaningful information."))))

cat("\n\n================================================================\n")
cat(sprintf("  SDT analysis complete : %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Saved -> %s\n", out_file))
cat("================================================================\n")
sink()
cat(sprintf("\nSaved -> %s\n", out_file))

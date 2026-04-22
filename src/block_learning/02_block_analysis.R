# src/block_learning/02_block_analysis.R
# Block-level learning analysis for the sentence memorability study.
#
# Tests whether IR / WR accuracy / RT change across experimental blocks,
# and whether the LL deficit is stable or attenuates over time.
#
# ANALYSIS A — Main effect of Block (Friedman's, collapsed across condition)
#   Does overall recognition discriminability improve with exposure?
#   3-level within-participants design → Friedman's.
#   Post-hoc: paired Wilcoxon signed-rank (Holm-corrected) + rank-biserial r.
#
# ANALYSIS B — Scheirer-Ray-Hare: Noun Condition × Block interaction
#   Same approach as Condition × Voice SRH in 05b_statistical_tests.R.
#   Tests whether the LL deficit changes across blocks (interaction).
#   Uses rcompanion::scheirerRayHare (consistent with rest of pipeline).
#
# ANALYSIS C — Per-block Friedman on noun condition
#   Replicates the main Friedman within each individual block.
#   Key theoretical test: does the LL deficit hold in Block 1, 2, and 3?
#
# Input:  data/processed/block_scores.csv
# Output: outputs/block_learning/block_stats.txt

suppressPackageStartupMessages({
  library(dplyr)
  library(rstatix)      # friedman_test(), friedman_effsize(), wilcox_test(), wilcox_effsize()
  library(rcompanion)   # scheirerRayHare() — consistent with rest of pipeline
})

dir.create("outputs/block_learning", showWarnings = FALSE, recursive = TRUE)
out_file <- "outputs/block_learning/block_stats.txt"

# Dual output: console + file (mirrors main pipeline pattern)
sink(out_file, split = TRUE)

cat("================================================================\n")
cat("  Block-Level Learning Analysis\n")
cat("================================================================\n")
cat(sprintf("  Run : %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Input : data/processed/block_scores.csv\n\n"))

bs <- read.csv("data/processed/block_scores.csv", stringsAsFactors = FALSE) %>%
  mutate(
    block_id       = factor(block_id,       levels = c("Block 1", "Block 2", "Block 3")),
    noun_condition = factor(noun_condition, levels = c("HH", "HL", "LH", "LL"))
  )

cat(sprintf("  Participants : %d\n", length(unique(bs$participant_id))))
cat(sprintf("  Rows         : %d  (%d per participant: 3 blocks × 4 conditions)\n",
            nrow(bs), nrow(bs) / length(unique(bs$participant_id))))

# ──────────────────────────────────────────────────────────────────────────────
# ──────────────────────────────────────────────────────────────────────────────
# Normality: Shapiro-Wilk per condition group and per block
# Normality must be checked separately per group being compared,
# not once on the pooled distribution. We check corrected_ir (primary DV)
# grouped by noun_condition (4 groups) and by block_id (3 groups).
# If any group fails (p < .05) → non-parametric route is justified.
# ──────────────────────────────────────────────────────────────────────────────
cat("\n\n================================================================\n")
cat("NORMALITY CHECK — Shapiro-Wilk per Group\n")
cat("(One test per group being compared; pooled tests are uninformative)\n")
cat("================================================================\n")

# Corrected IR per noun_condition (4 groups; used in Analysis C)
cat("\n── Shapiro-Wilk: Corrected IR by Noun Condition ──\n")
norm_by_cond <- bs %>%
  group_by(noun_condition) %>%
  summarise(
    n       = n(),
    W       = shapiro.test(corrected_ir[!is.na(corrected_ir)])$statistic,
    p_value = shapiro.test(corrected_ir[!is.na(corrected_ir)])$p.value,
    .groups = "drop"
  ) %>%
  mutate(conclusion = ifelse(p_value < 0.05, "Non-normal (p < .05)", "Normal (p > .05)"))
print(as.data.frame(norm_by_cond), row.names = FALSE)
n_nonnormal_cond <- sum(norm_by_cond$p_value < 0.05)
cat(sprintf("  %d/%d noun condition groups are non-normal\n",
            n_nonnormal_cond, nrow(norm_by_cond)))

# Corrected IR per block (3 groups; used in Analysis A)
cat("\n── Shapiro-Wilk: Corrected IR by Block ──\n")
# Collapse across condition first (matches the block-level Friedman)
bs_collapsed_norm <- bs %>%
  group_by(participant_id, block_id) %>%
  summarise(corrected_ir = mean(corrected_ir, na.rm = TRUE), .groups = "drop")
norm_by_block <- bs_collapsed_norm %>%
  group_by(block_id) %>%
  summarise(
    n       = n(),
    W       = shapiro.test(corrected_ir[!is.na(corrected_ir)])$statistic,
    p_value = shapiro.test(corrected_ir[!is.na(corrected_ir)])$p.value,
    .groups = "drop"
  ) %>%
  mutate(conclusion = ifelse(p_value < 0.05, "Non-normal (p < .05)", "Normal (p > .05)"))
print(as.data.frame(norm_by_block), row.names = FALSE)
n_nonnormal_block <- sum(norm_by_block$p_value < 0.05)
cat(sprintf("  %d/%d block groups are non-normal\n",
            n_nonnormal_block, nrow(norm_by_block)))

# Sphericity acknowledgment
cat("\n── Sphericity ──\n")
cat("  Mauchly's test of sphericity is not applicable here.\n")
cat("  Because normality is violated in at least one group, Friedman's non-parametric\n")
cat("  test was used throughout. Friedman's operates on ranks and does not assume\n")
cat("  equal variances (sphericity) across conditions — the assumption is implicitly\n")
cat("  bypassed by the rank transformation.\n")

# ──────────────────────────────────────────────────────────────────────────────
# ANALYSIS A: Main Effect of Block (Friedman's)
# Collapsed across noun_condition → pure block effect.
# Friedman's is correct: within-participants, 3-level (Block 1 / 2 / 3).
# ──────────────────────────────────────────────────────────────────────────────

bs_by_block <- bs %>%
  group_by(participant_id, block_id) %>%
  summarise(corrected_ir = mean(corrected_ir, na.rm = TRUE),
            wr_acc       = mean(wr_acc,       na.rm = TRUE),
            mean_rt      = mean(mean_rt,      na.rm = TRUE),
            .groups      = "drop")

cat("\n\n================================================================\n")
cat("ANALYSIS A — Main Effect of Block (Friedman's)\n")
cat("(Collapsed across noun condition; tests pure learning/fatigue)\n")
cat("(3-level within-participants → Friedman's)\n")
cat("================================================================\n")

run_block_friedman <- function(df, metric_col, label) {
  cat(sprintf("\n── A. Friedman's: Block effect on %s ──\n", label))
  frm <- df %>%
    friedman_test(as.formula(paste(metric_col, "~ block_id | participant_id")))
  print(frm)

  eff <- df %>%
    friedman_effsize(as.formula(paste(metric_col, "~ block_id | participant_id")))
  cat("  Kendall's W:\n")
  print(eff)

  if (!is.na(frm$p) && frm$p < 0.05) {
    cat("\n  Significant — post-hoc: Paired Wilcoxon signed-rank (Holm-corrected)\n")
    cat("  (Same participants across all 3 blocks → paired = TRUE)\n")
    ph <- df %>%
      wilcox_test(as.formula(paste(metric_col, "~ block_id")),
                  paired = TRUE, p.adjust.method = "holm")
    print(ph)

    ph_r <- df %>%
      wilcox_effsize(as.formula(paste(metric_col, "~ block_id")), paired = TRUE)
    cat("  Rank-biserial r:\n")
    print(ph_r)
  } else {
    cat("  Non-significant at α = .05. Post-hoc skipped.\n")
  }
}

run_block_friedman(bs_by_block, "corrected_ir", "Corrected IR")
run_block_friedman(bs_by_block, "wr_acc",       "WR Accuracy")
run_block_friedman(bs_by_block, "mean_rt",      "Reaction Time (ms)")

# ──────────────────────────────────────────────────────────────────────────────
# ANALYSIS B: Condition × Block Interaction (Scheirer-Ray-Hare)
# Same approach as Condition × Voice SRH in 05b_statistical_tests.R.
# η²_H reported per term, consistent with existing pipeline (F5).
# ──────────────────────────────────────────────────────────────────────────────

cat("\n\n================================================================\n")
cat("ANALYSIS B — Scheirer-Ray-Hare: Noun Condition × Block Interaction\n")
cat("(2-way non-parametric; tests whether LL deficit changes over blocks)\n")
cat("(Mirrors Condition × Voice SRH in 05b; uses rcompanion)\n")
cat("================================================================\n")
cat("  Note: SRH was designed for independent groups. Used here as a 2-way\n")
cat("  approximation; sensitivity Friedman per voice level follows.\n")

run_srh_block <- function(metric_col, label) {
  cat(sprintf("\n── B. SRH: %s ~ noun_condition + block_id ──\n", label))

  # SRH cell-balance check
  cell_counts <- bs %>%
    count(noun_condition, block_id) %>%
    arrange(noun_condition, block_id)
  if (var(cell_counts$n) > 0) {
    cat("  WARNING: Unbalanced cells detected — interpret SRH with caution.\n")
  } else {
    cat("  Cell balance check: OK (all cells equal)\n")
  }

  srh <- scheirerRayHare(
    as.formula(paste(metric_col, "~ noun_condition + block_id")),
    data = bs
  )
  print(srh)

  # η²_H per term = H_term / sum(all H terms)
  h_vals <- srh$H
  eta_H  <- round(h_vals / sum(h_vals, na.rm = TRUE), 4)
  cat(sprintf("  η²_H (noun_condition) = %.4f\n", eta_H[1]))
  cat(sprintf("  η²_H (block_id)       = %.4f\n", eta_H[2]))
  cat(sprintf("  η²_H (interaction)    = %.4f\n", eta_H[3]))
  cat("  (η²_H benchmarks: .01 small, .06 medium, .14 large)\n")
}

run_srh_block("corrected_ir", "Corrected IR")
run_srh_block("wr_acc",       "WR Accuracy")

# ──────────────────────────────────────────────────────────────────────────────
# ANALYSIS C: Per-Block Friedman on Noun Condition
# Replicates the main Friedman within each block separately.
# Key theoretical test: does the LL deficit replicate in every block?
# If it disappears by Block 3, that supports a familiarity account.
# ──────────────────────────────────────────────────────────────────────────────

cat("\n\n================================================================\n")
cat("ANALYSIS C — Per-Block Friedman: Noun Condition Effect within Each Block\n")
cat("(Does the LL deficit hold separately in Block 1, Block 2, Block 3?)\n")
cat("(Post-hoc only if omnibus p < .05, Holm-corrected)\n")
cat("================================================================\n")

for (blk in levels(bs$block_id)) {
  cat(sprintf("\n── C. Block: %s ──\n", blk))
  bs_sub <- bs %>% filter(block_id == blk)

  n_sub <- length(unique(bs_sub$participant_id))
  cat(sprintf("  Participants with complete data: %d\n", n_sub))

  result <- tryCatch(
    bs_sub %>%
      friedman_test(corrected_ir ~ noun_condition | participant_id),
    error = function(e) { cat(sprintf("  ERROR: %s\n", e$message)); NULL }
  )
  if (is.null(result)) next
  print(result)

  w_eff <- bs_sub %>%
    friedman_effsize(corrected_ir ~ noun_condition | participant_id)
  cat("  Kendall's W:\n")
  print(w_eff)

  if (!is.na(result$p) && result$p < 0.05) {
    cat("  Significant — post-hoc: Paired Wilcoxon signed-rank (Holm-corrected)\n")
    ph <- bs_sub %>%
      wilcox_test(corrected_ir ~ noun_condition,
                  paired = TRUE, p.adjust.method = "holm")
    print(ph)

    ph_r <- bs_sub %>%
      wilcox_effsize(corrected_ir ~ noun_condition, paired = TRUE)
    cat("  Rank-biserial r:\n")
    print(ph_r)
  } else {
    cat("  Non-significant at α = .05. Post-hoc skipped.\n")
  }
}

cat("\n\n================================================================\n")
cat(sprintf("  Analysis complete : %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Saved -> %s\n", out_file))
cat("================================================================\n")

sink()
cat(sprintf("\nSaved -> %s\n", out_file))

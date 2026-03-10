# 05b_statistical_tests.R
# Non-parametric inferential statistics for the sentence memorability study.
#
# Tests run:
#   1. Kruskal-Wallis: ir_cr ~ noun_condition
#   2. Kruskal-Wallis: wr_acc_score ~ noun_condition
#   3. Kruskal-Wallis: ir_rt ~ noun_condition
#   4. Post-hoc pairwise Wilcoxon (Holm correction) for significant KW tests
#   5. Scheirer-Ray-Hare: ir_cr ~ noun_condition * voice
#   6. Scheirer-Ray-Hare: wr_acc_score ~ noun_condition * voice
#   7. Paired Wilcoxon signed-rank: Active vs Passive voice on IR CR
#   8. Paired Wilcoxon signed-rank: Active vs Passive voice on WR accuracy
#   9. One-sample Wilcoxon: WR accuracy vs 0.5 (chance) for each voice
#
# Inputs:  data/processed/cr_scores.csv
# Outputs: outputs/stats/statistical_tests.txt

cat("\n[05b_statistical_tests] Running non-parametric inferential statistics...\n")

library(dplyr)
library(tidyr)
library(rcompanion)

cr_scores <- read.csv("data/processed/cr_scores.csv") %>%
    filter(noun_condition %in% c("HH", "HL", "LH", "LL"))
cr_scores$noun_condition <- factor(cr_scores$noun_condition, levels = c("HH", "HL", "LH", "LL"))
cr_scores$voice <- factor(cr_scores$voice)

cat(sprintf(
    "  Input : %d observations | conditions : %s | voices : %s\n",
    nrow(cr_scores),
    paste(levels(cr_scores$noun_condition), collapse = "/"),
    paste(levels(cr_scores$voice), collapse = "/")
))

# Capture all output for saving
.stat_lines <- character(0)
.log_test <- function(...) {
    lines <- c(...)
    .stat_lines <<- c(.stat_lines, lines)
    cat(paste(lines, collapse = "\n"), "\n")
}

# ── Omnibus Kruskal-Wallis + post-hoc ───────────────────────────────────────
run_kw <- function(metric_name, label) {
    .log_test(sprintf("\n================================================================"))
    .log_test(sprintf("Kruskal-Wallis: %s ~ noun_condition", label))
    .log_test(sprintf("================================================================"))

    res <- kruskal.test(as.formula(paste(metric_name, "~ noun_condition")),
        data = cr_scores
    )
    .stat_lines <<- c(.stat_lines, capture.output(print(res)))
    print(res)

    eps <- epsilonSquared(x = cr_scores[[metric_name]], g = cr_scores$noun_condition)
    .log_test(sprintf("  Effect Size (epsilon^2) = %.4f", eps))
    cat(sprintf(
        "  Interpretation: %s\n",
        if (eps < 0.01) {
            "negligible"
        } else if (eps < 0.06) {
            "small"
        } else if (eps < 0.14) "medium" else "large"
    ))

    if (res$p.value < 0.05) {
        .log_test(sprintf("\n  Post-hoc Pairwise Wilcoxon (Holm correction) for %s:", label))
        ph <- pairwise.wilcox.test(cr_scores[[metric_name]],
            cr_scores$noun_condition,
            p.adjust.method = "holm"
        )
        .stat_lines <<- c(.stat_lines, capture.output(print(ph)))
        print(ph)
    } else {
        .log_test("  No post-hoc test (omnibus p >= .05)")
    }
}

cat("\n  --- Omnibus Tests ---\n")
run_kw("ir_cr", "Corrected IR")
run_kw("wr_acc_score", "WR Accuracy")
run_kw("ir_rt", "IR Reaction Time")

# ── Scheirer-Ray-Hare: Condition x Voice Interaction ────────────────────────
cat("\n  --- Interaction Tests (Scheirer-Ray-Hare) ---\n")

.log_test("\n================================================================")
.log_test("Scheirer-Ray-Hare: Corrected IR ~ noun_condition * voice")
.log_test("================================================================")
srh_ir <- scheirerRayHare(ir_cr ~ noun_condition * voice, data = cr_scores)
.stat_lines <- c(.stat_lines, capture.output(print(srh_ir)))
print(srh_ir)

.log_test("\n================================================================")
.log_test("Scheirer-Ray-Hare: WR Accuracy ~ noun_condition * voice")
.log_test("================================================================")
srh_wr <- scheirerRayHare(wr_acc_score ~ noun_condition * voice, data = cr_scores)
.stat_lines <- c(.stat_lines, capture.output(print(srh_wr)))
print(srh_wr)

# ── Paired Wilcoxon signed-rank: Voice effects ──────────────────────────────
cat("\n  --- Voice Effects (Paired Wilcoxon Signed-Rank) ---\n")

# Aggregate to participant level, collapsed across noun condition
voice_agg <- cr_scores %>%
    group_by(participant_id, voice) %>%
    summarise(
        ir_cr_mean = mean(ir_cr, na.rm = TRUE),
        wr_acc_mean = mean(wr_acc_score, na.rm = TRUE),
        .groups = "drop"
    ) %>%
    pivot_wider(
        names_from = voice,
        values_from = c(ir_cr_mean, wr_acc_mean)
    )

.log_test("\n================================================================")
.log_test("Paired Wilcoxon: Corrected IR Active vs Passive")
.log_test("================================================================")
wsr_ir <- wilcox.test(voice_agg$ir_cr_mean_Active,
    voice_agg$ir_cr_mean_Passive,
    paired = TRUE
)
.stat_lines <- c(.stat_lines, capture.output(print(wsr_ir)))
print(wsr_ir)
cat(sprintf(
    "  Active: M=%.3f | Passive: M=%.3f\n",
    mean(voice_agg$ir_cr_mean_Active, na.rm = TRUE),
    mean(voice_agg$ir_cr_mean_Passive, na.rm = TRUE)
))

.log_test("\n================================================================")
.log_test("Paired Wilcoxon: WR Accuracy Active vs Passive")
.log_test("================================================================")
wsr_wr <- wilcox.test(voice_agg$wr_acc_mean_Active,
    voice_agg$wr_acc_mean_Passive,
    paired = TRUE
)
.stat_lines <- c(.stat_lines, capture.output(print(wsr_wr)))
print(wsr_wr)
cat(sprintf(
    "  Active: M=%.3f | Passive: M=%.3f\n",
    mean(voice_agg$wr_acc_mean_Active, na.rm = TRUE),
    mean(voice_agg$wr_acc_mean_Passive, na.rm = TRUE)
))

# ── One-sample Wilcoxon: WR vs chance (0.5) ─────────────────────────────────
cat("\n  --- WR vs Chance (One-Sample Wilcoxon) ---\n")

.log_test("\n================================================================")
.log_test("One-sample Wilcoxon: WR Active vs chance (0.5)")
.log_test("================================================================")
wr_active_test <- wilcox.test(voice_agg$wr_acc_mean_Active,
    mu = 0.5,
    alternative = "greater"
)
.stat_lines <- c(.stat_lines, capture.output(print(wr_active_test)))
print(wr_active_test)

.log_test("\n================================================================")
.log_test("One-sample Wilcoxon: WR Passive vs chance (0.5)")
.log_test("================================================================")
wr_passive_test <- wilcox.test(voice_agg$wr_acc_mean_Passive,
    mu = 0.5,
    alternative = "greater"
)
.stat_lines <- c(.stat_lines, capture.output(print(wr_passive_test)))
print(wr_passive_test)

# ── Save to outputs/stats/ ──────────────────────────────────────────────────
if (exists("stat_dir")) {
    writeLines(.stat_lines, file.path(stat_dir, "statistical_tests.txt"))
    cat(sprintf("\n  Saved -> %s/statistical_tests.txt\n", stat_dir))
}

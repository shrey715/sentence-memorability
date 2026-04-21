# 05b_statistical_tests.R
# Non-parametric inferential statistics for the sentence memorability study.
#
# CORRECTIONS applied in this version (vs. original):
#   F2  — Kruskal-Wallis replaced by Friedman's test (correct for within-participants)
#   F3  — Post-hoc Wilcoxon now uses paired = TRUE (signed-rank, not rank-sum)
#   F4  — Rank-biserial r added for every post-hoc Wilcoxon pair
#   F5  — Scheirer-Ray-Hare gains η²_H; sensitivity Friedman per voice added
#   F6  — Voice paired Wilcoxon gains rank-biserial r (collapsed across conditions)
#   F6b — Group-wise voice Wilcoxon: Active vs Passive within each noun condition
#   F7  — One-sample Wilcoxon gains rank-biserial r
#   F9  — Fligner-Killeen homogeneity of variance check added
#   F10 — SRH cell-balance verification added
#   F12 — Family-wise α across three omnibus tests documented explicitly
#
# Tests run:
#   [F9]  Fligner-Killeen homogeneity of variance (all 3 metrics)
#   [F2]  Friedman's test: metric ~ noun_condition | participant_id (x3)
#   [F3/4] Post-hoc paired Wilcoxon signed-rank + rank-biserial r (Holm-corrected)
#   [F5]  Scheirer-Ray-Hare: metric ~ noun_condition + voice (x2) + η²_H
#   [F5]  Sensitivity: Friedman per voice level (x2 metrics x 2 voices)
#   [F6]  Paired Wilcoxon: Active vs Passive (collapsed) + r
#   [F6b] Paired Wilcoxon: Active vs Passive within each noun condition
#   [F7]  One-sample Wilcoxon: WR vs chance (0.5) + r
#
# Inputs:  data/processed/cr_scores.csv
# Outputs: outputs/stats/statistical_tests.txt
#          outputs/stats/homogeneity.txt

cat("\n[05b_statistical_tests] Running non-parametric inferential statistics...\n")

suppressPackageStartupMessages({
    library(dplyr)
    library(tidyr)
    library(rcompanion)  # scheirerRayHare(), epsilonSquared()
    library(rstatix)     # wilcox_effsize(), friedman_test(), friedman_effsize()
})

cr_scores <- read.csv("data/processed/cr_scores.csv") %>%
    filter(noun_condition %in% c("HH", "HL", "LH", "LL"))
cr_scores$noun_condition <- factor(cr_scores$noun_condition, levels = c("HH", "HL", "LH", "LL"))
cr_scores$voice          <- factor(cr_scores$voice)

cat(sprintf(
    "  Input : %d observations | conditions : %s | voices : %s\n",
    nrow(cr_scores),
    paste(levels(cr_scores$noun_condition), collapse = "/"),
    paste(levels(cr_scores$voice), collapse = "/")
))

# Capture all output for saving
.stat_lines <- character(0)
.log <- function(...) {
    lines <- c(...)
    .stat_lines <<- c(.stat_lines, lines)
    cat(paste(lines, collapse = "\n"), "\n")
}

# ── F9: Homogeneity of Variance — Fligner-Killeen ───────────────────────────
# Fligner-Killeen is the non-parametric equivalent of Levene's test.
# Appropriate here because data is non-normal (Levene's assumes normal residuals).
# Class 14.pdf: homogeneity check is part of the decision flowchart.
# Note: Friedman's test is used regardless — this is for documentation.
cat("\n  --- Homogeneity of Variance: Fligner-Killeen (F9) ---\n")

fk_ir <- fligner.test(ir_cr        ~ noun_condition, data = cr_scores)
fk_wr <- fligner.test(wr_acc_score ~ noun_condition, data = cr_scores)
fk_rt <- fligner.test(ir_rt        ~ noun_condition, data = cr_scores)

fk_lines <- c(
    "=== Fligner-Killeen Test: Homogeneity of Variance ===",
    "(Non-parametric equivalent of Levene's; class 14.pdf flowchart step)",
    "",
    "IR Corrected Rate:",
    capture.output(print(fk_ir)),
    "",
    "WR Accuracy:",
    capture.output(print(fk_wr)),
    "",
    "IR Reaction Time:",
    capture.output(print(fk_rt)),
    "",
    "Interpretation: p < .05 indicates unequal spread across conditions.",
    "Friedman's test is used regardless (robustness to variance heterogeneity)."
)
cat(paste(fk_lines, collapse = "\n"), "\n")

if (exists("stat_dir")) {
    writeLines(fk_lines, file.path(stat_dir, "homogeneity.txt"))
    cat(sprintf("  Saved -> %s/homogeneity.txt\n", stat_dir))
}

# ── F12: Family-Wise α — Three Omnibus Tests ────────────────────────────────
# Class 14.pdf + 10.pdf: when running multiple omnibus tests on the same dataset,
# adjust the family-wise α. Three Friedman tests → Bonferroni α = 0.05 / 3.
# Within each significant omnibus, Holm correction is applied to post-hoc pairs.
FAMILYWISE_ALPHA <- 0.05 / 3   # = 0.01667
.log(
    "\n================================================================",
    "FAMILY-WISE α NOTE (class 14.pdf + 10.pdf)",
    "================================================================",
    "Three omnibus Friedman tests run on the same dataset:",
    "  (1) IR Corrected Rate, (2) WR Accuracy, (3) IR Reaction Time",
    sprintf("Bonferroni-adjusted family-wise alpha = 0.05 / 3 = %.4f", FAMILYWISE_ALPHA),
    "All omnibus results interpreted at this threshold for strict FWER control.",
    "Within significant omnibus tests, Holm correction applied to pairwise post-hocs."
)

# ── Aggregate to one row per participant × condition (for Friedman omnibus) ──
# Friedman's test requires an "unreplicated complete block design":
# exactly one observation per participant (block) × condition (group).
# Since cr_scores has 2 rows per participant × condition (Active + Passive),
# we collapse across voice by taking the mean. Voice effects are tested
# separately with paired Wilcoxon (F6) and group-wise tests (F6b).
cr_collapsed <- cr_scores %>%
    group_by(participant_id, noun_condition) %>%
    summarise(
        ir_cr        = mean(ir_cr,        na.rm = TRUE),
        wr_acc_score = mean(wr_acc_score, na.rm = TRUE),
        ir_rt        = mean(ir_rt,        na.rm = TRUE),
        .groups = "drop"
    )
cr_collapsed$noun_condition <- factor(cr_collapsed$noun_condition,
                                       levels = c("HH", "HL", "LH", "LL"))

cat(sprintf(
    "  Collapsed table (for Friedman omnibus): %d rows | %d participants x %d conditions\n",
    nrow(cr_collapsed),
    length(unique(cr_collapsed$participant_id)),
    nlevels(cr_collapsed$noun_condition)
))

# ── F2/F3/F4: Friedman's Test + Paired Post-hoc + Rank-biserial r ───────────
# F2: Friedman's is the correct non-parametric test for within-participants,
#     repeated-measures designs (class 14.pdf flowchart — replaces KW).
#     KW assumes independent groups; all participants appear in all 4 conditions.
# F3: Post-hoc uses paired Wilcoxon signed-rank (not rank-sum).
# F4: Rank-biserial r reported for each post-hoc pair (class 12.pdf).

run_friedman <- function(metric_col, label) {

    .log(
        "\n================================================================",
        sprintf("FRIEDMAN'S TEST: %s ~ noun_condition", label),
        "(Replaces Kruskal-Wallis: within-participants design, class 14.pdf)",
        "(Input: per-participant means collapsed across voice levels)",
        "================================================================"
    )

    # Base R Friedman test on the collapsed (one row per participant x condition) table
    res <- friedman.test(
        as.formula(paste(metric_col, "~ noun_condition | participant_id")),
        data = cr_collapsed
    )
    .stat_lines <<- c(.stat_lines, capture.output(print(res)))
    print(res)

    # Effect size: Kendall's W = chi² / (N * (k - 1))
    # (replaces epsilon² which was reported for KW)
    N_parts <- length(unique(cr_collapsed$participant_id))
    k       <- nlevels(cr_collapsed$noun_condition)   # = 4
    kendall_W <- as.numeric(res$statistic) / (N_parts * (k - 1))
    .log(
        sprintf("  Kendall's W = %.4f", kendall_W),
        "  (Benchmarks: W ~ .1 small, .3 medium, .5 large per Tomczak & Tomczak 2014)"
    )

    # Gate post-hoc on family-wise adjusted alpha
    if (res$p.value < FAMILYWISE_ALPHA) {
        .log(
            sprintf("\n  Omnibus significant at family-wise alpha = %.4f", FAMILYWISE_ALPHA),
            "  --- Post-hoc: Paired Wilcoxon Signed-Rank (Holm-corrected) ---",
            "  NOTE: paired = TRUE — same participants across all 4 conditions.",
            "  (Class 14.pdf: within-participants -> signed-rank, not rank-sum.)"
        )

        # F3: paired = TRUE (key correction from original)
        ph <- pairwise.wilcox.test(
            cr_collapsed[[metric_col]],
            cr_collapsed$noun_condition,
            paired          = TRUE,
            p.adjust.method = "holm"
        )
        .stat_lines <<- c(.stat_lines, capture.output(print(ph)))
        print(ph)

        # State Holm-corrected alpha threshold explicitly (class 14.pdf)
        n_pairs <- choose(k, 2)   # = 6 for 4 conditions C(4,2)
        .log(sprintf(
            "  Holm-corrected alpha (most conservative threshold): %.4f",
            0.05 / n_pairs
        ))

        # F4: rank-biserial r per pair (class 12.pdf)
        .log("  Rank-biserial r (effect size per pair):")
        tryCatch({
            ph_r <- cr_collapsed %>%
                wilcox_effsize(
                    as.formula(paste(metric_col, "~ noun_condition")),
                    paired    = TRUE
                )
            .stat_lines <<- c(.stat_lines, capture.output(print(ph_r)))
            print(ph_r)
        }, error = function(e) {
            .log(sprintf("  [Note] wilcox_effsize error: %s", e$message))
        })

    } else {
        .log(sprintf(
            "  Omnibus non-significant at family-wise alpha = %.4f. Post-hoc skipped.",
            FAMILYWISE_ALPHA
        ))
    }
}

.log(
    "\n  --- Sphericity (class 14.pdf) ---",
    "  Mauchly's test of sphericity is not applicable here as the analysis used",
    "  Friedman's non-parametric test, which operates on ranks and does not assume",
    "  equal variances across conditions."
)

cat("\n  --- Omnibus Tests (Friedman's) ---\n")
run_friedman("ir_cr",        "Corrected IR")
run_friedman("wr_acc_score", "WR Accuracy")
run_friedman("ir_rt",        "IR Reaction Time")

# ── F10: SRH Cell-Balance Check ─────────────────────────────────────────────
# Scheirer-Ray-Hare requires balanced cell sizes. Verify at participant level.
cat("\n  --- Cell-Size Balance Check for SRH (F10) ---\n")
cell_counts <- cr_scores %>%
    count(noun_condition, voice) %>%
    arrange(noun_condition, voice)

.log(
    "\n================================================================",
    "CELL-SIZE BALANCE CHECK (required for valid SRH, F10)",
    "================================================================"
)
.stat_lines <<- c(.stat_lines, capture.output(print(as.data.frame(cell_counts), row.names = FALSE)))
print(as.data.frame(cell_counts), row.names = FALSE)

if (var(cell_counts$n) > 0) {
    warning("UNBALANCED CELLS — SRH results may be unreliable. Check design.")
    .log("  WARNING: Unbalanced cells detected — interpret SRH with caution.")
} else {
    .log("  Cells balanced. SRH assumption met.")
}

# ── F5: Scheirer-Ray-Hare + η²_H + Sensitivity Friedman per Voice ───────────
# SRH is the class-taught 2-way non-parametric test (class 14.pdf).
# Limitation noted: SRH was designed for independent groups; used here as
# the primary interaction test per class material, with sensitivity checks below.
cat("\n  --- Interaction Tests: Scheirer-Ray-Hare + Sensitivity Friedman (F5) ---\n")

run_srh <- function(metric_col, label) {
    .log(
        "\n================================================================",
        sprintf("SCHEIRER-RAY-HARE: %s ~ noun_condition * voice", label),
        "(2-way non-parametric, class 14.pdf; limitation: designed for indep. groups)",
        "LIMITATION NOTE (Fix 7): The Scheirer-Ray-Hare test was developed for",
        "mixed factorial designs; as both factors are within-participants here,",
        "the H statistics should be interpreted with caution as an approximation.",
        "================================================================"
    )
    srh <- scheirerRayHare(
        as.formula(paste(metric_col, "~ noun_condition + voice")),
        data = cr_scores
    )
    .stat_lines <<- c(.stat_lines, capture.output(print(srh)))
    print(srh)

    # F5: η²_H per term = (H - (k-1)) / (N - k)
    N_total <- nrow(cr_scores)
    k_cond <- nlevels(cr_scores$noun_condition)
    k_voice <- nlevels(cr_scores$voice)
    k_int <- k_cond * k_voice

    eta_H_cond <- (srh$H[1] - (k_cond - 1)) / (N_total - k_cond)
    eta_H_voice <- (srh$H[2] - (k_voice - 1)) / (N_total - k_voice)
    eta_H_int <- (srh$H[3] - (k_int - 1)) / (N_total - k_int)

    .log(
        sprintf("  eta^2_H (noun_condition) = %.4f", eta_H_cond),
        sprintf("  eta^2_H (voice)          = %.4f", eta_H_voice),
        sprintf("  eta^2_H (interaction)    = %.4f", eta_H_int),
        "  (eta^2_H benchmarks: .01 small, .06 medium, .14 large)"
    )

    # F5: Sensitivity — Friedman per voice level
    .log(sprintf(
        "\n  Sensitivity check: Friedman per voice level (%s)", label
    ))
    for (v in levels(cr_scores$voice)) {
        # Use only participants with a non-NA score for this metric in this voice
        # (required for Friedman's "unreplicated complete block design" assumption)
        sub <- cr_scores %>%
            filter(voice == v, !is.na(.data[[metric_col]])) %>%
            group_by(participant_id) %>%
            filter(n_distinct(noun_condition) == nlevels(cr_scores$noun_condition)) %>%
            ungroup()

        if (nrow(sub) == 0) {
            .log(sprintf("    %s: no complete cases. Skipped.", v))
            next
        }

        frd <- tryCatch(
            friedman.test(
                as.formula(paste(metric_col, "~ noun_condition | participant_id")),
                data = sub
            ),
            error = function(e) list(statistic = NA, p.value = NA, message = e$message)
        )
        if (!is.na(frd$statistic)) {
            N_v <- length(unique(sub$participant_id))
            k_v <- nlevels(factor(sub$noun_condition))
            W_v <- as.numeric(frd$statistic) / (N_v * (k_v - 1))
            .log(sprintf(
                "    %s: chi2(3) = %.3f, p = %.4f, Kendall's W = %.4f (N = %d participants)",
                v, as.numeric(frd$statistic), frd$p.value, W_v, N_v
            ))
        } else {
            .log(sprintf("    %s: error — %s", v, frd$message))
        }
    }
}

run_srh("ir_cr",        "Corrected IR")
run_srh("wr_acc_score", "WR Accuracy")

# ── F6: Voice Main Effect — Paired Wilcoxon + Rank-Biserial r ───────────────
# Collapsed across noun conditions. paired = TRUE was already correct.
# F6 adds the missing rank-biserial r effect size (class 12.pdf).
cat("\n  --- Voice Main Effect: Paired Wilcoxon (collapsed) (F6) ---\n")

voice_agg <- cr_scores %>%
    group_by(participant_id, voice) %>%
    summarise(
        ir_cr_mean  = mean(ir_cr,        na.rm = TRUE),
        wr_acc_mean = mean(wr_acc_score, na.rm = TRUE),
        .groups = "drop"
    ) %>%
    pivot_wider(
        names_from  = voice,
        values_from = c(ir_cr_mean, wr_acc_mean)
    )

# IR CR: Active vs Passive
.log(
    "\n================================================================",
    "Paired Wilcoxon: Corrected IR — Active vs Passive (collapsed)",
    "================================================================"
)
wsr_ir <- wilcox.test(voice_agg$ir_cr_mean_Active, voice_agg$ir_cr_mean_Passive,
                      paired = TRUE, exact = FALSE)
.stat_lines <<- c(.stat_lines, capture.output(print(wsr_ir)))
print(wsr_ir)

# rank-biserial r: wilcox_effsize(paired=TRUE)
voice_ir_long <- voice_agg %>%
    select(participant_id, starts_with("ir_cr_mean_")) %>%
    pivot_longer(cols = -participant_id, names_to = "voice", names_prefix = "ir_cr_mean_", values_to = "ir_cr")
r_ir_res <- wilcox_effsize(voice_ir_long, ir_cr ~ voice, paired = TRUE)

.log(
    sprintf("  Active M = %.4f | Passive M = %.4f",
            mean(voice_agg$ir_cr_mean_Active, na.rm = TRUE),
            mean(voice_agg$ir_cr_mean_Passive, na.rm = TRUE)),
    sprintf("  rank-biserial r = %.4f", r_ir_res$effsize)
)

# WR Accuracy: Active vs Passive
.log(
    "\n================================================================",
    "Paired Wilcoxon: WR Accuracy — Active vs Passive (collapsed)",
    "================================================================"
)
wsr_wr <- wilcox.test(voice_agg$wr_acc_mean_Active, voice_agg$wr_acc_mean_Passive,
                      paired = TRUE, exact = FALSE)
.stat_lines <<- c(.stat_lines, capture.output(print(wsr_wr)))
print(wsr_wr)

voice_wr_long <- voice_agg %>%
    select(participant_id, starts_with("wr_acc_mean_")) %>%
    pivot_longer(cols = -participant_id, names_to = "voice", names_prefix = "wr_acc_mean_", values_to = "wr_acc")
r_wr_res <- wilcox_effsize(voice_wr_long, wr_acc ~ voice, paired = TRUE)

.log(
    sprintf("  Active M = %.4f | Passive M = %.4f",
            mean(voice_agg$wr_acc_mean_Active, na.rm = TRUE),
            mean(voice_agg$wr_acc_mean_Passive, na.rm = TRUE)),
    sprintf("  rank-biserial r = %.4f", r_wr_res$effsize)
)

# ── F6b: Group-Wise Voice Tests — Per Noun Condition ────────────────────────
# Group-wise: test Active vs. Passive separately within each noun condition.
# This characterises whether the voice effect is consistent across conditions,
# complementing the SRH interaction test. Uses paired Wilcoxon signed-rank.
cat("\n  --- Group-Wise Voice Effect: Per Noun Condition (F6b) ---\n")

.log(
    "\n================================================================",
    "GROUP-WISE VOICE TEST (F6b): Active vs Passive within each condition",
    "(Paired Wilcoxon signed-rank; same participants in both voice levels)",
    "================================================================"
)

for (cond in levels(cr_scores$noun_condition)) {

    sub_wide <- cr_scores %>%
        filter(noun_condition == cond) %>%
        select(participant_id, voice, ir_cr, wr_acc_score) %>%
        pivot_wider(names_from = voice, values_from = c(ir_cr, wr_acc_score))

    .log(sprintf("\n  --- Condition: %s ---", cond))

    for (metric_label in list(
            list(active = "ir_cr_Active",  passive = "ir_cr_Passive",  name = "IR CR"),
            list(active = "wr_acc_score_Active", passive = "wr_acc_score_Passive", name = "WR Acc")
        )) {

        active_col  <- metric_label$active
        passive_col <- metric_label$passive
        metric_name <- metric_label$name

        if (!active_col  %in% names(sub_wide) ||
            !passive_col %in% names(sub_wide)) next

        v_active  <- sub_wide[[active_col]]
        v_passive <- sub_wide[[passive_col]]

        complete_pairs <- !is.na(v_active) & !is.na(v_passive)
        if (sum(complete_pairs) < 3) {
            .log(sprintf("    %s [%s]: insufficient complete pairs (%d). Skipped.",
                         metric_name, cond, sum(complete_pairs)))
            next
        }

        wt <- wilcox.test(v_active[complete_pairs], v_passive[complete_pairs],
                          paired = TRUE, exact = FALSE)

        N_c <- sum(complete_pairs)
        sub_metric <- sub_wide[complete_pairs, ] %>%
            select(participant_id, all_of(c(active_col, passive_col))) %>%
            pivot_longer(cols = -participant_id, names_to = "voice", values_to = "val")
        r_c_res <- wilcox_effsize(sub_metric, val ~ voice, paired = TRUE)
        r_c <- r_c_res$effsize

        sig_flag <- if (wt$p.value < 0.05) " *" else ""
        .log(sprintf(
            "    %s [%s]: V = %.0f, p = %.4f%s, r = %.3f (N pairs = %d)",
            metric_name, cond, wt$statistic, wt$p.value, sig_flag, r_c, N_c
        ))
    }
}

# ── F7: One-Sample Wilcoxon — WR vs Chance + Rank-Biserial r ────────────────
# Already correct in original (one-sample signed-rank, mu = 0.5).
# F7 adds the missing rank-biserial r (class 12.pdf).
cat("\n  --- WR vs Chance: One-Sample Wilcoxon (F7) ---\n")

N_parts <- length(unique(cr_scores$participant_id))

.log(
    "\n================================================================",
    "One-Sample Wilcoxon: WR Accuracy — Active voice vs chance (0.5)",
    "================================================================"
)
wr_active_test <- wilcox.test(voice_agg$wr_acc_mean_Active,
                               mu = 0.5, alternative = "greater")
.stat_lines <<- c(.stat_lines, capture.output(print(wr_active_test)))
print(wr_active_test)
Z_ca <- qnorm(wr_active_test$p.value)   # one-sided p
r_ca <- abs(Z_ca) / sqrt(N_parts)
.log(sprintf("  rank-biserial r (Active vs chance) = %.4f", r_ca))

.log(
    "\n================================================================",
    "One-Sample Wilcoxon: WR Accuracy — Passive voice vs chance (0.5)",
    "================================================================"
)
wr_passive_test <- wilcox.test(voice_agg$wr_acc_mean_Passive,
                                mu = 0.5, alternative = "greater")
.stat_lines <<- c(.stat_lines, capture.output(print(wr_passive_test)))
print(wr_passive_test)
Z_cp <- qnorm(wr_passive_test$p.value)
r_cp <- abs(Z_cp) / sqrt(N_parts)
.log(sprintf("  rank-biserial r (Passive vs chance) = %.4f", r_cp))

# ── Save statistical_tests.txt ───────────────────────────────────────────────
if (exists("stat_dir")) {
    writeLines(.stat_lines, file.path(stat_dir, "statistical_tests.txt"))
    cat(sprintf("\n  Saved -> %s/statistical_tests.txt\n", stat_dir))
}

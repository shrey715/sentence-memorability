# 06b_results_plots.R
# Generates all result visualizations for Report 1.
#
# Plot naming convention:
#   01_ir_cr_by_condition.png       - IR CR raincloud by noun condition
#   02_wr_acc_by_condition.png      - WR accuracy raincloud by noun condition
#   03_ir_cr_condition_x_voice.png  - IR CR interaction (condition x voice)
#   04_wr_acc_condition_x_voice.png - WR accuracy interaction (condition x voice)
#   05_ir_rt_by_condition.png       - IR RT raincloud by noun condition
#   06_qq_ir_cr.png                 - Q-Q plot for IR CR (normality check)
#   07_qq_ir_rt.png                 - Q-Q plot for IR RT (normality check)
#   08_ir_cr_by_voice.png           - IR CR raincloud by voice
#   09_wr_acc_by_voice.png          - WR accuracy raincloud by voice
#
# Inputs:  data/processed/cr_scores.csv
# Outputs: outputs/plots/01-09_*.png

cat("\n[06b_results_plots] Generating result visualizations...\n")

suppressPackageStartupMessages({
    library(dplyr)
    library(ggplot2)
    library(ggdist)
    library(tidyr)
})

cr_scores <- read.csv("data/processed/cr_scores.csv") %>%
    filter(noun_condition %in% c("HH", "HL", "LH", "LL"))
cr_scores$noun_condition <- factor(cr_scores$noun_condition,
    levels = c("HH", "HL", "LH", "LL")
)
dir.create("outputs/plots", showWarnings = FALSE, recursive = TRUE)

cat(sprintf("  Input : %d rows | conditions : HH, HL, LH, LL\n", nrow(cr_scores)))

# ── Shared aesthetics and helpers ────────────────────────────────────────────
# palette_cond  : colorblind-friendly colors for the 4 noun conditions
# cond_labels   : human-readable labels used in plot legends/facets
# theme_pub     : minimal ggplot2 theme applied to all result plots
# save_plot()   : wrapper that calls ggsave and prints the saved path
palette_cond <- c(HH = "#E69F00", HL = "#56B4E9", LH = "#009E73", LL = "#CC79A7")
cond_labels <- c(
    HH = "HH (High-High)", HL = "HL (High-Low)",
    LH = "LH (Low-High)", LL = "LL (Low-Low)"
)
theme_pub <- theme_minimal(base_size = 13) +
    theme(legend.position = "top", plot.title = element_text(face = "bold"))

save_plot <- function(path, width = 8, height = 6) {
    ggsave(path, width = width, height = height, dpi = 200)
    cat(sprintf("  Saved -> %s\n", path))
}

# ── Plot 01: IR CR by Condition (Raincloud) ──────────────────────────────────
cat("  [1/7] IR CR by condition (raincloud)...\n")
# Does noun memorability condition affect how well sentences are recognized? (IR CR)
ggplot(cr_scores, aes(x = noun_condition, y = ir_cr, fill = noun_condition)) +
    stat_halfeye(
        adjust = 0.6, width = 0.5, justification = -0.3,
        point_colour = NA, .width = 0, na.rm = TRUE
    ) +
    geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.5, na.rm = TRUE) +
    geom_point(
        position = position_jitter(width = 0.08, seed = 42),
        size = 1.2, alpha = 0.25, na.rm = TRUE
    ) +
    scale_fill_manual(
        values = palette_cond, name = "Noun Condition",
        labels = cond_labels
    ) +
    labs(
        title = "Corrected IR Scores by Noun Condition",
        x = "Noun Condition", y = "Corrected IR Score"
    ) +
    theme_pub
save_plot("outputs/plots/01_ir_cr_by_condition.png")

# ── Plot 02: WR Accuracy by Condition (Raincloud) ───────────────────────────
cat("  [2/7] WR accuracy by condition (raincloud)...\n")
# Does noun memorability affect wording recognition accuracy?
ggplot(cr_scores, aes(x = noun_condition, y = wr_acc_score, fill = noun_condition)) +
    stat_halfeye(
        adjust = 0.6, width = 0.5, justification = -0.3,
        point_colour = NA, .width = 0, na.rm = TRUE
    ) +
    geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.5, na.rm = TRUE) +
    geom_point(
        position = position_jitter(width = 0.08, seed = 42),
        size = 1.2, alpha = 0.25, na.rm = TRUE
    ) +
    geom_hline(yintercept = 0.5, linetype = "dotted", colour = "gray40") +
    scale_fill_manual(
        values = palette_cond, name = "Noun Condition",
        labels = cond_labels
    ) +
    labs(
        title = "Wording Recognition Accuracy by Noun Condition",
        x = "Noun Condition", y = "WR Accuracy"
    ) +
    theme_pub
save_plot("outputs/plots/02_wr_acc_by_condition.png")

# ── Plot 03: IR CR Condition x Voice (Interaction) ──────────────────────────
cat("  [3/7] IR CR condition x voice (interaction bar plot)...\n")
# Aggregate to condition x voice means ± SE for the interaction bar chart
ir_voice_summary <- cr_scores %>%
    group_by(noun_condition, voice) %>%
    summarise(
        mean_ir = mean(ir_cr, na.rm = TRUE),
        se_ir = sd(ir_cr, na.rm = TRUE) / sqrt(sum(!is.na(ir_cr))),
        .groups = "drop"
    )

# Is the noun condition effect modulated by grammatical voice? (IR CR interaction)
ggplot(ir_voice_summary, aes(x = noun_condition, y = mean_ir, fill = voice)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6, colour = "gray30") +
    geom_errorbar(aes(ymin = mean_ir - se_ir, ymax = mean_ir + se_ir),
        position = position_dodge(width = 0.7), width = 0.2
    ) +
    scale_fill_manual(
        values = c(Active = "#0072B2", Passive = "#D55E00"),
        name = "Voice"
    ) +
    labs(
        title = "Corrected IR: Noun Condition x Voice",
        x = "Noun Condition", y = "Mean Corrected IR (+/- 1 SE)"
    ) +
    theme_pub
save_plot("outputs/plots/03_ir_cr_condition_x_voice.png")

# ── Plot 04: WR Accuracy Condition x Voice (Interaction) ────────────────────
cat("  [4/7] WR accuracy condition x voice (interaction bar plot)...\n")
wr_voice_summary <- cr_scores %>%
    group_by(noun_condition, voice) %>%
    summarise(
        mean_wr = mean(wr_acc_score, na.rm = TRUE),
        se_wr = sd(wr_acc_score, na.rm = TRUE) / sqrt(sum(!is.na(wr_acc_score))),
        .groups = "drop"
    )

# Same interaction for wording recognition accuracy
ggplot(wr_voice_summary, aes(x = noun_condition, y = mean_wr, fill = voice)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6, colour = "gray30") +
    geom_errorbar(aes(ymin = mean_wr - se_wr, ymax = mean_wr + se_wr),
        position = position_dodge(width = 0.7), width = 0.2
    ) +
    geom_hline(yintercept = 0.5, linetype = "dotted", colour = "gray40") +
    scale_fill_manual(
        values = c(Active = "#0072B2", Passive = "#D55E00"),
        name = "Voice"
    ) +
    labs(
        title = "WR Accuracy: Noun Condition x Voice",
        x = "Noun Condition", y = "Mean WR Accuracy (+/- 1 SE)"
    ) +
    theme_pub
save_plot("outputs/plots/04_wr_acc_condition_x_voice.png")

# ── Plot 05: IR RT by Condition (Raincloud) ─────────────────────────────────
cat("  [5/7] IR RT by condition (raincloud)...\n")# Does noun memorability affect how quickly participants recognize sentences? (RT)ggplot(cr_scores, aes(x = noun_condition, y = ir_rt, fill = noun_condition)) +
    stat_halfeye(
        adjust = 0.6, width = 0.5, justification = -0.3,
        point_colour = NA, .width = 0, na.rm = TRUE
    ) +
    geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.5, na.rm = TRUE) +
    geom_point(
        position = position_jitter(width = 0.08, seed = 42),
        size = 1.2, alpha = 0.25, na.rm = TRUE
    ) +
    scale_fill_manual(
        values = palette_cond, name = "Noun Condition",
        labels = cond_labels
    ) +
    labs(
        title = "IR Reaction Time by Noun Condition",
        x = "Noun Condition", y = "IR Reaction Time (ms)"
    ) +
    theme_pub
save_plot("outputs/plots/05_ir_rt_by_condition.png")

# ── Plot 06: Q-Q IR CR ──────────────────────────────────────────────────────
cat("  [6/7] Q-Q plot for IR CR...\n")# Q-Q diagnostic: does IR CR follow a normal distribution? (justifies non-parametric tests)ggplot(cr_scores, aes(sample = ir_cr)) +
    stat_qq(na.rm = TRUE, alpha = 0.4, colour = "gray40") +
    stat_qq_line(na.rm = TRUE, linewidth = 0.7, colour = "black", linetype = "dashed") +
    facet_wrap(~noun_condition, labeller = labeller(noun_condition = cond_labels)) +
    labs(
        title = "Q-Q Plot: Corrected IR Scores by Noun Condition",
        subtitle = "Dashed line = theoretical normal; deviation indicates non-normality",
        x = "Theoretical quantiles", y = "Sample quantiles"
    ) +
    theme_pub
save_plot("outputs/plots/06_qq_ir_cr.png")

# ── Plot 07: Q-Q IR RT ──────────────────────────────────────────────────────
cat("  [7/7] Q-Q plot for IR RT...\n")# Q-Q diagnostic: same check for IR reaction timeggplot(cr_scores, aes(sample = ir_rt)) +
    stat_qq(na.rm = TRUE, alpha = 0.4, colour = "gray40") +
    stat_qq_line(na.rm = TRUE, linewidth = 0.7, colour = "black", linetype = "dashed") +
    facet_wrap(~noun_condition, labeller = labeller(noun_condition = cond_labels)) +
    labs(
        title = "Q-Q Plot: IR Reaction Times by Noun Condition",
        subtitle = "Dashed line = theoretical normal; deviation indicates non-normality",
        x = "Theoretical quantiles", y = "Sample quantiles"
    ) +
    theme_pub
save_plot("outputs/plots/07_qq_ir_rt.png")

# ── Plot 08: IR CR by Voice (Raincloud) ──────────────────────────────────────
cat("  [8/9] IR CR by voice (main effect raincloud)...\n")
ggplot(cr_scores, aes(x = voice, y = ir_cr, fill = voice)) +
    stat_halfeye(
        adjust = 0.6, width = 0.5, justification = -0.3,
        point_colour = NA, .width = 0, na.rm = TRUE
    ) +
    geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.5, na.rm = TRUE) +
    geom_point(
        position = position_jitter(width = 0.08, seed = 42),
        size = 1.2, alpha = 0.15, na.rm = TRUE
    ) +
    scale_fill_manual(
        values = c(Active = "#0072B2", Passive = "#D55E00"),
        name = "Voice"
    ) +
    labs(
        title = "Corrected IR Scores by Grammatical Voice",
        x = "Voice", y = "Corrected IR Score"
    ) +
    theme_pub
save_plot("outputs/plots/08_ir_cr_by_voice.png")

# ── Plot 09: WR Accuracy by Voice (Raincloud) ───────────────────────────────
cat("  [9/9] WR accuracy by voice (main effect raincloud)...\n")# Main effect of voice on wording recognition accuracyggplot(cr_scores, aes(x = voice, y = wr_acc_score, fill = voice)) +
    stat_halfeye(
        adjust = 0.6, width = 0.5, justification = -0.3,
        point_colour = NA, .width = 0, na.rm = TRUE
    ) +
    geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.5, na.rm = TRUE) +
    geom_point(
        position = position_jitter(width = 0.08, seed = 42),
        size = 1.2, alpha = 0.15, na.rm = TRUE
    ) +
    geom_hline(yintercept = 0.5, linetype = "dotted", colour = "gray40") +
    scale_fill_manual(
        values = c(Active = "#0072B2", Passive = "#D55E00"),
        name = "Voice"
    ) +
    labs(
        title = "Wording Recognition Accuracy by Grammatical Voice",
        x = "Voice", y = "WR Accuracy"
    ) +
    theme_pub
save_plot("outputs/plots/09_wr_acc_by_voice.png")

# ── Plot 10: Within-Participant Voice Differences ──────────────────────────
cat("  [10/10] Voice difference distribution plot...\n")

# Compute per-participant Active − Passive difference for each metric
voice_diff <- cr_scores %>%
    group_by(participant_id, voice) %>%
    summarise(
        ir_cr_mean = mean(ir_cr, na.rm = TRUE),
        wr_acc_mean = mean(wr_acc_score, na.rm = TRUE),
        .groups = "drop"
    ) %>%
    tidyr::pivot_wider(names_from = voice, values_from = c(ir_cr_mean, wr_acc_mean)) %>%
    dplyr::transmute(
        participant_id,
        `Corrected IR`  = ir_cr_mean_Active - ir_cr_mean_Passive,
        `WR Accuracy`   = wr_acc_mean_Active - wr_acc_mean_Passive
    ) %>%
    tidyr::pivot_longer(
        cols = c(`Corrected IR`, `WR Accuracy`),
        names_to = "metric", values_to = "diff"
    )

# Distribution of within-participant voice differences - centred near 0 means no systematic voice bias
ggplot(voice_diff, aes(x = diff)) +
    geom_histogram(aes(y = after_stat(density)),
        bins = 25,
        fill = "#56B4E9", colour = "white", alpha = 0.8
    ) +
    geom_density(colour = "#0072B2", linewidth = 0.9) +
    geom_vline(xintercept = 0, linetype = "dashed", colour = "black", linewidth = 0.8) +
    facet_wrap(~metric, scales = "free") +
    labs(
        title = "Voice Effect: Active \u2212 Passive (per participant)",
        subtitle = "Dashed line = zero; centred distribution indicates no systematic voice bias",
        x = "Difference (Active \u2212 Passive)", y = "Density"
    ) +
    theme_pub
save_plot("outputs/plots/10_voice_paired_dots.png", width = 8, height = 4)

cat("  All plots saved to outputs/plots/\n")

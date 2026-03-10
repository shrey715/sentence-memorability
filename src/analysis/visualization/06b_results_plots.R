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
#
# Inputs:  data/processed/cr_scores.csv
# Outputs: outputs/plots/01-07_*.png

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

# ── Shared theme and palette ─────────────────────────────────────────────────
palette_cond <- c(HH = "#1A9641", HL = "#A6D96A", LH = "#FDAE61", LL = "#D7191C")
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
ir_voice_summary <- cr_scores %>%
    group_by(noun_condition, voice) %>%
    summarise(
        mean_ir = mean(ir_cr, na.rm = TRUE),
        se_ir = sd(ir_cr, na.rm = TRUE) / sqrt(sum(!is.na(ir_cr))),
        .groups = "drop"
    )

ggplot(ir_voice_summary, aes(x = noun_condition, y = mean_ir, fill = voice)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6, colour = "gray30") +
    geom_errorbar(aes(ymin = mean_ir - se_ir, ymax = mean_ir + se_ir),
        position = position_dodge(width = 0.7), width = 0.2
    ) +
    scale_fill_manual(
        values = c(Active = "gray30", Passive = "gray75"),
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

ggplot(wr_voice_summary, aes(x = noun_condition, y = mean_wr, fill = voice)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6, colour = "gray30") +
    geom_errorbar(aes(ymin = mean_wr - se_wr, ymax = mean_wr + se_wr),
        position = position_dodge(width = 0.7), width = 0.2
    ) +
    geom_hline(yintercept = 0.5, linetype = "dotted", colour = "gray40") +
    scale_fill_manual(
        values = c(Active = "gray30", Passive = "gray75"),
        name = "Voice"
    ) +
    labs(
        title = "WR Accuracy: Noun Condition x Voice",
        x = "Noun Condition", y = "Mean WR Accuracy (+/- 1 SE)"
    ) +
    theme_pub
save_plot("outputs/plots/04_wr_acc_condition_x_voice.png")

# ── Plot 05: IR RT by Condition (Raincloud) ─────────────────────────────────
cat("  [5/7] IR RT by condition (raincloud)...\n")
ggplot(cr_scores, aes(x = noun_condition, y = ir_rt, fill = noun_condition)) +
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
cat("  [6/7] Q-Q plot for IR CR...\n")
ggplot(cr_scores, aes(sample = ir_cr)) +
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
cat("  [7/7] Q-Q plot for IR RT...\n")
ggplot(cr_scores, aes(sample = ir_rt)) +
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

# ── Plot manifest ────────────────────────────────────────────────────────────
if (exists("stat_dir")) {
    manifest <- c(
        "Generated Plots Manifest", "========================",
        sprintf("Timestamp : %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
        "",
        "01_ir_cr_by_condition.png       | IR CR raincloud by noun condition",
        "02_wr_acc_by_condition.png      | WR accuracy raincloud by noun condition",
        "03_ir_cr_condition_x_voice.png  | IR CR interaction (condition x voice)",
        "04_wr_acc_condition_x_voice.png | WR accuracy interaction (condition x voice)",
        "05_ir_rt_by_condition.png       | IR RT raincloud by noun condition",
        "06_qq_ir_cr.png                 | Q-Q plot for IR CR (normality check)",
        "07_qq_ir_rt.png                 | Q-Q plot for IR RT (normality check)"
    )
    writeLines(manifest, file.path(stat_dir, "plots_manifest.txt"))
    cat(sprintf("  Saved -> %s/plots_manifest.txt\n", stat_dir))
}

cat("  All plots saved to outputs/plots/\n")

# src/block_learning/03_block_plots.R
# Visualizations for the block-level learning analysis.
#
# All plots mirror the visual style of 06b_results_plots.R
# (same theme_pub, palette, stat_halfeye raincloud pattern).
#
# Plot 01: Corrected IR by Block — raincloud (pure block main effect)
# Plot 02: Corrected IR — Condition × Block line plot (interaction)
# Plot 03: WR Accuracy by Block — raincloud
# Plot 04: IR Reaction Time by Block — raincloud
#
# Input:  data/processed/block_scores.csv
# Output: outputs/block_learning/01-04_*.png

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(ggdist)
})

cat("\n[block_learning/03] Generating block-level visualizations...\n")

bs <- read.csv("data/processed/block_scores.csv", stringsAsFactors = FALSE) %>%
  mutate(
    block_id       = factor(block_id,       levels = c("Block 1", "Block 2", "Block 3")),
    noun_condition = factor(noun_condition, levels = c("HH", "HL", "LH", "LL"))
  )

dir.create("outputs/block_learning", showWarnings = FALSE, recursive = TRUE)

# ── Shared aesthetics (mirrors 06b_results_plots.R) ───────────────────────────
palette_block <- c("Block 1" = "#56B4E9", "Block 2" = "#E69F00", "Block 3" = "#009E73")
palette_cond  <- c(HH = "#E69F00", HL = "#56B4E9", LH = "#009E73", LL = "#CC79A7")
cond_labels   <- c(HH = "HH (High-High)", HL = "HL (High-Low)",
                   LH = "LH (Low-High)",  LL = "LL (Low-Low)")

theme_pub <- theme_minimal(base_size = 13) +
  theme(legend.position = "top", plot.title = element_text(face = "bold"))

save_plot <- function(path, w = 8, h = 6) {
  ggsave(path, width = w, height = h, dpi = 200)
  cat(sprintf("  Saved -> %s\n", path))
}

# ── Plot 01: Corrected IR by Block (Raincloud) ────────────────────────────────
# Collapses across noun condition — isolates the pure block (learning/fatigue) effect.
cat("  [1/4] Corrected IR by block (raincloud)...\n")

bs_collapsed <- bs %>%
  group_by(participant_id, block_id) %>%
  summarise(corrected_ir = mean(corrected_ir, na.rm = TRUE), .groups = "drop")

ggplot(bs_collapsed, aes(x = block_id, y = corrected_ir, fill = block_id)) +
  stat_halfeye(
    adjust = 0.6, width = 0.5, justification = -0.3,
    point_colour = NA, .width = 0, na.rm = TRUE
  ) +
  geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.5, na.rm = TRUE) +
  geom_point(
    position = position_jitter(width = 0.08, seed = 42),
    size = 1.2, alpha = 0.25, na.rm = TRUE
  ) +
  scale_fill_manual(values = palette_block, guide = "none") +
  labs(
    title    = "Corrected IR Across Experimental Blocks",
    subtitle = "Does overall recognition discriminability improve with exposure?",
    x = "Block", y = "Mean Corrected IR"
  ) +
  theme_pub
save_plot("outputs/block_learning/01_ir_by_block.png")

# ── Plot 02: Corrected IR — Condition × Block (Line Plot) ────────────────────
# Shows whether the LL deficit persists, shrinks, or widens over time.
# Error bars = ±1 SE (matches the interaction plots in 06b).
cat("  [2/4] Corrected IR condition × block (interaction line plot)...\n")

bs_summary <- bs %>%
  group_by(noun_condition, block_id) %>%
  summarise(
    mean_ir = mean(corrected_ir, na.rm = TRUE),
    se_ir   = sd(corrected_ir,  na.rm = TRUE) / sqrt(sum(!is.na(corrected_ir))),
    .groups = "drop"
  )

ggplot(bs_summary, aes(x = block_id, y = mean_ir,
                        colour = noun_condition, group = noun_condition)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_errorbar(aes(ymin = mean_ir - se_ir, ymax = mean_ir + se_ir), width = 0.12) +
  scale_colour_manual(values = palette_cond, name = "Noun Condition",
                      labels = cond_labels) +
  labs(
    title    = "Corrected IR by Condition Across Blocks",
    subtitle = "Does the LL deficit persist, shrink, or widen over time?",
    x = "Block", y = "Mean Corrected IR (±1 SE)"
  ) +
  theme_pub
save_plot("outputs/block_learning/02_ir_condition_x_block.png")

# ── Plot 03: WR Accuracy by Block (Raincloud) ─────────────────────────────────
# Wording memory should remain flat if gist and wording are dissociated.
cat("  [3/4] WR accuracy by block (raincloud)...\n")

bs_wr <- bs %>%
  group_by(participant_id, block_id) %>%
  summarise(wr_acc = mean(wr_acc, na.rm = TRUE), .groups = "drop")

ggplot(bs_wr, aes(x = block_id, y = wr_acc, fill = block_id)) +
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
  scale_fill_manual(values = palette_block, guide = "none") +
  labs(
    title    = "WR Accuracy Across Blocks",
    subtitle = "Wording memory should remain flat if gist and wording are dissociated",
    x = "Block", y = "WR Accuracy"
  ) +
  theme_pub
save_plot("outputs/block_learning/03_wr_by_block.png")

# ── Plot 04: Reaction Time by Block (Raincloud) ───────────────────────────────
# A speed-up across blocks would indicate familiarity/learning effects on RT.
cat("  [4/4] Reaction time by block (raincloud)...\n")

bs_rt <- bs %>%
  group_by(participant_id, block_id) %>%
  summarise(mean_rt = mean(mean_rt, na.rm = TRUE), .groups = "drop")

ggplot(bs_rt, aes(x = block_id, y = mean_rt, fill = block_id)) +
  stat_halfeye(
    adjust = 0.6, width = 0.5, justification = -0.3,
    point_colour = NA, .width = 0, na.rm = TRUE
  ) +
  geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.5, na.rm = TRUE) +
  geom_point(
    position = position_jitter(width = 0.08, seed = 42),
    size = 1.2, alpha = 0.25, na.rm = TRUE
  ) +
  scale_fill_manual(values = palette_block, guide = "none") +
  labs(
    title    = "IR Reaction Time Across Blocks",
    subtitle = "Speed-up across blocks would indicate familiarity/learning on RT",
    x = "Block", y = "Mean RT (ms)"
  ) +
  theme_pub
save_plot("outputs/block_learning/04_rt_by_block.png")

cat("  All plots saved to outputs/block_learning/\n")

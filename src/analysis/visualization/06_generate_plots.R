cat("\n[06_generate_plots] Generating publication-quality visualizations...\n")

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(ggdist)
})

cr_scores <- read.csv("data/processed/cr_scores.csv") %>% filter(noun_condition %in% c("HH", "HL", "LH", "LL"))
cr_scores$noun_condition <- factor(cr_scores$noun_condition, levels = c("HH", "HL", "LH", "LL"))
dir.create("outputs/plots", showWarnings = FALSE, recursive = TRUE)

cat(sprintf("  Input : %d rows | conditions : HH, HL, LH, LL\n", nrow(cr_scores)))

palette_condition <- c(HH = "#6C5CE7", HL = "#00B894", LH = "#FDCB6E", LL = "#E17055")
theme_pub <- theme_minimal(base_size=13) + theme(legend.position="top", plot.title=element_text(face="bold"))

.save_plot <- function(path, width, height) {
  ggsave(path, width=width, height=height, dpi=200)
  cat(sprintf("  Saved -> %s  [%g x %g in, 200 dpi]\n", path, width, height))
}

# Plot 1: IR CR Raincloud
cat("  [1/3] IR CR by condition (Raincloud)...\n")
ggplot(cr_scores, aes(x = noun_condition, y = ir_cr, fill = noun_condition)) +
  stat_halfeye(adjust = 0.6, width = 0.5, justification = -0.3, point_colour = NA, .width = 0, na.rm = TRUE) +
  geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.5, na.rm = TRUE) +
  geom_point(position = position_jitter(width = 0.08, seed = 42), size = 1.2, alpha = 0.25, na.rm = TRUE) +
  scale_fill_manual(values = palette_condition) +
  labs(title = "Immediate Recognition (IR) Corrected Scores",
       x = "Noun Condition", y = "IR Corrected Recognition Score", fill = "Condition") +
  theme_pub
.save_plot("outputs/plots/01_ir_by_condition_raincloud.png", 9, 6)

# Plot 2: WR Accuracy Raincloud
cat("  [2/3] WR conditional accuracy by condition (Raincloud)...\n")
ggplot(cr_scores, aes(x = noun_condition, y = wr_acc_score, fill = noun_condition)) +
  stat_halfeye(adjust = 0.6, width = 0.5, justification = -0.3, point_colour = NA, .width = 0, na.rm = TRUE) +
  geom_boxplot(width = 0.12, outlier.shape = NA, alpha = 0.5, na.rm = TRUE) +
  geom_point(position = position_jitter(width = 0.08, seed = 42), size = 1.2, alpha = 0.25, na.rm = TRUE) +
  scale_fill_manual(values = palette_condition) +
  labs(title = "Wording Recognition (WR) Conditional Accuracy",
       x = "Noun Condition", y = "WR Accuracy (proportion correct)", fill = "Condition") +
  theme_pub
.save_plot("outputs/plots/02_wr_accuracy_raincloud.png", 9, 6)

# Plot 3: Q-Q for IR RT
cat("  [3/3] Q-Q plot for IR reaction times...\n")
ggplot(cr_scores, aes(sample = ir_rt)) +
  stat_qq(na.rm = TRUE, alpha=0.4) +
  stat_qq_line(colour="firebrick", na.rm = TRUE) +
  facet_wrap(~noun_condition) +
  labs(title="Q-Q Plot: Non-normal Reaction Times",
       subtitle="Deviation from line indicates non-normality") +
  theme_pub
.save_plot("outputs/plots/07_qq_ir_rt.png", 8, 7)

# Log plot manifest to outputs/stats/
if (exists("stat_dir")) {
  plot_manifest <- c(
    "Generated Plots Manifest", "========================",
    sprintf("Timestamp : %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    "",
    "01_ir_by_condition_raincloud.png  | IR CR Raincloud by noun condition (9x6in, 200dpi)",
    "02_wr_accuracy_raincloud.png      | WR conditional accuracy Raincloud (9x6in, 200dpi)",
    "07_qq_ir_rt.png                   | Q-Q plot for IR reaction times (8x7in, 200dpi)"
  )
  writeLines(plot_manifest, file.path(stat_dir, "plots_manifest.txt"))
  cat(sprintf("  Saved -> %s/plots_manifest.txt\n", stat_dir))
}

cat("  All plots saved to outputs/plots/\n")

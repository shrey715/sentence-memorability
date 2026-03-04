# ── viz.R ─────────────────────────────────────────────────────────────────────
# Publication-quality visualisations for the Sentence Memorability study.
# Uses final_data.csv (all rows from validated blocks).
#
# Key design:
#   - ir_corrected_recognition / wr_corrected_recognition are NA in the file
#   - We compute hit rates and false-alarm rates from ir_accuracy / wr_accuracy
#   - Analysis is restricted to target probe sentences (Sentence shown events)
# ──────────────────────────────────────────────────────────────────────────────

# ── Libraries ─────────────────────────────────────────────────────────────────

library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

# ── Aesthetic constants ───────────────────────────────────────────────────────

palette_condition <- c(
  "HH" = "#6C5CE7",
  "HL" = "#00B894",
  "LH" = "#FDCB6E",
  "LL" = "#E17055"
)

palette_voice <- c(
  "Active"  = "#0984E3",
  "Passive" = "#D63031"
)

palette_8 <- c(
  "HH · Active"  = "#6C5CE7", "HH · Passive" = "#A29BFE",
  "HL · Active"  = "#00B894", "HL · Passive" = "#55EFC4",
  "LH · Active"  = "#FDCB6E", "LH · Passive" = "#FFEAA7",
  "LL · Active"  = "#E17055", "LL · Passive" = "#FAB1A0"
)

# A clean, modern ggplot2 theme
theme_memo <- function(base_size = 13) {
  theme_minimal(base_size = base_size) %+replace%
    theme(
      text              = element_text(family = "sans", colour = "#2D3436"),
      plot.title        = element_text(face = "bold", size = rel(1.25),
                                       hjust = 0, margin = margin(b = 8)),
      plot.subtitle     = element_text(size = rel(0.9), colour = "#636E72",
                                       hjust = 0, margin = margin(b = 12)),
      plot.caption      = element_text(size = rel(0.7), colour = "#B2BEC3",
                                       hjust = 1, margin = margin(t = 10)),
      axis.title        = element_text(size = rel(0.95), face = "bold"),
      axis.text         = element_text(size = rel(0.85), colour = "#636E72"),
      legend.position   = "top",
      legend.title      = element_text(face = "bold", size = rel(0.85)),
      legend.text       = element_text(size = rel(0.8)),
      panel.grid.major  = element_line(colour = "#DFE6E9", linewidth = 0.3),
      panel.grid.minor  = element_blank(),
      strip.text        = element_text(face = "bold", size = rel(0.9)),
      plot.background   = element_rect(fill = "#FAFAFA", colour = NA),
      panel.background  = element_rect(fill = "#FAFAFA", colour = NA),
      plot.margin       = margin(15, 15, 15, 15)
    )
}

# ── Load data ─────────────────────────────────────────────────────────────────

df <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)

# Parse stimulus_id → noun_condition + voice
# Data codes: HH, HVL→HL, LVH→LH, LVL→LL, HF→filler
df <- df |>
  mutate(
    stim_prefix = str_extract(stimulus_id, "^[A-Z]+"),
    voice_code  = str_extract(stimulus_id, "[AP]$"),
    noun_condition = case_when(
      stim_prefix == "HH"  ~ "HH",
      stim_prefix == "HVL" ~ "HL",
      stim_prefix == "LVH" ~ "LH",
      stim_prefix == "LVL" ~ "LL",
      TRUE                 ~ NA_character_
    ),
    voice = case_when(
      voice_code == "A" ~ "Active",
      voice_code == "P" ~ "Passive",
      TRUE              ~ NA_character_
    )
  )

# ── Build analysis-ready datasets ────────────────────────────────────────────

# Target probe events: the moment a repeated target sentence is shown
# This is where recognition happens
probes_shown <- df |>
  filter(
    event_type == "Sentence shown",
    is_target_sentence == TRUE,
    is_probe_repeat == TRUE,
    !is.na(noun_condition)
  )

# IR presses on target probes (hits)
ir_hits <- df |>
  filter(
    event_type == "IR pressed",
    is_target_sentence == TRUE,
    is_probe_repeat == TRUE,
    !is.na(noun_condition)
  )

# IR presses on non-target non-repeat (false alarms)
ir_false_alarms <- df |>
  filter(
    event_type == "IR pressed",
    is_target_sentence == FALSE,
    is_probe_repeat == FALSE
  )

# WR presses on target probes
wr_presses <- df |>
  filter(
    event_type == "WR pressed",
    is_target_sentence == TRUE,
    is_probe_repeat == TRUE,
    !is.na(noun_condition)
  )

cat(sprintf("Target probe Sentence shown: %d | IR hits: %d | WR presses: %d\n",
            nrow(probes_shown), nrow(ir_hits), nrow(wr_presses)))

# ── Compute per-participant hit rates and FA rates ───────────────────────────

# Hit rate per participant × condition × voice
hit_rates <- probes_shown |>
  left_join(
    ir_hits |>
      select(participant_id, stimulus_id, block_id,
             ir_accuracy, ir_reaction_time_ms) |>
      rename(ir_hit = ir_accuracy, ir_rt = ir_reaction_time_ms),
    by = c("participant_id", "stimulus_id", "block_id")
  ) |>
  mutate(ir_hit = ifelse(is.na(ir_hit), 0L, ir_hit))  # miss = 0

# Join WR info
hit_rates <- hit_rates |>
  left_join(
    wr_presses |>
      select(participant_id, stimulus_id, block_id,
             wr_accuracy, wr_reaction_time_ms) |>
      rename(wr_acc = wr_accuracy, wr_rt = wr_reaction_time_ms),
    by = c("participant_id", "stimulus_id", "block_id")
  )

# Overall false alarm rate per participant
fa_per_participant <- ir_false_alarms |>
  group_by(participant_id) |>
  summarise(n_fa = n(), .groups = "drop") |>
  left_join(
    probes_shown |>
      filter(is_target_sentence == FALSE | is_probe_repeat == FALSE) |>
      ## Actually, we need a denominator: count non-target sentence showings
      ## Instead, use the simpler approach: count from the full data
      select() |> head(0),  # placeholder
    by = character()
  )

# Count non-target, non-repeat "Sentence shown" per participant (FA denominator)
n_nontarget <- df |>
  filter(
    event_type == "Sentence shown",
    is_target_sentence == FALSE,
    is_probe_repeat == FALSE
  ) |>
  group_by(participant_id) |>
  summarise(n_nontarget_shown = n(), .groups = "drop")

fa_rate <- ir_false_alarms |>
  group_by(participant_id) |>
  summarise(n_fa = n(), .groups = "drop") |>
  left_join(n_nontarget, by = "participant_id") |>
  mutate(fa_rate = n_fa / n_nontarget_shown)

# Per-participant × condition hit rate
hit_by_cond <- hit_rates |>
  group_by(participant_id, noun_condition) |>
  summarise(
    n_probes  = n(),
    n_hits    = sum(ir_hit, na.rm = TRUE),
    hit_rate  = n_hits / n_probes,
    .groups   = "drop"
  ) |>
  left_join(fa_rate |> select(participant_id, fa_rate), by = "participant_id") |>
  mutate(
    fa_rate = ifelse(is.na(fa_rate), 0, fa_rate),
    corrected_ir = hit_rate - fa_rate
  )

# Per-participant × condition × voice hit rate
hit_by_cond_voice <- hit_rates |>
  group_by(participant_id, noun_condition, voice) |>
  summarise(
    n_probes = n(),
    n_hits   = sum(ir_hit, na.rm = TRUE),
    hit_rate = n_hits / n_probes,
    .groups  = "drop"
  ) |>
  left_join(fa_rate |> select(participant_id, fa_rate), by = "participant_id") |>
  mutate(
    fa_rate = ifelse(is.na(fa_rate), 0, fa_rate),
    corrected_ir = hit_rate - fa_rate
  )

# WR accuracy by condition × voice
wr_by_cond_voice <- hit_rates |>
  filter(!is.na(wr_acc)) |>
  group_by(participant_id, noun_condition, voice) |>
  summarise(
    n_wr        = n(),
    n_correct   = sum(wr_acc, na.rm = TRUE),
    wr_accuracy = n_correct / n_wr,
    .groups     = "drop"
  )

wr_by_cond <- hit_rates |>
  filter(!is.na(wr_acc)) |>
  group_by(participant_id, noun_condition) |>
  summarise(
    n_wr        = n(),
    n_correct   = sum(wr_acc, na.rm = TRUE),
    wr_accuracy = n_correct / n_wr,
    .groups     = "drop"
  )

# Ensure factor ordering
hit_by_cond$noun_condition <- factor(hit_by_cond$noun_condition,
                                     levels = c("HH", "HL", "LH", "LL"))
hit_by_cond_voice$noun_condition <- factor(hit_by_cond_voice$noun_condition,
                                           levels = c("HH", "HL", "LH", "LL"))
hit_by_cond_voice$voice <- factor(hit_by_cond_voice$voice,
                                   levels = c("Active", "Passive"))
wr_by_cond$noun_condition <- factor(wr_by_cond$noun_condition,
                                     levels = c("HH", "HL", "LH", "LL"))
wr_by_cond_voice$noun_condition <- factor(wr_by_cond_voice$noun_condition,
                                           levels = c("HH", "HL", "LH", "LL"))
wr_by_cond_voice$voice <- factor(wr_by_cond_voice$voice,
                                  levels = c("Active", "Passive"))

# Create output directory
dir.create("plots", showWarnings = FALSE, recursive = TRUE)


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 1 — IR Corrected Recognition by Noun Condition
# Violin + box + jittered points
# ══════════════════════════════════════════════════════════════════════════════

p1 <- ggplot(hit_by_cond, aes(x = noun_condition, y = corrected_ir,
                               fill = noun_condition)) +
  geom_violin(alpha = 0.35, colour = NA, width = 0.8, trim = FALSE) +
  geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.7,
               colour = "#2D3436", linewidth = 0.4) +
  geom_jitter(aes(colour = noun_condition), width = 0.08, alpha = 0.45,
              size = 1.2, shape = 16) +
  scale_fill_manual(values = palette_condition, guide = "none") +
  scale_colour_manual(values = palette_condition, guide = "none") +
  labs(
    title    = "Immediate Recognition (IR) by Noun Condition",
    subtitle = "Per-participant corrected recognition (hit rate − FA rate)",
    x        = "Noun Condition",
    y        = "Corrected Recognition",
    caption  = "Each point = one participant | HH = High–High, HL = High–Low, LH = Low–High, LL = Low–Low"
  ) +
  theme_memo() +
  theme(legend.position = "none")

ggsave("plots/01_ir_by_condition.png", p1, width = 8, height = 6, dpi = 300)
cat("Saved: plots/01_ir_by_condition.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 2 — WR Accuracy by Noun Condition
# ══════════════════════════════════════════════════════════════════════════════

p2 <- ggplot(wr_by_cond, aes(x = noun_condition, y = wr_accuracy,
                              fill = noun_condition)) +
  geom_violin(alpha = 0.35, colour = NA, width = 0.8, trim = FALSE) +
  geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.7,
               colour = "#2D3436", linewidth = 0.4) +
  geom_jitter(aes(colour = noun_condition), width = 0.08, alpha = 0.45,
              size = 1.2, shape = 16) +
  geom_hline(yintercept = 0.5, linetype = "dotted", colour = "#B2BEC3") +
  scale_fill_manual(values = palette_condition, guide = "none") +
  scale_colour_manual(values = palette_condition, guide = "none") +
  labs(
    title    = "Wording Recognition (WR) Accuracy by Noun Condition",
    subtitle = "Per-participant proportion correct wording judgments",
    x        = "Noun Condition",
    y        = "Proportion Correct",
    caption  = "Dotted line = chance (50%) | Each point = one participant"
  ) +
  theme_memo() +
  theme(legend.position = "none")

ggsave("plots/02_wr_by_condition.png", p2, width = 8, height = 6, dpi = 300)
cat("Saved: plots/02_wr_by_condition.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 3 — IR Corrected Recognition: Noun Condition × Voice Interaction
# ══════════════════════════════════════════════════════════════════════════════

ir_interaction <- hit_by_cond_voice |>
  group_by(noun_condition, voice) |>
  summarise(
    M  = mean(corrected_ir, na.rm = TRUE),
    SE = sd(corrected_ir, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p3 <- ggplot(ir_interaction, aes(x = noun_condition, y = M, fill = voice)) +
  geom_col(position = position_dodge(0.7), width = 0.6, alpha = 0.85) +
  geom_errorbar(aes(ymin = M - SE, ymax = M + SE),
                position = position_dodge(0.7), width = 0.18,
                linewidth = 0.5, colour = "#2D3436") +
  scale_fill_manual(values = palette_voice, name = "Voice") +
  labs(
    title    = "Noun Condition × Voice Interaction (IR)",
    subtitle = "Mean corrected recognition ± 1 SE",
    x        = "Noun Condition",
    y        = "Mean Corrected Recognition",
    caption  = "Error bars = ±1 standard error of the mean"
  ) +
  theme_memo()

ggsave("plots/03_ir_condition_x_voice.png", p3, width = 9, height = 6, dpi = 300)
cat("Saved: plots/03_ir_condition_x_voice.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 4 — WR Accuracy: Noun Condition × Voice Interaction
# ══════════════════════════════════════════════════════════════════════════════

wr_interaction <- wr_by_cond_voice |>
  group_by(noun_condition, voice) |>
  summarise(
    M  = mean(wr_accuracy, na.rm = TRUE),
    SE = sd(wr_accuracy, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p4 <- ggplot(wr_interaction, aes(x = noun_condition, y = M, fill = voice)) +
  geom_col(position = position_dodge(0.7), width = 0.6, alpha = 0.85) +
  geom_errorbar(aes(ymin = M - SE, ymax = M + SE),
                position = position_dodge(0.7), width = 0.18,
                linewidth = 0.5, colour = "#2D3436") +
  geom_hline(yintercept = 0.5, linetype = "dotted", colour = "#B2BEC3") +
  scale_fill_manual(values = palette_voice, name = "Voice") +
  labs(
    title    = "Noun Condition × Voice Interaction (WR)",
    subtitle = "Mean proportion correct wording judgments ± 1 SE",
    x        = "Noun Condition",
    y        = "Mean Proportion Correct",
    caption  = "Dotted line = chance (50%) | Error bars = ±1 SE"
  ) +
  theme_memo()

ggsave("plots/04_wr_condition_x_voice.png", p4, width = 9, height = 6, dpi = 300)
cat("Saved: plots/04_wr_condition_x_voice.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 5 — IR Reaction Time Distribution by Noun Condition
# Overlapping density curves
# ══════════════════════════════════════════════════════════════════════════════

ir_rt <- ir_hits |>
  filter(
    !is.na(ir_reaction_time_ms),
    ir_reaction_time_ms > 0,
    ir_reaction_time_ms < 10000
  ) |>
  mutate(noun_condition = factor(noun_condition, levels = c("HH", "HL", "LH", "LL")))

p5 <- ggplot(ir_rt, aes(x = ir_reaction_time_ms, fill = noun_condition,
                         colour = noun_condition)) +
  geom_density(alpha = 0.3, linewidth = 0.7) +
  scale_fill_manual(values = palette_condition, name = "Noun Condition") +
  scale_colour_manual(values = palette_condition, name = "Noun Condition") +
  scale_x_continuous(labels = scales::comma_format()) +
  labs(
    title    = "IR Reaction Time Distributions by Noun Condition",
    subtitle = "Density of reaction times (ms) for IR presses on target probes",
    x        = "Reaction Time (ms)",
    y        = "Density",
    caption  = "RTs > 10 s excluded | Kernel density estimate"
  ) +
  theme_memo()

ggsave("plots/05_ir_rt_density.png", p5, width = 9, height = 5.5, dpi = 300)
cat("Saved: plots/05_ir_rt_density.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 6 — Hit Rate vs False Alarm Rate by Participant
# ══════════════════════════════════════════════════════════════════════════════

participant_perf <- probes_shown |>
  left_join(
    ir_hits |>
      select(participant_id, stimulus_id, block_id, ir_accuracy) |>
      rename(ir_hit = ir_accuracy),
    by = c("participant_id", "stimulus_id", "block_id")
  ) |>
  mutate(ir_hit = ifelse(is.na(ir_hit), 0L, ir_hit)) |>
  group_by(participant_id) |>
  summarise(
    hit_rate = mean(ir_hit, na.rm = TRUE),
    n_trials = n(),
    .groups = "drop"
  ) |>
  left_join(fa_rate |> select(participant_id, fa_rate), by = "participant_id") |>
  mutate(fa_rate = ifelse(is.na(fa_rate), 0, fa_rate))

p6 <- ggplot(participant_perf, aes(x = fa_rate, y = hit_rate)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed",
              colour = "#B2BEC3", linewidth = 0.5) +
  geom_point(colour = "#6C5CE7", alpha = 0.55, size = 2.5, shape = 16) +
  geom_smooth(method = "lm", se = TRUE, colour = "#D63031",
              fill = "#D63031", alpha = 0.15, linewidth = 0.8) +
  labs(
    title    = "Hit Rate vs False Alarm Rate (IR)",
    subtitle = "Each point = one participant's overall performance",
    x        = "False Alarm Rate",
    y        = "Hit Rate",
    caption  = "Dashed = chance performance | Red line = linear fit ± 95% CI"
  ) +
  theme_memo() +
  coord_fixed(xlim = c(0, 1), ylim = c(0, 1))

ggsave("plots/06_hit_vs_fa.png", p6, width = 7.5, height = 7, dpi = 300)
cat("Saved: plots/06_hit_vs_fa.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 7 — IR Corrected Recognition Across Blocks
# Line plot showing learning / fatigue effects
# ══════════════════════════════════════════════════════════════════════════════

hit_by_block <- hit_rates |>
  group_by(participant_id, block_id, noun_condition) |>
  summarise(
    hit_rate = mean(ir_hit, na.rm = TRUE),
    .groups  = "drop"
  ) |>
  left_join(fa_rate |> select(participant_id, fa_rate), by = "participant_id") |>
  mutate(
    fa_rate = ifelse(is.na(fa_rate), 0, fa_rate),
    corrected_ir = hit_rate - fa_rate
  )

hit_by_block$noun_condition <- factor(hit_by_block$noun_condition,
                                      levels = c("HH", "HL", "LH", "LL"))

block_summary <- hit_by_block |>
  group_by(block_id, noun_condition) |>
  summarise(
    M  = mean(corrected_ir, na.rm = TRUE),
    SE = sd(corrected_ir, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p7 <- ggplot(block_summary, aes(x = factor(block_id), y = M,
                                 colour = noun_condition,
                                 group = noun_condition)) +
  geom_line(linewidth = 1, alpha = 0.8) +
  geom_point(size = 3.5, shape = 21, aes(fill = noun_condition),
             colour = "#2D3436", stroke = 0.6) +
  geom_errorbar(aes(ymin = M - SE, ymax = M + SE), width = 0.12,
                linewidth = 0.5) +
  scale_colour_manual(values = palette_condition, name = "Noun Condition") +
  scale_fill_manual(values = palette_condition, name = "Noun Condition") +
  labs(
    title    = "IR Corrected Recognition Across Blocks",
    subtitle = "Mean ± 1 SE per noun condition across three experimental blocks",
    x        = "Block",
    y        = "Mean Corrected Recognition",
    caption  = "Blocks 1–3 = consecutive segments of the experiment"
  ) +
  theme_memo()

ggsave("plots/07_block_learning.png", p7, width = 8, height = 5.5, dpi = 300)
cat("Saved: plots/07_block_learning.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 8 — Per-Participant IR Heatmap
# ══════════════════════════════════════════════════════════════════════════════

# Order participants by overall corrected IR
pid_order <- hit_by_cond |>
  group_by(participant_id) |>
  summarise(overall = mean(corrected_ir, na.rm = TRUE), .groups = "drop") |>
  arrange(overall) |>
  pull(participant_id)

heatmap_data <- hit_by_cond |>
  mutate(participant_id = factor(participant_id, levels = pid_order))

p8 <- ggplot(heatmap_data,
             aes(x = noun_condition, y = participant_id, fill = corrected_ir)) +
  geom_tile(colour = "#FAFAFA", linewidth = 0.3) +
  scale_fill_gradient2(
    low      = "#D63031",
    mid      = "#FAFAFA",
    high     = "#00B894",
    midpoint = 0,
    name     = "Corrected\nRecognition"
  ) +
  labs(
    title    = "Per-Participant IR Performance Heatmap",
    subtitle = "Rows sorted by overall mean corrected recognition (low → high)",
    x        = "Noun Condition",
    y        = "Participant (sorted)",
    caption  = "Green = strong recognition | Red = poor / negative"
  ) +
  theme_memo() +
  theme(
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid   = element_blank()
  )

ggsave("plots/08_participant_heatmap.png", p8, width = 6.5, height = 10, dpi = 300)
cat("Saved: plots/08_participant_heatmap.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 9 — Active vs Passive Voice: Slope Chart (IR)
# ══════════════════════════════════════════════════════════════════════════════

voice_summary <- hit_by_cond_voice |>
  group_by(noun_condition, voice) |>
  summarise(
    M  = mean(corrected_ir, na.rm = TRUE),
    SE = sd(corrected_ir, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p9 <- ggplot(voice_summary, aes(x = voice, y = M, colour = noun_condition,
                                 group = noun_condition)) +
  geom_line(linewidth = 1.2, alpha = 0.7) +
  geom_point(size = 4, shape = 19) +
  geom_errorbar(aes(ymin = M - SE, ymax = M + SE), width = 0.1,
                linewidth = 0.5) +
  scale_colour_manual(values = palette_condition, name = "Noun Condition") +
  labs(
    title    = "Active vs Passive Voice Effect on IR",
    subtitle = "Mean corrected recognition ± 1 SE, connected by condition",
    x        = "Grammatical Voice",
    y        = "Mean Corrected Recognition",
    caption  = "Lines connect the same noun condition across voices"
  ) +
  theme_memo()

ggsave("plots/09_voice_slope.png", p9, width = 7.5, height = 5.5, dpi = 300)
cat("Saved: plots/09_voice_slope.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 10 — IR Hit Rate vs WR Accuracy Scatter
# ══════════════════════════════════════════════════════════════════════════════

ir_wr_comp <- hit_by_cond |>
  select(participant_id, noun_condition, corrected_ir) |>
  left_join(
    wr_by_cond |> select(participant_id, noun_condition, wr_accuracy),
    by = c("participant_id", "noun_condition")
  )

p10 <- ggplot(ir_wr_comp, aes(x = corrected_ir, y = wr_accuracy,
                               colour = noun_condition)) +
  geom_point(alpha = 0.5, size = 2, shape = 16) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.7, alpha = 0.7) +
  scale_colour_manual(values = palette_condition, name = "Noun Condition") +
  labs(
    title    = "IR Corrected Recognition vs WR Accuracy",
    subtitle = "Per-participant per-condition scores",
    x        = "IR Corrected Recognition",
    y        = "WR Proportion Correct",
    caption  = "Solid lines = per-condition linear fits"
  ) +
  theme_memo()

ggsave("plots/10_ir_vs_wr.png", p10, width = 8, height = 6.5, dpi = 300)
cat("Saved: plots/10_ir_vs_wr.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 11 — WR Accuracy by Voice
# Critical question: can participants detect voice changes?
# ══════════════════════════════════════════════════════════════════════════════

wr_voice <- hit_rates |>
  filter(!is.na(wr_acc)) |>
  group_by(participant_id, voice) |>
  summarise(prop_correct = mean(wr_acc, na.rm = TRUE), .groups = "drop") |>
  mutate(voice = factor(voice, levels = c("Active", "Passive")))

p11 <- ggplot(wr_voice, aes(x = voice, y = prop_correct, fill = voice)) +
  geom_violin(alpha = 0.3, colour = NA, width = 0.7, trim = FALSE) +
  geom_boxplot(width = 0.15, outlier.shape = NA, alpha = 0.7,
               colour = "#2D3436", linewidth = 0.4) +
  geom_jitter(aes(colour = voice), width = 0.06, alpha = 0.4,
              size = 1.3, shape = 16) +
  geom_hline(yintercept = 0.5, linetype = "dotted", colour = "#B2BEC3") +
  scale_fill_manual(values = palette_voice, guide = "none") +
  scale_colour_manual(values = palette_voice, guide = "none") +
  labs(
    title    = "Wording Recognition Accuracy by Voice",
    subtitle = "Per-participant proportion correct on voice judgments",
    x        = "Original Voice of Sentence",
    y        = "Proportion Correct",
    caption  = "Dotted line = chance (50%) | Each point = one participant"
  ) +
  theme_memo() +
  theme(legend.position = "none")

ggsave("plots/11_wr_accuracy_by_voice.png", p11, width = 7, height = 6, dpi = 300)
cat("Saved: plots/11_wr_accuracy_by_voice.png\n")


# ══════════════════════════════════════════════════════════════════════════════
# PLOT 12 — Forest Plot: IR Corrected Recognition by Condition × Voice
# ══════════════════════════════════════════════════════════════════════════════

forest_data <- hit_by_cond_voice |>
  group_by(noun_condition, voice) |>
  summarise(
    M    = mean(corrected_ir, na.rm = TRUE),
    SE   = sd(corrected_ir, na.rm = TRUE) / sqrt(n()),
    n    = n(),
    CI95 = qt(0.975, n() - 1) * SE,
    .groups = "drop"
  ) |>
  mutate(label = paste0(noun_condition, " (", voice, ")"))

forest_data$label <- factor(forest_data$label,
                            levels = forest_data$label[order(forest_data$M)])

p12 <- ggplot(forest_data, aes(x = M, y = label, colour = voice)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "#B2BEC3",
             linewidth = 0.4) +
  geom_errorbar(aes(xmin = M - CI95, xmax = M + CI95),
                height = 0.25, linewidth = 0.6, orientation = "y") +
  geom_point(size = 3.5, shape = 19) +
  scale_colour_manual(values = palette_voice, name = "Voice") +
  labs(
    title    = "Forest Plot: IR Corrected Recognition",
    subtitle = "Mean ± 95% CI (participant-level, by condition × voice)",
    x        = "Mean Corrected Recognition",
    y        = NULL,
    caption  = "Dashed line = zero (no discrimination) | CI = 95% t-interval"
  ) +
  theme_memo() +
  theme(panel.grid.major.y = element_blank())

ggsave("plots/12_forest_plot.png", p12, width = 9, height = 5.5, dpi = 300)
cat("Saved: plots/12_forest_plot.png\n")


# ══════════════════════════════════════════════════════════════════════════════
cat("\n✓ All 12 plots saved to plots/ directory.\n")

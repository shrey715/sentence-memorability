# ── results_stats.R ───────────────────────────────────────────────────────────
# Compute all statistics needed for the results write-up.
# Outputs are printed to stdout for extraction.
# ──────────────────────────────────────────────────────────────────────────────

library(dplyr)
library(stringr)

df <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)

# Parse conditions
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

# ── Target probe Sentence shown rows ────────────────────────────────────────
probes_shown <- df |>
  filter(event_type == "Sentence shown", is_target_sentence == TRUE,
         is_probe_repeat == TRUE, !is.na(noun_condition))

# IR hits on target probes
ir_hits <- df |>
  filter(event_type == "IR pressed", is_target_sentence == TRUE,
         is_probe_repeat == TRUE, !is.na(noun_condition))

# WR presses on target probes
wr_presses <- df |>
  filter(event_type == "WR pressed", is_target_sentence == TRUE,
         is_probe_repeat == TRUE, !is.na(noun_condition))

# FA data
n_nontarget <- df |>
  filter(event_type == "Sentence shown", is_target_sentence == FALSE,
         is_probe_repeat == FALSE) |>
  group_by(participant_id) |> summarise(n_nt = n(), .groups = "drop")

ir_fa <- df |>
  filter(event_type == "IR pressed", is_target_sentence == FALSE,
         is_probe_repeat == FALSE) |>
  group_by(participant_id) |> summarise(n_fa = n(), .groups = "drop")

fa_rate <- ir_fa |>
  left_join(n_nontarget, by = "participant_id") |>
  mutate(fa_rate = n_fa / n_nt)

# ── Join hit/miss info to probes_shown ────────────────────────────────────────
probes <- probes_shown |>
  left_join(
    ir_hits |> select(participant_id, stimulus_id, block_id, ir_accuracy,
                      ir_reaction_time_ms) |>
      rename(ir_hit = ir_accuracy, ir_rt = ir_reaction_time_ms),
    by = c("participant_id", "stimulus_id", "block_id")
  ) |>
  mutate(ir_hit = ifelse(is.na(ir_hit), 0L, ir_hit)) |>
  left_join(
    wr_presses |> select(participant_id, stimulus_id, block_id, wr_accuracy,
                         wr_reaction_time_ms) |>
      rename(wr_acc = wr_accuracy, wr_rt = wr_reaction_time_ms),
    by = c("participant_id", "stimulus_id", "block_id")
  )

cat("═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 0: DESCRIPTIVE OVERVIEW\n")
cat("═══════════════════════════════════════════════════════════════════\n")
cat(sprintf("Participants: %d\n", n_distinct(probes$participant_id)))
cat(sprintf("Target probe rows: %d\n", nrow(probes)))
cat(sprintf("IR hit rows: %d\n", nrow(ir_hits)))
cat(sprintf("WR press rows: %d\n", nrow(wr_presses)))

# Overall hit/FA/corrected
overall_hit <- mean(probes$ir_hit, na.rm = TRUE)
overall_fa  <- mean(fa_rate$fa_rate, na.rm = TRUE)
cat(sprintf("Overall IR hit rate: %.3f\n", overall_hit))
cat(sprintf("Overall FA rate: %.3f\n", overall_fa))
cat(sprintf("Overall corrected IR: %.3f\n", overall_hit - overall_fa))

cat("\n═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 1: IR CORRECTED RECOGNITION BY NOUN CONDITION\n")
cat("═══════════════════════════════════════════════════════════════════\n")

hit_by_cond <- probes |>
  group_by(participant_id, noun_condition) |>
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") |>
  left_join(fa_rate |> select(participant_id, fa_rate), by = "participant_id") |>
  mutate(fa_rate = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

cond_summary <- hit_by_cond |>
  group_by(noun_condition) |>
  summarise(M = mean(corrected_ir), SD = sd(corrected_ir),
            Mdn = median(corrected_ir), n = n(), .groups = "drop")
cat("Condition-level descriptives:\n")
print(as.data.frame(cond_summary))

# Kruskal-Wallis (as specified in project)
kw_ir <- kruskal.test(corrected_ir ~ noun_condition, data = hit_by_cond)
cat(sprintf("\nKruskal-Wallis: H(%d) = %.3f, p = %.4f\n",
            kw_ir$parameter, kw_ir$statistic, kw_ir$p.value))

# Pairwise Wilcoxon
pw_ir <- pairwise.wilcox.test(hit_by_cond$corrected_ir,
                              hit_by_cond$noun_condition,
                              p.adjust.method = "holm")
cat("Pairwise Wilcoxon (Holm-corrected):\n")
print(pw_ir$p.value)

cat("\n═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 2: WR ACCURACY BY NOUN CONDITION\n")
cat("═══════════════════════════════════════════════════════════════════\n")

wr_by_cond <- probes |>
  filter(!is.na(wr_acc)) |>
  group_by(participant_id, noun_condition) |>
  summarise(wr_accuracy = mean(wr_acc, na.rm = TRUE), .groups = "drop")

wr_cond_summary <- wr_by_cond |>
  group_by(noun_condition) |>
  summarise(M = mean(wr_accuracy), SD = sd(wr_accuracy),
            Mdn = median(wr_accuracy), n = n(), .groups = "drop")
cat("WR accuracy by condition:\n")
print(as.data.frame(wr_cond_summary))

kw_wr <- kruskal.test(wr_accuracy ~ noun_condition, data = wr_by_cond)
cat(sprintf("\nKruskal-Wallis: H(%d) = %.3f, p = %.4f\n",
            kw_wr$parameter, kw_wr$statistic, kw_wr$p.value))

cat("\n═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 3: VOICE EFFECT ON IR\n")
cat("═══════════════════════════════════════════════════════════════════\n")

hit_by_voice <- probes |>
  group_by(participant_id, voice) |>
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") |>
  left_join(fa_rate |> select(participant_id, fa_rate), by = "participant_id") |>
  mutate(fa_rate = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

voice_summary <- hit_by_voice |>
  group_by(voice) |>
  summarise(M = mean(corrected_ir), SD = sd(corrected_ir),
            Mdn = median(corrected_ir), n = n(), .groups = "drop")
cat("IR corrected by voice:\n")
print(as.data.frame(voice_summary))

wt_voice <- wilcox.test(corrected_ir ~ voice, data = hit_by_voice, paired = TRUE)
cat(sprintf("\nWilcoxon signed-rank (paired): V = %.0f, p = %.4f\n",
            wt_voice$statistic, wt_voice$p.value))

cat("\n═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 4: CONDITION × VOICE INTERACTION (IR)\n")
cat("═══════════════════════════════════════════════════════════════════\n")

hit_by_cv <- probes |>
  group_by(participant_id, noun_condition, voice) |>
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") |>
  left_join(fa_rate |> select(participant_id, fa_rate), by = "participant_id") |>
  mutate(fa_rate = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

cv_summary <- hit_by_cv |>
  group_by(noun_condition, voice) |>
  summarise(M = mean(corrected_ir), SD = sd(corrected_ir), n = n(),
            .groups = "drop")
cat("8-cell descriptives (condition × voice):\n")
print(as.data.frame(cv_summary))

cat("\n═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 5: WR ACCURACY BY VOICE\n")
cat("═══════════════════════════════════════════════════════════════════\n")

wr_by_voice <- probes |>
  filter(!is.na(wr_acc)) |>
  group_by(participant_id, voice) |>
  summarise(wr_accuracy = mean(wr_acc, na.rm = TRUE), .groups = "drop")

wr_voice_summary <- wr_by_voice |>
  group_by(voice) |>
  summarise(M = mean(wr_accuracy), SD = sd(wr_accuracy),
            Mdn = median(wr_accuracy), n = n(), .groups = "drop")
cat("WR accuracy by voice:\n")
print(as.data.frame(wr_voice_summary))

wt_wr_voice <- wilcox.test(wr_accuracy ~ voice, data = wr_by_voice, paired = TRUE)
cat(sprintf("\nWilcoxon signed-rank (paired): V = %.0f, p = %.4f\n",
            wt_wr_voice$statistic, wt_wr_voice$p.value))

# One-sample vs chance (0.5)
for (v in c("Active", "Passive")) {
  vals <- wr_by_voice$wr_accuracy[wr_by_voice$voice == v]
  wt <- wilcox.test(vals, mu = 0.5, alternative = "greater")
  cat(sprintf("  %s vs 0.5: V = %.0f, p = %.4f\n", v, wt$statistic, wt$p.value))
}

cat("\n═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 6: REACTION TIMES\n")
cat("═══════════════════════════════════════════════════════════════════\n")

rt_data <- ir_hits |>
  filter(!is.na(ir_reaction_time_ms), ir_reaction_time_ms > 0,
         ir_reaction_time_ms < 10000)

rt_by_cond <- rt_data |>
  group_by(participant_id, noun_condition) |>
  summarise(mean_rt = mean(ir_reaction_time_ms), mdn_rt = median(ir_reaction_time_ms),
            .groups = "drop")

rt_summary <- rt_by_cond |>
  group_by(noun_condition) |>
  summarise(M = mean(mean_rt), SD = sd(mean_rt), Mdn = mean(mdn_rt),
            n = n(), .groups = "drop")
cat("RT by condition (ms):\n")
print(as.data.frame(rt_summary))

kw_rt <- kruskal.test(mean_rt ~ noun_condition, data = rt_by_cond)
cat(sprintf("\nKruskal-Wallis: H(%d) = %.3f, p = %.4f\n",
            kw_rt$parameter, kw_rt$statistic, kw_rt$p.value))

cat("\n═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 7: BLOCK EFFECTS\n")
cat("═══════════════════════════════════════════════════════════════════\n")

hit_by_block <- probes |>
  group_by(participant_id, block_id) |>
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") |>
  left_join(fa_rate |> select(participant_id, fa_rate), by = "participant_id") |>
  mutate(fa_rate = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

block_summary <- hit_by_block |>
  group_by(block_id) |>
  summarise(M = mean(corrected_ir), SD = sd(corrected_ir), n = n(),
            .groups = "drop")
cat("Corrected IR by block:\n")
print(as.data.frame(block_summary))

kw_block <- kruskal.test(corrected_ir ~ factor(block_id), data = hit_by_block)
cat(sprintf("\nKruskal-Wallis: H(%d) = %.3f, p = %.4f\n",
            kw_block$parameter, kw_block$statistic, kw_block$p.value))

cat("\n═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 8: HIT vs FA CORRELATION\n")
cat("═══════════════════════════════════════════════════════════════════\n")

part_perf <- probes |>
  group_by(participant_id) |>
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") |>
  left_join(fa_rate |> select(participant_id, fa_rate), by = "participant_id") |>
  mutate(fa_rate = ifelse(is.na(fa_rate), 0, fa_rate))

cor_test <- cor.test(part_perf$fa_rate, part_perf$hit_rate, method = "spearman")
cat(sprintf("Spearman correlation(FA, hit): rho = %.3f, p = %.4f\n",
            cor_test$estimate, cor_test$p.value))
cat(sprintf("Hit rate range: [%.3f, %.3f]\n",
            min(part_perf$hit_rate), max(part_perf$hit_rate)))
cat(sprintf("FA rate range: [%.3f, %.3f]\n",
            min(part_perf$fa_rate), max(part_perf$fa_rate)))

cat("\n═══════════════════════════════════════════════════════════════════\n")
cat("SECTION 9: IR vs WR CORRELATION\n")
cat("═══════════════════════════════════════════════════════════════════\n")

ir_wr <- hit_by_cond |>
  select(participant_id, noun_condition, corrected_ir) |>
  left_join(wr_by_cond |> select(participant_id, noun_condition, wr_accuracy),
            by = c("participant_id", "noun_condition")) |>
  filter(!is.na(wr_accuracy))

cor_ir_wr <- cor.test(ir_wr$corrected_ir, ir_wr$wr_accuracy, method = "spearman")
cat(sprintf("Spearman correlation(IR, WR): rho = %.3f, p = %.4f\n",
            cor_ir_wr$estimate, cor_ir_wr$p.value))

cat("\n═══ DONE ═══\n")

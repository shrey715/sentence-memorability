# src/block_learning/01_prepare_block_data.R
# Creates block_scores.csv: per-participant × block_id × noun_condition summary.
# Reads pruned_data.csv so block_id is available and failed blocks are excluded.
#
# block_id is assigned by 02_clean_events.R using "Rest Phase started" boundaries.
# pruned_data.csv retains block_id with block_valid attached (03_validate_participants.R).
# We filter to block_valid == TRUE — same exclusion step as 04_finalize_dataset.R.
#
# Scoring approach (mirrors 05a_compute_scores.R):
#   Target probes  — "Sentence shown" events: is_target_sentence == TRUE &
#                    is_probe_repeat == "TRUE"
#   IR hits        — "IR pressed" events: is_target_sentence == TRUE
#   FA count       — "IR pressed" events: noun_condition_raw == "HF" &
#                    is.na(is_probe_repeat)  (HF first-showings incorrectly pressed)
#   FA denominator — "Sentence shown" events: noun_condition_raw == "HF" &
#                    is.na(is_probe_repeat)  (32 per participant per block)
#   WR accuracy    — "WR pressed" events: is_target_sentence == TRUE
#   RT             — ir_reaction_time_ms from "IR pressed" target rows
#
# FA rate is computed per participant × block (not globally), because each block
# has its own independent lure set. Using a global FA would inflate/deflate
# block-level corrected IRs.
#
# Input:  data/processed/pruned_data.csv
# Output: data/processed/block_scores.csv

suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
})

cat("\n[block_learning/01] Preparing block-level dataset...\n")

df <- read.csv("data/processed/pruned_data.csv", stringsAsFactors = FALSE) %>%
  filter(block_valid == TRUE)

cat(sprintf("  Input rows (valid blocks only) : %d\n", nrow(df)))
cat(sprintf("  Participants                   : %d\n", length(unique(df$participant_id))))

# ── Parse condition from stimulus ID (mirrors 04_finalize_dataset.R) ───────────
# stimulus_id format: <condition>_<number>_<voice_suffix>
# e.g. "HVL_3_A" -> noun_condition_raw = "HVL" -> noun_condition = "HL"
#      "HF_5_A"  -> noun_condition_raw = "HF"  (high-frequency filler / lure)
df <- df %>%
  mutate(
    noun_condition_raw = str_extract(stimulus_id, "^[A-Za-z]+"),
    noun_condition = case_when(
      noun_condition_raw %in% c("HL", "HVL") ~ "HL",
      noun_condition_raw %in% c("LH", "LVH") ~ "LH",
      noun_condition_raw %in% c("LL", "LVL") ~ "LL",
      TRUE ~ noun_condition_raw
    )
  )

cat("\n  Noun condition distribution (all event types):\n")
cond_counts <- sort(table(df$noun_condition), decreasing = TRUE)
for (i in seq_along(cond_counts)) {
  cat(sprintf("    %-4s : %d rows\n", names(cond_counts)[i], cond_counts[i]))
}

# ── False alarm rate per participant × block ────────────────────────────────────
# FA = "IR pressed" on HF sentences at first showing (is.na(is_probe_repeat))
# Denominator = "Sentence shown" HF at first showing (always 32 per block)
hf_shown <- df %>%
  filter(event_type == "Sentence shown",
         noun_condition_raw == "HF",
         is.na(is_probe_repeat)) %>%
  group_by(participant_id, block_id) %>%
  summarise(n_hf = n(), .groups = "drop")

hf_pressed <- df %>%
  filter(event_type == "IR pressed",
         noun_condition_raw == "HF",
         is.na(is_probe_repeat)) %>%
  group_by(participant_id, block_id) %>%
  summarise(n_fa = n(), .groups = "drop")

fa_by_block <- hf_shown %>%
  left_join(hf_pressed, by = c("participant_id", "block_id")) %>%
  mutate(
    n_fa    = replace(n_fa, is.na(n_fa), 0L),
    fa_rate = n_fa / n_hf
  ) %>%
  select(participant_id, block_id, fa_rate, n_hf)

cat(sprintf("\n  FA rate computed for %d participant × block combinations\n",
            nrow(fa_by_block)))
cat(sprintf("  FA rate  mean=%.3f  sd=%.3f  min=%.3f  max=%.3f\n",
            mean(fa_by_block$fa_rate), sd(fa_by_block$fa_rate),
            min(fa_by_block$fa_rate), max(fa_by_block$fa_rate)))

# ── Target probe count per participant × block × condition ──────────────────────
target_probes <- df %>%
  filter(event_type == "Sentence shown",
         is_target_sentence == TRUE,
         is_probe_repeat == "TRUE",
         noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
  group_by(participant_id, block_id, noun_condition) %>%
  summarise(n_probes = n(), .groups = "drop")

# ── IR hit count per participant × block × condition ────────────────────────────
ir_hits <- df %>%
  filter(event_type == "IR pressed",
         is_target_sentence == TRUE,
         noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
  group_by(participant_id, block_id, noun_condition) %>%
  summarise(n_hits = n(), .groups = "drop")

# ── WR accuracy per participant × block × condition ─────────────────────────────
wr_acc <- df %>%
  filter(event_type == "WR pressed",
         is_target_sentence == TRUE,
         noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
  group_by(participant_id, block_id, noun_condition) %>%
  summarise(
    wr_acc    = mean(wr_accuracy == 1, na.rm = TRUE),
    n_wr      = n(),
    .groups   = "drop"
  )

# ── Mean RT per participant × block × condition ─────────────────────────────────
mean_rt <- df %>%
  filter(event_type == "IR pressed",
         is_target_sentence == TRUE,
         noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
  group_by(participant_id, block_id, noun_condition) %>%
  summarise(
    mean_rt  = mean(ir_reaction_time_ms, na.rm = TRUE),
    .groups  = "drop"
  )

# ── Assemble block_scores ───────────────────────────────────────────────────────
block_scores <- target_probes %>%
  left_join(ir_hits,    by = c("participant_id", "block_id", "noun_condition")) %>%
  left_join(wr_acc,     by = c("participant_id", "block_id", "noun_condition")) %>%
  left_join(mean_rt,    by = c("participant_id", "block_id", "noun_condition")) %>%
  left_join(fa_by_block, by = c("participant_id", "block_id")) %>%
  mutate(
    n_hits       = replace(n_hits, is.na(n_hits), 0L),
    hit_rate     = n_hits / n_probes,
    corrected_ir = hit_rate - fa_rate,
    block_id     = factor(block_id, levels = c(1, 2, 3),
                          labels = c("Block 1", "Block 2", "Block 3")),
    noun_condition = factor(noun_condition, levels = c("HH", "HL", "LH", "LL"))
  ) %>%
  select(participant_id, block_id, noun_condition,
         hit_rate, fa_rate, corrected_ir, wr_acc, mean_rt,
         n_probes, n_hits)

cat(sprintf("  Total block × condition rows : %d\n", nrow(block_scores)))

# ── Completeness check ──────────────────────────────────────────────────────────
# Friedman's test requires an unreplicated complete block design:
# exactly one observation per participant × treatment cell.
# Here: 3 blocks × 4 conditions = 12 cells per participant required.
expected_cells <- 3L * 4L   # 12 per participant

complete_pids <- block_scores %>%
  group_by(participant_id) %>%
  summarise(n_cells = n(), .groups = "drop") %>%
  filter(n_cells == expected_cells) %>%
  pull(participant_id)

n_total   <- length(unique(block_scores$participant_id))
n_dropped <- n_total - length(complete_pids)

cat(sprintf("\n  Completeness check (expecting %d cells per participant):\n", expected_cells))
cat(sprintf("    Complete : %d participants\n", length(complete_pids)))
cat(sprintf("    Dropped  : %d (incomplete block × condition cells)\n", n_dropped))

if (n_dropped > 0) {
  incomplete <- block_scores %>%
    group_by(participant_id) %>%
    summarise(n_cells = n(), .groups = "drop") %>%
    filter(n_cells != expected_cells)
  cat("  Incomplete participants:\n")
  print(as.data.frame(incomplete), row.names = FALSE)
}

block_scores <- block_scores %>% filter(participant_id %in% complete_pids)

cat(sprintf("\n  Final dataset : %d rows | %d participants\n",
            nrow(block_scores), length(unique(block_scores$participant_id))))
cat(sprintf("  Corrected IR  mean=%.3f  sd=%.3f  min=%.3f  max=%.3f\n",
            mean(block_scores$corrected_ir, na.rm = TRUE),
            sd(block_scores$corrected_ir,   na.rm = TRUE),
            min(block_scores$corrected_ir,  na.rm = TRUE),
            max(block_scores$corrected_ir,  na.rm = TRUE)))

# ── Save ────────────────────────────────────────────────────────────────────────
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
write.csv(block_scores, "data/processed/block_scores.csv", row.names = FALSE)
cat(sprintf("  Saved -> data/processed/block_scores.csv  (%d rows)\n", nrow(block_scores)))

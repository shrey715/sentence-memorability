# 04_finalize_dataset.R
# Final preprocessing step: drops rows from blocks that failed validation,
# then parses noun condition and voice from the stimulus ID string.
#
# Stimulus ID format: <condition>_<number>_<voice_suffix>
#   e.g. "HVL_3_A"  -> noun_condition = "HL", voice = "Active"
#   e.g. "LVH_12_P" -> noun_condition = "LH", voice = "Passive"
#
# Note: stimulus labels were renamed mid-experiment (HVL -> HL, LVH -> LH,
# LVL -> LL). The normalization below harmonizes both naming schemes.
#
# Input:  data/processed/pruned_data.csv
# Output: data/processed/final_data.csv

library(dplyr)
library(stringr)

cat("\n[04_finalize_dataset] Normalizing conditions and parsing voice...\n")

df <- read.csv("data/processed/pruned_data.csv", stringsAsFactors = FALSE)
rows_before <- nrow(df)
cat(sprintf("  Input rows : %d\n", rows_before))

# ── Drop failed blocks ───────────────────────────────────────────────────────
# Removes all rows belonging to blocks that failed the validation formula.
# This is the actual exclusion step flagged in script 03.
failed_blocks <- sum(df$block_valid == FALSE | is.na(df$block_valid))
df <- df %>% filter(block_valid == TRUE) %>% select(-block_valid)
cat(sprintf("  Rows from failed blocks excluded : %d\n", failed_blocks))
cat(sprintf("  Rows retained                   : %d\n", nrow(df)))

# ── Parse condition and voice from stimulus ID ────────────────────────────────
# Extract the prefix (condition) and suffix (_A / _P) from the stimulus ID.
# Normalize legacy condition labels to the final 4-level scheme: HH/HL/LH/LL.
df <- df %>%
  mutate(
    noun_condition_raw = str_extract(stimulus_id, "^[A-Za-z]+"),
    voice_code         = str_extract(stimulus_id, "[AP]$"),
    voice = case_when(voice_code == "A" ~ "Active", voice_code == "P" ~ "Passive", TRUE ~ NA_character_),
    noun_condition = case_when(
      noun_condition_raw %in% c("HL", "HVL") ~ "HL",
      noun_condition_raw %in% c("LH", "LVH") ~ "LH",
      noun_condition_raw %in% c("LL", "LVL") ~ "LL",
      TRUE ~ noun_condition_raw
    )
  ) %>% select(-noun_condition_raw, -voice_code)

cat("\n  Noun condition distribution (after normalization):\n")
cond_counts <- sort(table(df$noun_condition), decreasing = TRUE)
for (i in seq_along(cond_counts)) {
  cat(sprintf("    %-6s : %d rows\n", names(cond_counts)[i], cond_counts[i]))
}

cat("\n  Voice distribution:\n")
voice_counts <- table(df$voice)
for (i in seq_along(voice_counts)) {
  cat(sprintf("    %-10s : %d rows\n", names(voice_counts)[i], voice_counts[i]))
}
cat("\n  Voice distribution by noun condition:\n")
voice_cond_counts <- df %>%
  group_by(noun_condition, voice) %>%
  summarise(count = n(), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = voice, values_from = count, values_fill = 0)
print(as.data.frame(voice_cond_counts), row.names = FALSE)

cat(sprintf("\n  Final dataset : %d rows × %d cols | %d participants\n",
            nrow(df), ncol(df), length(unique(df$participant_id))))

write.csv(df, "data/processed/final_data.csv", row.names = FALSE)
cat("  Saved -> data/processed/final_data.csv\n")

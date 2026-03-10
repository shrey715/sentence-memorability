library(dplyr)

cat("\n[02_clean_events] Filtering events and assigning block IDs...\n")

df <- read.csv("data/processed/combined_data.csv", stringsAsFactors = FALSE)
rows_before <- nrow(df)
cat(sprintf("  Input rows : %d\n", rows_before))

df <- df %>%
  filter(!grepl("^Practice", event_type), event_type != "gap_time")
rows_after_filter <- nrow(df)
cat(sprintf("  Removed practice/gap_time rows : %d  (%.1f%%)\n",
            rows_before - rows_after_filter,
            100 * (rows_before - rows_after_filter) / rows_before))

df <- df %>%
  group_by(participant_id) %>%
  mutate(block_id = cumsum(event_type == "Rest Phase started") + 1L) %>%
  filter(block_id <= 3L) %>%
  ungroup()

rows_final <- nrow(df)
cat(sprintf("  Rows after block capping (<=3)  : %d\n", rows_final))

block_counts <- df %>%
  group_by(participant_id, block_id) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(block_id) %>%
  summarise(participants = n(), min_rows = min(n), median_rows = median(n), max_rows = max(n), .groups = "drop")
cat("\n  Rows per block (across participants):\n")
print(as.data.frame(block_counts), row.names = FALSE)

target_enc_counts <- df %>%
  filter(event_type == "Sentence shown",
         is_target_sentence == TRUE | is_target_sentence == "TRUE",
         is.na(is_probe_repeat) | is_probe_repeat == FALSE | is_probe_repeat == "FALSE") %>%
  group_by(participant_id) %>%
  summarise(n_targets = n(), .groups = "drop")
cat(sprintf("\n  Target sentences at encoding (expecting 48 per participant):\n"))
cat(sprintf("    min=%.0f  median=%.0f  max=%.0f  n_participants=%d\n",
            min(target_enc_counts$n_targets),
            median(target_enc_counts$n_targets),
            max(target_enc_counts$n_targets),
            nrow(target_enc_counts)))

write.csv(df, "data/processed/cleaned_data.csv", row.names = FALSE)
cat(sprintf("  Saved -> data/processed/cleaned_data.csv\n"))

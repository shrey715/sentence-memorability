# 03_validate_participants.R
# Applies the pre-registered block-level attentiveness check to flag blocks
# where the participant failed to detect validation repeats.
#
# Validation formula (per block):
#   Correct validation presses > (Wrong IR presses / 2) + Missed validations
#
# Flagged blocks are tagged block_valid = FALSE and excluded in script 04.
#
# Input:  data/processed/cleaned_data.csv
# Output: data/processed/pruned_data.csv
#         data/processed/validation_report.csv

library(dplyr)

cat("\n[03_validate_participants] Applying block-level validation formula...\n")

df <- read.csv("data/processed/cleaned_data.csv")
cat(sprintf("  Input rows : %d from %d participants\n",
            nrow(df), length(unique(df$participant_id))))

# ── Count validation event types per participant × block ─────────────────────
# "Validation IR pressed"       = correct detection (hit)
# "Validation Wrong IR pressed" = false alarm on a non-repeat
# "Validation Missed"           = failed to press on a validation repeat
validation_counts <- df %>%
  group_by(participant_id, block_id) %>%
  summarise(
    correct_val = sum(event_type == "Validation IR pressed"),
    wrong_ir    = sum(event_type == "Validation Wrong IR pressed"),
    missed_val  = sum(event_type == "Validation Missed"),
    .groups     = "drop"
  )

# ── Apply validation formula ─────────────────────────────────────────────────
# A block passes only if correct detections exceed the weighted error rate.
# This is the pre-registered attentiveness threshold.
validation_counts <- validation_counts %>%
  mutate(
    threshold   = (wrong_ir / 2) + missed_val,
    block_valid = correct_val > threshold
  )

cat("\n  Block-level validation (formula: Correct > Wrong/2 + Missed):\n")
block_summary <- validation_counts %>%
  group_by(block_id, block_valid) %>%
  summarise(n_participants = n(), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = block_valid, values_from = n_participants,
                     names_prefix = "valid=", values_fill = 0)
print(as.data.frame(block_summary), row.names = FALSE)

participant_summary <- validation_counts %>%
  group_by(participant_id) %>%
  summarise(
    total_blocks  = n(),
    blocks_passed = sum(block_valid),
    all_pass      = all(block_valid),
    .groups       = "drop"
  )

n_total    <- nrow(participant_summary)
n_all_pass <- sum(participant_summary$all_pass)
n_partial  <- sum(!participant_summary$all_pass)
cat(sprintf("\n  Participants total     : %d\n", n_total))
cat(sprintf("  All 3 blocks passed   : %d  (%.1f%%)\n", n_all_pass, 100*n_all_pass/n_total))
cat(sprintf("  Partial/failed blocks : %d  (%.1f%%)\n", n_partial,  100*n_partial/n_total))

# Save text summary to outputs/stats/
if (exists("stat_dir")) {
  writeLines(
    c("Block-Level Validation Summary",
      "==============================",
      capture.output(print(as.data.frame(validation_counts), row.names = FALSE)),
      "",
      "Participant-Level Summary",
      "=========================",
      capture.output(print(as.data.frame(participant_summary), row.names = FALSE))
    ),
    file.path(stat_dir, "validation_summary.txt")
  )
  cat(sprintf("  Saved -> %s/validation_summary.txt\n", stat_dir))
}

df <- df %>% left_join(validation_counts %>% select(participant_id, block_id, block_valid), by = c("participant_id", "block_id"))

write.csv(validation_counts, "data/processed/validation_report.csv", row.names = FALSE)
write.csv(df, "data/processed/pruned_data.csv", row.names = FALSE)
cat("  Saved -> data/processed/validation_report.csv, pruned_data.csv\n")

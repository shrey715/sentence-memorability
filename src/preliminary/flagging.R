# now to analyse all the types of sentences (target, validation, etc) and find invalid participants
# load the cleaned data with practice rows removed
library(dplyr)

processed_data <- read.csv("data/processed/cleaned_data.csv")

# ── Step 1: Sentence type counts per participant (sanity check) ───────────────
sentence_counts <- processed_data |>
  filter(Event == "Sentence shown") |>
  group_by(participant_id) |>
  summarise(
    n_target_enc   = sum(isTarget == TRUE  & (is.na(isRepeat) | isRepeat == FALSE)),
    n_target_probe = sum(isTarget == TRUE  & isRepeat == TRUE),
    n_validation   = sum(isValidation == TRUE & isRepeat == TRUE),  # validation repeats
    n_filler       = sum(isTarget == FALSE & isValidation == FALSE),
    n_total        = n(),
    .groups = "drop"
  )
cat("── Sentence type breakdown per participant (first 6):\n")
print(head(sentence_counts))

cat("\nSummary across all participants:\n")
print(summary(sentence_counts[, -1]))

# ── Step 2: Compute validation counts per participant × block ─────────────────
# Three event types feed into the formula:
#   "Validation IR pressed"       → correct_val  (hit on a validation repeat)
#   "Validation Wrong IR pressed" → wrong_ir      (spacebar on a non-repeat)
#   "Validation Missed"           → missed_val    (no spacebar on a validation repeat)

validation_counts <- processed_data |>
  filter(block_id %in% c(1, 2, 3)) |>
  group_by(participant_id, block_id) |>
  summarise(
    correct_val = sum(Event == "Validation IR pressed"),
    wrong_ir    = sum(Event == "Validation Wrong IR pressed"),
    missed_val  = sum(Event == "Validation Missed"),
    .groups     = "drop"
  )
cat("\n── Validation counts (first 10 rows):\n")
print(head(validation_counts, 10))

# ── Step 3: Apply validation formula ─────────────────────────────────────────
# correct_val > (wrong_ir / 2) + missed_val
validation_counts <- validation_counts |>
  mutate(
    threshold   = (wrong_ir / 2) + missed_val,
    block_valid = correct_val > threshold
  )
cat("\n── Validation results (first 10 rows):\n")
print(head(validation_counts, 10))

# ── Step 4: Block-level pass/fail summary ─────────────────────────────────────
cat("\n── Block-level pass/fail:\n")
block_summary <- validation_counts |>
  group_by(block_id) |>
  summarise(
    n_pass    = sum(block_valid),
    n_fail    = sum(!block_valid),
    pass_rate = round(mean(block_valid) * 100, 1),
    .groups   = "drop"
  )
print(block_summary)

# ── Step 5: Participant-level summary ─────────────────────────────────────────
participant_summary <- validation_counts |>
  group_by(participant_id) |>
  summarise(
    blocks_passed = sum(block_valid),
    blocks_failed = sum(!block_valid),
    all_pass      = all(block_valid),
    .groups       = "drop"
  )

cat("\n── Participants by number of valid blocks:\n")
print(table(participant_summary$blocks_passed))

cat(sprintf("\nAll 3 blocks valid  : %d participants\n", sum(participant_summary$all_pass)))
cat(sprintf("1-2 blocks valid    : %d participants\n", sum(!participant_summary$all_pass & participant_summary$blocks_passed > 0)))
cat(sprintf("0 blocks valid      : %d participants\n", sum(participant_summary$blocks_passed == 0)))

# ── Step 6: Flag failing blocks in detail ────────────────────────────────────
cat("\n── Failed blocks (showing why each failed):\n")
failed <- validation_counts |>
  filter(!block_valid) |>
  arrange(participant_id, block_id)
print(failed)

cat(sprintf("\nTotal valid blocks   : %d / %d (%.1f%%)\n",
    sum(validation_counts$block_valid),
    nrow(validation_counts),
    mean(validation_counts$block_valid) * 100))

# ── Step 7: Attach block_valid back to trial data ────────────────────────────
# This is the key column every downstream script filters on.
processed_data <- processed_data |>
  left_join(
    validation_counts |> select(participant_id, block_id, block_valid),
    by = c("participant_id", "block_id")
  )

cat(sprintf("\nblock_valid attached: TRUE=%d  FALSE=%d  NA=%d\n",
    sum(processed_data$block_valid == TRUE,  na.rm = TRUE),
    sum(processed_data$block_valid == FALSE, na.rm = TRUE),
    sum(is.na(processed_data$block_valid))))

# ── Step 8: Save ──────────────────────────────────────────────────────────────
write.csv(processed_data,       "data/processed/pruned_data.csv",         row.names = FALSE)
write.csv(validation_counts,    "data/processed/validation_report.csv",     row.names = FALSE)
write.csv(participant_summary,  "data/processed/participant_validity.csv",  row.names = FALSE)

cat("\nSaved: pruned_data.csv, validation_report.csv, participant_validity.csv\n")


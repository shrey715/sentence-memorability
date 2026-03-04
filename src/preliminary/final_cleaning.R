# loading the pruned data, to basically work with all the non-excluded blocks and participants
processed_data <- read.csv("data/processed/pruned_data.csv")

processed_data$participant_id <- NULL

processed_data <- processed_data |>
  dplyr::rename(
    participant_id            = participant_ID,
    event_timestamp_ms        = Timestamp,
    event_type                = Event,
    stimulus_id               = Stimulus,
    is_target_sentence        = isTarget,
    is_validation_sentence    = isValidation,
    is_probe_repeat           = isRepeat,
    response_button           = Button,
    ir_accuracy               = Accuracy.IR,
    wr_accuracy               = Accuracy.WR,
    ir_reaction_time_ms       = Reaction_time_IR,
    wr_reaction_time_ms       = Reaction_time_WR,
    ir_corrected_recognition  = CR_IR,
    wr_corrected_recognition  = CR_WR,
    block_id                  = block_id,
    block_passed_validation   = block_valid
  )

# ── Drop all rows from invalid blocks ─────────────────────────────────────────
rows_before <- nrow(processed_data)

processed_data <- processed_data[processed_data$block_passed_validation == TRUE, ]

cat(sprintf("Rows before exclusion : %d\n", rows_before))
cat(sprintf("Rows after exclusion  : %d\n", nrow(processed_data)))
cat(sprintf("Rows dropped          : %d  (from failed blocks)\n",
            rows_before - nrow(processed_data)))

# block_passed_validation is now redundant — every remaining row is TRUE
processed_data$block_passed_validation <- NULL

cat("\nFinal column names:\n")
print(colnames(processed_data))

cat(sprintf("\nFinal dimensions: %d rows × %d columns\n",
            nrow(processed_data), ncol(processed_data)))

cat(sprintf("Participants remaining: %d\n",
            length(unique(processed_data$participant_id))))

cat(sprintf("Valid blocks remaining: %d\n",
            nrow(unique(processed_data[, c("participant_id", "block_id")]))))

write.csv(processed_data, "data/processed/final_data.csv", row.names = FALSE)
cat("\nSaved: data/processed/final_data.csv\n")

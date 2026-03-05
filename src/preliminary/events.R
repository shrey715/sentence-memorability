library(dplyr)

processed_data <- read.csv("data/processed/combined_data.csv")

# ── Unique events (pre-removal audit) ────────────────────────────────────────
num_events <- length(unique(processed_data$Event))
print(paste("Number of unique events in the data:", num_events))

unique_events <- unique(processed_data$Event)
print("The unique events are:")
print(unique_events)

event_counts <- table(processed_data$Event)
print("Event counts for each unique event:")
print(event_counts)

# ── Drop practice rows AND gaptime in one pass ───────────────────────────────
# gaptime = ISI timing metadata only; carries no response fields, never used downstream
processed_data <- processed_data[!grepl("^Practice", processed_data$Event), ]
processed_data <- processed_data[processed_data$Event != "gap_time", ]

cat("Remaining events after practice + gaptime removal:\n")
event_counts <- table(processed_data$Event)
print(event_counts)

write.csv(processed_data, "data/processed/cleaned_data.csv", row.names = FALSE)

cat(sprintf(
  "\nRows remaining: %d  (removed %d practice + gaptime rows)\n",
  nrow(processed_data), 81329 - nrow(processed_data)
))

# ── Helper ───────────────────────────────────────────────────────────────────
get_count <- function(event_name) event_counts[event_name]

# ── Cross-verification: experimental invariants ───────────────────────────────
# Invariant 1 (gaptime == Sentence shown) REMOVED — gaptime no longer in data

cat("Invariant 2: Rest Phase started should be exactly 2 per participant\n")
rest_per_p <- processed_data |>
  dplyr::filter(Event == "Rest Phase started") |>
  dplyr::count(participant_id, name = "n_rest")
cat(sprintf("  Total Rest Phase rows : %d  (expected %d)\n",
    sum(rest_per_p$n_rest), 114 * 2))
off_rest <- rest_per_p[rest_per_p$n_rest != 2, ]
if (nrow(off_rest) == 0) {
  cat("  All participants have exactly 2 Rest Phase events.\n\n")
} else {
  cat("  Deviating participants:\n")
  print(off_rest)
  cat("\n")
}

cat("Invariant 3: IR pressed == WR pressed (WR always follows IR)\n")
cat(sprintf("  IR pressed : %d\n", get_count("IR pressed")))
cat(sprintf("  WR pressed : %d\n", get_count("WR pressed")))
cat(sprintf("  Match: %s\n\n",
    get_count("IR pressed") == get_count("WR pressed")))

cat("Invariant 4: Target probes should be exactly 48 per participant\n")
target_probes <- processed_data |>
  dplyr::filter(
    Event    == "Sentence shown",
    isTarget == TRUE,
    isRepeat == TRUE
  ) |>
  dplyr::count(participant_id, name = "n_probes")

cat(sprintf("  Total target probe rows : %d  (expected %d)\n",
    sum(target_probes$n_probes), 114 * 48))
cat("  Per-participant summary:\n")
print(summary(target_probes$n_probes))

off_probes <- target_probes[target_probes$n_probes != 48, ]
if (nrow(off_probes) == 0) {
  cat("  All participants have exactly 48 target probes.\n\n")
} else {
  cat("  Deviating participants:\n")
  print(off_probes)
  cat("\n")
}

cat("Invariant 5: Target encodings should also be exactly 48 per participant\n")
target_enc <- processed_data |>
  dplyr::filter(
    Event    == "Sentence shown",
    isTarget == TRUE,
    is.na(isRepeat)
  ) |>
  dplyr::count(participant_id, name = "n_encodings")

off_enc <- target_enc[target_enc$n_encodings != 48, ]
if (nrow(off_enc) == 0) {
  cat("  All participants have exactly 48 target encodings.\n\n")
} else {
  cat("  Deviating participants:\n")
  print(off_enc)
  cat("\n")
}

cat("Invariant 6: IR on target probes should be <= 48 per participant\n")
ir_on_probes <- processed_data |>
  dplyr::filter(
    Event    == "IR pressed",
    isTarget == TRUE,
    isRepeat == TRUE
  ) |>
  dplyr::count(participant_id, name = "n_ir_on_probes")

cat(sprintf("  Min: %d  |  Max: %d  |  Median: %.0f\n",
    min(ir_on_probes$n_ir_on_probes),
    max(ir_on_probes$n_ir_on_probes),
    median(ir_on_probes$n_ir_on_probes)))

ir_on_probes$n_missed <- 48 - ir_on_probes$n_ir_on_probes
cat(sprintf("  Total missed IR across all participants: %d\n",
    sum(ir_on_probes$n_missed)))
cat(sprintf("  Overall miss rate: %.1f%%\n\n",
    mean(ir_on_probes$n_missed / 48) * 100))

cat("Invariant 7: Sentence shown per participant should all be 222\n")
shown_per_p <- processed_data |>
  dplyr::filter(Event == "Sentence shown") |>
  dplyr::count(participant_id, name = "n_shown")
off_shown <- shown_per_p[shown_per_p$n_shown != 222, ]
if (nrow(off_shown) == 0) {
  cat("  All participants: exactly 222 Sentence shown.\n\n")
} else {
  cat("  Deviating participants:\n")
  print(off_shown)
  cat("\n")
}

assign_block_ids <- function(events) {
  block_vec <- integer(length(events))
  blk <- 1L
  for (i in seq_along(events)) {
    block_vec[i] <- blk
    if (events[i] == "Rest Phase started") blk <- blk + 1L
  }
  block_vec
}

processed_data <- processed_data |>
  dplyr::group_by(participant_id) |>
  dplyr::mutate(block_id = assign_block_ids(Event)) |>
  dplyr::ungroup()

# Sanity: exactly 3 blocks per participant
block_check <- processed_data |>
  dplyr::filter(Event != "Rest Phase started") |>
  dplyr::group_by(participant_id) |>
  dplyr::summarise(n_blocks = dplyr::n_distinct(block_id), .groups = "drop")

off_blocks <- block_check[block_check$n_blocks != 3, ]
if (nrow(off_blocks) == 0) {
  cat("All participants have exactly 3 blocks.\n")
} else {
  cat("Deviating participants:\n")
  print(off_blocks)
}

# Sanity: 16 target probes per block
probes_per_block <- processed_data |>
  dplyr::filter(Event == "Sentence shown", isTarget == TRUE, isRepeat == TRUE) |>
  dplyr::count(participant_id, block_id, name = "n_probes")

cat("\nTarget probes per block summary:\n")
print(summary(probes_per_block$n_probes))

off_block_probes <- probes_per_block[probes_per_block$n_probes != 16, ]
if (nrow(off_block_probes) == 0) {
  cat("All participants have exactly 16 target probes per block.\n\n")
} else {
  cat("Deviating participant-blocks:\n")
  print(off_block_probes)
}

processed_data <- processed_data[processed_data$Event != "Rest Phase started", ]
cat(sprintf("Rows after dropping Rest Phase: %d  (removed %d rows)\n",
    nrow(processed_data), 228))  # 2 rest rows × 114 participants

write.csv(processed_data, "data/processed/cleaned_data.csv", row.names = FALSE)
cat("Saved updated cleaned_data.csv with block_id column.\n")

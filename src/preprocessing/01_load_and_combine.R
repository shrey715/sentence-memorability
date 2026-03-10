library(dplyr)

cat("\n[01_load_and_combine] Loading raw participant log files...\n")

data_dir <- "data/raw"
files    <- list.files(data_dir, pattern = "\\.log$", full.names = TRUE)

if (length(files) == 0) stop("No .log files found in ", data_dir)
cat(sprintf("  Found %d .log files in '%s'\n", length(files), data_dir))

load_log <- function(file) {
  df <- read.csv(file, fileEncoding = "UTF-8-BOM", na.strings = "N/A", stringsAsFactors = FALSE)

  df <- df %>%
    rename(
      participant_id         = participant_ID,
      event_timestamp_ms     = Timestamp,
      event_type             = Event,
      stimulus_id            = Stimulus,
      is_target_sentence     = isTarget,
      is_validation_sentence = isValidation,
      is_probe_repeat        = isRepeat,
      response_button        = Button,
      ir_accuracy            = Accuracy.IR,
      wr_accuracy            = Accuracy.WR,
      ir_reaction_time_ms    = Reaction_time_IR,
      wr_reaction_time_ms    = Reaction_time_WR
    )

  bool_to_logical <- function(x) {
    v <- tolower(trimws(as.character(x)))
    dplyr::case_when(v == "true" ~ TRUE, v == "false" ~ FALSE, TRUE ~ NA)
  }

  df$is_target_sentence     <- bool_to_logical(df$is_target_sentence)
  df$is_probe_repeat        <- bool_to_logical(df$is_probe_repeat)
  df$is_validation_sentence <- bool_to_logical(df$is_validation_sentence)

  return(df)
}

combined_data <- bind_rows(lapply(files, load_log)) %>% select(participant_id, everything())

n_participants <- length(unique(combined_data$participant_id))
n_rows         <- nrow(combined_data)
n_cols         <- ncol(combined_data)

cat(sprintf("  Loaded    : %d rows, %d columns, %d participants\n", n_rows, n_cols, n_participants))
cat(sprintf("  Columns   : %s\n", paste(names(combined_data), collapse = ", ")))

rows_per_pid <- combined_data %>%
  count(participant_id, name = "n_rows") %>%
  summarise(min = min(n_rows), median = median(n_rows), max = max(n_rows))
cat(sprintf("  Rows/participant  min=%d  median=%.0f  max=%d\n",
            rows_per_pid$min, rows_per_pid$median, rows_per_pid$max))

cat(sprintf("  Event types present:\n"))
event_counts <- sort(table(combined_data$event_type), decreasing = TRUE)
for (i in seq_along(event_counts)) {
  cat(sprintf("    %-40s %d\n", names(event_counts)[i], event_counts[i]))
}

write.csv(combined_data, "data/processed/combined_data.csv", row.names = FALSE)
cat(sprintf("  Saved -> data/processed/combined_data.csv\n")
)

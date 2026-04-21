suppressPackageStartupMessages({
  library(dplyr)
})

cat("\n[glm/01] Preparing GLM cell-level dataset...\n")

final_df <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)
cr_scores <- read.csv("data/processed/cr_scores.csv", stringsAsFactors = FALSE)

is_true <- function(x) {
  x == TRUE | x == "TRUE"
}

target_probes <- final_df %>%
  filter(
    event_type == "Sentence shown",
    is_true(is_target_sentence),
    is_true(is_probe_repeat),
    noun_condition %in% c("HH", "HL", "LH", "LL"),
    voice %in% c("Active", "Passive")
  ) %>%
  arrange(participant_id, event_timestamp_ms) %>%
  group_by(participant_id) %>%
  mutate(trial_position = row_number()) %>%
  ungroup()

trial_pos_cell <- target_probes %>%
  group_by(participant_id, noun_condition, voice) %>%
  summarise(mean_trial_position = mean(trial_position, na.rm = TRUE), .groups = "drop")

glm_cell <- cr_scores %>%
  filter(
    noun_condition %in% c("HH", "HL", "LH", "LL"),
    voice %in% c("Active", "Passive")
  ) %>%
  left_join(trial_pos_cell, by = c("participant_id", "noun_condition", "voice")) %>%
  transmute(
    participant_id,
    noun_condition,
    voice,
    corrected_ir = ir_cr,
    wr_accuracy = wr_acc_score,
    mean_rt = ir_rt,
    mean_trial_position
  )

n_participants <- dplyr::n_distinct(glm_cell$participant_id)
complete_cells <- glm_cell %>%
  count(participant_id, name = "n_cells") %>%
  summarise(n_complete = sum(n_cells == 8L), n_incomplete = sum(n_cells != 8L))

cat(sprintf("  Rows: %d | Participants: %d\n", nrow(glm_cell), n_participants))
cat(sprintf("  Complete 8-cell participants: %d | Incomplete: %d\n",
            complete_cells$n_complete, complete_cells$n_incomplete))
cat(sprintf("  Missing mean_rt: %d | Missing mean_trial_position: %d\n",
            sum(is.na(glm_cell$mean_rt)), sum(is.na(glm_cell$mean_trial_position))))

write.csv(glm_cell, "data/processed/glm_cell_data.csv", row.names = FALSE)
cat("  Saved -> data/processed/glm_cell_data.csv\n")

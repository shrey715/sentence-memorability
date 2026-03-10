cat("\n[06a_data_checks] Data integrity crosschecks...\n")

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(tidyr)
})

df <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)
dir.create("outputs/plots", showWarnings = FALSE, recursive = TRUE)

# ── Encoding targets only ─────────────────────────────────────────────────────
# (Sentence shown, is_target_sentence = TRUE, not a probe repeat)
enc <- df %>%
  filter(
    event_type         == "Sentence shown",
    is_target_sentence == TRUE | is_target_sentence == "TRUE",
    is.na(is_probe_repeat) | is_probe_repeat == FALSE | is_probe_repeat == "FALSE"
  )

n_participants <- length(unique(df$participant_id))
cat(sprintf("  Participants in final data : %d\n", n_participants))
cat(sprintf("  Total encoding target rows : %d\n", nrow(enc)))

# ── 1. Sentences per participant (expect 48) ─────────────────────────────────
cat("  [1/4] Sentences per participant...\n")
per_part <- enc %>%
  group_by(participant_id) %>%
  summarise(n_sentences = n(), .groups = "drop")

cat(sprintf("    min=%d  median=%.0f  max=%d  (expected: 48 per participant)\n",
            min(per_part$n_sentences),
            median(per_part$n_sentences),
            max(per_part$n_sentences)))

ggplot(per_part, aes(x = n_sentences)) +
  geom_histogram(binwidth = 1, fill = "gray50", colour = "white") +
  geom_vline(aes(xintercept = 48, linetype = "Expected (48)"), colour = "black", linewidth = 0.8) +
  scale_linetype_manual(name = NULL, values = c("Expected (48)" = "dashed")) +
  labs(title = "Target Sentences Shown per Participant",
       x = "Number of sentences", y = "Number of participants") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), legend.position = "top")
ggsave("outputs/plots/00a_sentences_per_participant.png", width = 7, height = 5, dpi = 200)
cat("  Saved -> outputs/plots/00a_sentences_per_participant.png\n")

# ── 2. Distribution by noun condition ───────────────────────────────────────
cat("  [2/4] Distribution by noun condition...\n")
cond_dist <- enc %>%
  filter(noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
  count(noun_condition) %>%
  mutate(noun_condition = factor(noun_condition, levels = c("HH", "HL", "LH", "LL")))

cat("    Noun condition counts (encoding trials):\n")
for (i in seq_len(nrow(cond_dist))) {
  cat(sprintf("      %-4s : %d\n", cond_dist$noun_condition[i], cond_dist$n[i]))
}

ggplot(cond_dist, aes(x = noun_condition, y = n)) +
  geom_col(width = 0.6, fill = "gray50", colour = "white") +
  geom_text(aes(label = n), vjust = -0.4, size = 4) +
  labs(title = "Encoding Trials by Noun Condition",
       x = "Noun Condition", y = "Total encoding trials") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"))
ggsave("outputs/plots/00b_trials_by_noun_condition.png", width = 7, height = 5, dpi = 200)
cat("  Saved -> outputs/plots/00b_trials_by_noun_condition.png\n")

# ── 3. Distribution by voice ─────────────────────────────────────────────────
cat("  [3/4] Distribution by voice...\n")
voice_dist <- enc %>%
  filter(!is.na(voice)) %>%
  count(voice)

cat("    Voice counts (encoding trials):\n")
for (i in seq_len(nrow(voice_dist))) {
  cat(sprintf("      %-8s : %d\n", voice_dist$voice[i], voice_dist$n[i]))
}

ggplot(voice_dist, aes(x = voice, y = n)) +
  geom_col(width = 0.5, fill = "gray50", colour = "white") +
  geom_text(aes(label = n), vjust = -0.4, size = 4) +
  labs(title = "Encoding Trials by Voice",
       x = "Voice", y = "Total encoding trials") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"))
ggsave("outputs/plots/00c_trials_by_voice.png", width = 7, height = 5, dpi = 200)
cat("  Saved -> outputs/plots/00c_trials_by_voice.png\n")

# ── 4. Condition × Voice crosscheck ─────────────────────────────────────────
cat("  [4/4] Condition x Voice crosscheck...\n")
cross <- enc %>%
  filter(noun_condition %in% c("HH", "HL", "LH", "LL"), !is.na(voice)) %>%
  count(noun_condition, voice) %>%
  mutate(noun_condition = factor(noun_condition, levels = c("HH", "HL", "LH", "LL")))

cat("    Condition x Voice table:\n")
cross_wide <- cross %>%
  pivot_wider(names_from = voice, values_from = n, values_fill = 0L)
print(as.data.frame(cross_wide), row.names = FALSE)

# Active/Passive: filled vs. outline — dark fill for active (unmarked), light for passive (marked)
ggplot(cross, aes(x = noun_condition, y = n, fill = voice)) +
  geom_col(position = position_dodge(width = 0.65), width = 0.55, colour = "gray30") +
  geom_text(aes(label = n), position = position_dodge(width = 0.65),
            vjust = -0.4, size = 3.5) +
  scale_fill_manual(
    values = c(Active = "gray30", Passive = "gray80"),
    name   = "Voice"
  ) +
  labs(title = "Encoding Trials: Noun Condition × Voice",
       x = "Noun Condition", y = "Total encoding trials") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), legend.position = "top")
ggsave("outputs/plots/00d_trials_condition_by_voice.png", width = 7, height = 5, dpi = 200)
cat("  Saved -> outputs/plots/00d_trials_condition_by_voice.png\n")

cat("  [06a_data_checks] Done.\n")

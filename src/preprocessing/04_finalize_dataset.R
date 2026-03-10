library(dplyr)
library(stringr)

cat("\n[04_finalize_dataset] Normalizing conditions, parsing voice, trimming RT outliers...\n")

df <- read.csv("data/processed/pruned_data.csv", stringsAsFactors = FALSE)
rows_before <- nrow(df)
cat(sprintf("  Input rows : %d\n", rows_before))

failed_blocks <- sum(df$block_valid == FALSE | is.na(df$block_valid))
df <- df %>% filter(block_valid == TRUE) %>% select(-block_valid)
cat(sprintf("  Rows from failed blocks excluded : %d\n", failed_blocks))
cat(sprintf("  Rows retained                   : %d\n", nrow(df)))

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

na_ir_before <- sum(is.na(df$ir_reaction_time_ms))
na_wr_before <- sum(is.na(df$wr_reaction_time_ms))

df <- df %>%
  group_by(participant_id) %>%
  mutate(
    ir_rt_mean = mean(ir_reaction_time_ms, na.rm = TRUE),
    ir_rt_sd   = sd(ir_reaction_time_ms,   na.rm = TRUE),
    wr_rt_mean = mean(wr_reaction_time_ms, na.rm = TRUE),
    wr_rt_sd   = sd(wr_reaction_time_ms,   na.rm = TRUE)
  ) %>%
  ungroup() %>%
  mutate(
    ir_reaction_time_ms = if_else(!is.na(ir_reaction_time_ms) & (ir_reaction_time_ms < 200 | ir_reaction_time_ms > ir_rt_mean + 3 * ir_rt_sd), NA_real_, ir_reaction_time_ms),
    wr_reaction_time_ms = if_else(!is.na(wr_reaction_time_ms) & (wr_reaction_time_ms < 200 | wr_reaction_time_ms > wr_rt_mean + 3 * wr_rt_sd), NA_real_, wr_reaction_time_ms)
  ) %>% select(-ir_rt_mean, -ir_rt_sd, -wr_rt_mean, -wr_rt_sd)

ir_trimmed <- sum(is.na(df$ir_reaction_time_ms)) - na_ir_before
wr_trimmed <- sum(is.na(df$wr_reaction_time_ms)) - na_wr_before
cat(sprintf("\n  RT outliers trimmed (< 200ms or > mean+3SD per participant):\n"))
cat(sprintf("    IR reaction time : %d values set to NA\n", ir_trimmed))
cat(sprintf("    WR reaction time : %d values set to NA\n", wr_trimmed))

cat(sprintf("\n  Final dataset : %d rows × %d cols | %d participants\n",
            nrow(df), ncol(df), length(unique(df$participant_id))))

write.csv(df, "data/processed/final_data.csv", row.names = FALSE)
cat("  Saved -> data/processed/final_data.csv\n")

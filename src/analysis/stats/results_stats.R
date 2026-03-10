# results_stats.R - Corrected Recognition scores, advanced descriptives,
#                   and normality checks
#
# Signal-detection structure for this experiment:
#   IR = Immediate Recognition (spacebar press on a probe)
#     - Hit   : IR pressed on TARGET probe  (is_target=T, is_probe_repeat=T)
#     - FA    : IR pressed on HF FILLER FIRST SHOWING (noun_condition=="HF",
#               is_probe_repeat=NA — first time the filler is seen)
#     - Hit Rate    = n(IR hits) / n(target probes shown)
#     - IR FA Rate  = n(IR presses on HF first-showings) / n(HF first-showings)
#
#   WR = Wording Recognition (separate key — always co-pressed with IR)
#     The meaningful WR signal is in wr_accuracy:
#       wr_accuracy=1 → exact-voice repeat recognized (correct wording)
#       wr_accuracy=0 → voice-changed probe pressed (wrong wording / different form)
#     - WR Hit Rate = n(WR pressed, wr_accuracy=1, target probe) / n(target probes)
#     - WR FA Rate  = n(WR pressed on HF first-showings) / n(HF first-showings)

cat("\n[results_stats] Computing CR scores, descriptives, and normality checks...\n")

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(moments)
})

df <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)
df$is_target_sentence <- df$is_target_sentence == "TRUE"
cat(sprintf("  Input rows : %d | participants : %d\n",
            nrow(df), length(unique(df$participant_id))))

# ── 1. Global IR FA Rates ──────────────────────────────────────────────────
cat("\n  [1/7] Computing IR false alarm rates from HF first-showings...\n")
hf_first_shown <- df %>% filter(event_type == "Sentence shown", noun_condition == "HF", is.na(is_probe_repeat)) %>% count(participant_id, name = "n_hf_first")
ir_fa_counts   <- df %>% filter(event_type == "IR pressed",    noun_condition == "HF", is.na(is_probe_repeat)) %>% count(participant_id, name = "n_ir_fa")

fa_rates <- hf_first_shown %>%
  left_join(ir_fa_counts, by = "participant_id") %>%
  mutate(n_ir_fa = replace_na(n_ir_fa, 0), ir_fa_rate = n_ir_fa / n_hf_first) %>%
  select(participant_id, ir_fa_rate)

cat(sprintf("    HF first-showings per participant  min=%.0f  max=%.0f\n",
            min(hf_first_shown$n_hf_first), max(hf_first_shown$n_hf_first)))
cat(sprintf("    IR FA rate  mean=%.3f  sd=%.3f  min=%.3f  max=%.3f\n",
            mean(fa_rates$ir_fa_rate), sd(fa_rates$ir_fa_rate),
            min(fa_rates$ir_fa_rate), max(fa_rates$ir_fa_rate)))

# ── 2. Target IR Hits ──────────────────────────────────────────────────────
cat("\n  [2/7] Counting IR hits on target probes...\n")
target_probes <- df %>% filter(event_type == "Sentence shown", is_target_sentence == TRUE, is_probe_repeat == "TRUE") %>% count(participant_id, noun_condition, voice, name = "n_target_probes")
ir_hits       <- df %>% filter(event_type == "IR pressed",    is_target_sentence == TRUE, is_probe_repeat == "TRUE") %>% count(participant_id, noun_condition, voice, name = "n_ir_hits")
cat(sprintf("    Target probe rows : %d | IR hit rows : %d\n", nrow(target_probes), nrow(ir_hits)))

# ── 3. WR Accuracy conditional on IR ──────────────────────────────────────
cat("\n  [3/7] Computing WR conditional accuracy (wr_accuracy==1)...\n")
wr_accuracy_data <- df %>%
  filter(event_type == "WR pressed", is_target_sentence == TRUE, is_probe_repeat == "TRUE") %>%
  group_by(participant_id, noun_condition, voice) %>%
  summarise(n_wr_trials = n(), n_wr_correct = sum(wr_accuracy == 1, na.rm = TRUE),
            wr_acc_score = n_wr_correct / n_wr_trials, .groups = "drop")
cat(sprintf("    WR trials recorded : %d | mean wr_acc_score : %.3f\n",
            nrow(wr_accuracy_data), mean(wr_accuracy_data$wr_acc_score, na.rm = TRUE)))

# ── 4. Mean RTs ────────────────────────────────────────────────────────────
cat("\n  [4/7] Computing mean reaction times per condition × voice...\n")
mean_rts <- df %>%
  filter(is_target_sentence == TRUE, is_probe_repeat == "TRUE") %>%
  group_by(participant_id, noun_condition, voice) %>%
  summarise(
    ir_rt = mean(ir_reaction_time_ms[event_type == "IR pressed"], na.rm = TRUE),
    wr_rt = mean(wr_reaction_time_ms[event_type == "WR pressed"], na.rm = TRUE),
    .groups = "drop"
  )

# ── 5. Compile CR Scores ───────────────────────────────────────────────────
cat("\n  [5/7] Compiling final CR score table...\n")
cr_scores <- target_probes %>%
  left_join(ir_hits,         by = c("participant_id","noun_condition","voice")) %>%
  left_join(wr_accuracy_data,by = c("participant_id","noun_condition","voice")) %>%
  left_join(fa_rates,        by = "participant_id") %>%
  left_join(mean_rts,        by = c("participant_id","noun_condition","voice")) %>%
  mutate(
    n_ir_hits   = replace_na(n_ir_hits, 0),
    ir_hit_rate = n_ir_hits / n_target_probes,
    ir_cr       = ir_hit_rate - ir_fa_rate
  ) %>% select(participant_id, noun_condition, voice, ir_cr, wr_acc_score, ir_rt, wr_rt)

cat(sprintf("    CR score table : %d rows × %d cols\n", nrow(cr_scores), ncol(cr_scores)))
cat("\n    IR CR score summary:\n")
print(summary(cr_scores$ir_cr))
cat("\n    WR accuracy score summary:\n")
print(summary(cr_scores$wr_acc_score))
cat("\n    NA counts per column:\n")
na_counts <- colSums(is.na(cr_scores))
print(na_counts[na_counts > 0])

# ── 6. Descriptive Statistics ──────────────────────────────────────────────
cat("\n  [6/7] Computing per-condition descriptive statistics...\n")
make_summary <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 3) return(tibble(N=length(x), Mean=NA, Median=NA, Min=NA, Max=NA, IQR=NA, Skewness=NA, Kurtosis=NA))
  tibble(N=length(x), Mean=round(mean(x),4), Median=round(median(x),4), Min=round(min(x),4),
         Max=round(max(x),4), IQR=round(IQR(x),4), Skewness=round(skewness(x),3), Kurtosis=round(kurtosis(x),3))
}

summary_table <- cr_scores %>%
  pivot_longer(cols = c(ir_cr, wr_acc_score, ir_rt, wr_rt), names_to = "metric", values_to = "value") %>%
  group_by(noun_condition, voice, metric) %>%
  summarise(make_summary(value), .groups = "drop")

cat("\n    Descriptive statistics table:\n")
print(as.data.frame(summary_table), row.names = FALSE)

# ── 7. Normality (Shapiro-Wilk) ────────────────────────────────────────────
cat("\n  [7/7] Shapiro-Wilk normality tests...\n")
shapiro_results <- cr_scores %>%
  pivot_longer(cols = c(ir_cr, wr_acc_score, ir_rt, wr_rt), names_to = "metric", values_to = "value") %>%
  group_by(metric) %>%
  summarise(
    n       = sum(!is.na(value)),
    W       = { v <- value[!is.na(value)]; if(length(v) >= 3) shapiro.test(v)$statistic else NA },
    p_value = { v <- value[!is.na(value)]; if(length(v) >= 3) shapiro.test(v)$p.value   else NA },
    .groups = "drop"
  ) %>%
  mutate(normal = ifelse(is.na(p_value), NA, p_value > 0.05),
         conclusion = case_when(
           is.na(p_value) ~ "Insufficient data",
           p_value > 0.05 ~ "Normal (p > .05)",
           TRUE           ~ "Non-normal (p < .05)"
         ))

print(as.data.frame(shapiro_results), row.names = FALSE)
non_normal <- sum(!shapiro_results$normal, na.rm = TRUE)
cat(sprintf("\n    %d/%d metrics are non-normal -> non-parametric tests justified.\n",
            non_normal, nrow(shapiro_results)))

# ── Save to outputs/stats/ ─────────────────────────────────────────────────
if (exists("stat_dir")) {
  writeLines(
    c("FA Rate Summary", "===============",
      capture.output(print(as.data.frame(fa_rates), row.names = FALSE))),
    file.path(stat_dir, "fa_rates.txt")
  )
  writeLines(
    c("Descriptive Statistics per Condition × Voice × Metric",
      "======================================================",
      capture.output(print(as.data.frame(summary_table), row.names = FALSE))),
    file.path(stat_dir, "descriptives.txt")
  )
  writeLines(
    c("Shapiro-Wilk Normality Tests", "=============================",
      capture.output(print(as.data.frame(shapiro_results), row.names = FALSE))),
    file.path(stat_dir, "normality.txt")
  )
  cat(sprintf("\n  Saved tables -> %s/{fa_rates,descriptives,normality}.txt\n", stat_dir))
}

# ── Save CSVs ──────────────────────────────────────────────────────────────
write.csv(cr_scores,    "data/processed/cr_scores.csv",    row.names = FALSE)
write.csv(summary_table,"data/processed/stats_summary.csv", row.names = FALSE)
cat("  Saved -> data/processed/cr_scores.csv, stats_summary.csv\n")

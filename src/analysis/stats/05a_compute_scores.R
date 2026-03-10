# 05a_compute_scores.R
# Computes corrected recognition (CR) scores, WR accuracy, mean RTs,
# descriptive statistics, and Shapiro-Wilk normality checks.
#
# Inputs:  data/processed/final_data.csv
# Outputs: data/processed/cr_scores.csv
#          data/processed/descriptive_stats.csv
#          outputs/stats/fa_rates.txt
#          outputs/stats/descriptive_stats.txt
#          outputs/stats/normality.txt

cat("\n[05a_compute_scores] Computing CR scores, descriptives, and normality checks...\n")

suppressPackageStartupMessages({
    library(dplyr)
    library(tidyr)
})

df <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)
df$is_target_sentence <- df$is_target_sentence == "TRUE"
cat(sprintf(
    "  Input rows : %d | participants : %d\n",
    nrow(df), length(unique(df$participant_id))
))

# ── 1. Global IR False Alarm Rates ──────────────────────────────────────────
cat("\n  [1/5] Computing IR false alarm rates from HF first-showings...\n")
hf_first_shown <- df %>%
    filter(
        event_type == "Sentence shown",
        noun_condition == "HF",
        is.na(is_probe_repeat)
    ) %>%
    count(participant_id, name = "n_hf_first")

ir_fa_counts <- df %>%
    filter(
        event_type == "IR pressed",
        noun_condition == "HF",
        is.na(is_probe_repeat)
    ) %>%
    count(participant_id, name = "n_ir_fa")

fa_rates <- hf_first_shown %>%
    left_join(ir_fa_counts, by = "participant_id") %>%
    mutate(
        n_ir_fa = replace_na(n_ir_fa, 0),
        ir_fa_rate = n_ir_fa / n_hf_first
    ) %>%
    select(participant_id, ir_fa_rate)

cat(sprintf(
    "    HF first-showings per participant  min=%.0f  max=%.0f\n",
    min(hf_first_shown$n_hf_first), max(hf_first_shown$n_hf_first)
))
cat(sprintf(
    "    IR FA rate  mean=%.3f  sd=%.3f  min=%.3f  max=%.3f\n",
    mean(fa_rates$ir_fa_rate), sd(fa_rates$ir_fa_rate),
    min(fa_rates$ir_fa_rate), max(fa_rates$ir_fa_rate)
))

# ── 2. Target IR Hits ───────────────────────────────────────────────────────
cat("\n  [2/5] Counting IR hits on target probes...\n")
target_probes <- df %>%
    filter(
        event_type == "Sentence shown",
        is_target_sentence == TRUE,
        is_probe_repeat == "TRUE"
    ) %>%
    count(participant_id, noun_condition, voice, name = "n_target_probes")

ir_hits <- df %>%
    filter(
        event_type == "IR pressed",
        is_target_sentence == TRUE,
        is_probe_repeat == "TRUE"
    ) %>%
    count(participant_id, noun_condition, voice, name = "n_ir_hits")

cat(sprintf(
    "    Target probe rows : %d | IR hit rows : %d\n",
    nrow(target_probes), nrow(ir_hits)
))

# ── 3. WR Accuracy (conditional on IR) ──────────────────────────────────────
cat("\n  [3/5] Computing WR conditional accuracy...\n")
wr_accuracy_data <- df %>%
    filter(
        event_type == "WR pressed",
        is_target_sentence == TRUE,
        is_probe_repeat == "TRUE"
    ) %>%
    group_by(participant_id, noun_condition, voice) %>%
    summarise(
        n_wr_trials = n(),
        n_wr_correct = sum(wr_accuracy == 1, na.rm = TRUE),
        wr_acc_score = n_wr_correct / n_wr_trials,
        .groups = "drop"
    )

cat(sprintf(
    "    WR trials recorded : %d | mean wr_acc_score : %.3f\n",
    nrow(wr_accuracy_data),
    mean(wr_accuracy_data$wr_acc_score, na.rm = TRUE)
))

# ── 4. Mean Reaction Times ──────────────────────────────────────────────────
cat("\n  [4/5] Computing mean reaction times per condition x voice...\n")
mean_rts <- df %>%
    filter(is_target_sentence == TRUE, is_probe_repeat == "TRUE") %>%
    group_by(participant_id, noun_condition, voice) %>%
    summarise(
        ir_rt = mean(ir_reaction_time_ms[event_type == "IR pressed"], na.rm = TRUE),
        wr_rt = mean(wr_reaction_time_ms[event_type == "WR pressed"], na.rm = TRUE),
        .groups = "drop"
    )

# ── 5. Compile CR Scores Table ──────────────────────────────────────────────
cat("\n  [5/5] Compiling final CR score table...\n")
cr_scores <- target_probes %>%
    left_join(ir_hits, by = c("participant_id", "noun_condition", "voice")) %>%
    left_join(wr_accuracy_data, by = c("participant_id", "noun_condition", "voice")) %>%
    left_join(fa_rates, by = "participant_id") %>%
    left_join(mean_rts, by = c("participant_id", "noun_condition", "voice")) %>%
    mutate(
        n_ir_hits   = replace_na(n_ir_hits, 0),
        ir_hit_rate = n_ir_hits / n_target_probes,
        ir_cr       = ir_hit_rate - ir_fa_rate
    ) %>%
    select(
        participant_id, noun_condition, voice,
        ir_cr, ir_hit_rate, ir_fa_rate,
        wr_acc_score, ir_rt, wr_rt
    )

cat(sprintf(
    "    CR score table : %d rows x %d cols\n",
    nrow(cr_scores), ncol(cr_scores)
))
cat("\n    IR CR summary:\n")
print(summary(cr_scores$ir_cr))
cat("\n    WR accuracy summary:\n")
print(summary(cr_scores$wr_acc_score))

# ── Descriptive Statistics ──────────────────────────────────────────────────
cat("\n  Computing per-condition descriptive statistics...\n")
desc_table <- cr_scores %>%
    filter(noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
    pivot_longer(
        cols = c(ir_cr, wr_acc_score, ir_rt),
        names_to = "metric", values_to = "value"
    ) %>%
    group_by(noun_condition, voice, metric) %>%
    summarise(
        N = sum(!is.na(value)),
        Mean = round(mean(value, na.rm = TRUE), 4),
        SD = round(sd(value, na.rm = TRUE), 4),
        Median = round(median(value, na.rm = TRUE), 4),
        Min = round(min(value, na.rm = TRUE), 4),
        Max = round(max(value, na.rm = TRUE), 4),
        .groups = "drop"
    )

cat("\n    Descriptive statistics:\n")
print(as.data.frame(desc_table), row.names = FALSE)

# ── Shapiro-Wilk Normality ──────────────────────────────────────────────────
cat("\n  Shapiro-Wilk normality tests...\n")
shapiro_results <- cr_scores %>%
    filter(noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
    pivot_longer(
        cols = c(ir_cr, wr_acc_score, ir_rt),
        names_to = "metric", values_to = "value"
    ) %>%
    group_by(metric) %>%
    summarise(
        n = sum(!is.na(value)),
        W = {
            v <- value[!is.na(value)]
            if (length(v) >= 3) shapiro.test(v)$statistic else NA
        },
        p_value = {
            v <- value[!is.na(value)]
            if (length(v) >= 3) shapiro.test(v)$p.value else NA
        },
        .groups = "drop"
    ) %>%
    mutate(conclusion = case_when(
        is.na(p_value) ~ "Insufficient data",
        p_value > 0.05 ~ "Normal (p > .05)",
        TRUE ~ "Non-normal (p < .05)"
    ))

print(as.data.frame(shapiro_results), row.names = FALSE)
non_normal <- sum(shapiro_results$p_value < 0.05, na.rm = TRUE)
cat(sprintf(
    "\n    %d/%d metrics are non-normal -> non-parametric tests justified.\n",
    non_normal, nrow(shapiro_results)
))

# ── Save outputs ─────────────────────────────────────────────────────────────
if (exists("stat_dir")) {
    writeLines(
        c(
            "FA Rate Summary", "===============",
            capture.output(print(as.data.frame(fa_rates), row.names = FALSE))
        ),
        file.path(stat_dir, "fa_rates.txt")
    )
    writeLines(
        c(
            "Descriptive Statistics per Condition x Voice x Metric",
            "======================================================",
            capture.output(print(as.data.frame(desc_table), row.names = FALSE))
        ),
        file.path(stat_dir, "descriptive_stats.txt")
    )
    writeLines(
        c(
            "Shapiro-Wilk Normality Tests", "=============================",
            capture.output(print(as.data.frame(shapiro_results), row.names = FALSE))
        ),
        file.path(stat_dir, "normality.txt")
    )
    cat(sprintf("\n  Saved tables -> %s/{fa_rates,descriptive_stats,normality}.txt\n", stat_dir))
}

write.csv(cr_scores, "data/processed/cr_scores.csv", row.names = FALSE)
write.csv(desc_table, "data/processed/descriptive_stats.csv", row.names = FALSE)
cat("  Saved -> data/processed/cr_scores.csv, descriptive_stats.csv\n")

# results_stats.R
# Computes all statistics cited in results.md.
# All numbers reported in the write-up must trace to output from this script.
library(dplyr)
library(stringr)

# ── Load ──────────────────────────────────────────────────────────────────────
df <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)

df <- df %>%
  mutate(
    stim_prefix    = str_extract(stimulus_id, "^[A-Z]+"),
    voice_code     = str_extract(stimulus_id, "[AP]$"),
    noun_condition = case_when(
      stim_prefix == "HH"  ~ "HH",
      stim_prefix == "HVL" ~ "HL",
      stim_prefix == "LVH" ~ "LH",
      stim_prefix == "LVL" ~ "LL",
      TRUE                 ~ NA_character_
    ),
    voice = case_when(
      voice_code == "A" ~ "Active",
      voice_code == "P" ~ "Passive",
      TRUE              ~ NA_character_
    )
  )

# ── Subsets ───────────────────────────────────────────────────────────────────
probes_shown <- df %>%
  filter(event_type         == "Sentence shown",
         is_target_sentence == TRUE,
         is_probe_repeat    == TRUE,
         !is.na(noun_condition))

ir_hits <- df %>%
  filter(event_type         == "IR pressed",
         is_target_sentence == TRUE,
         is_probe_repeat    == TRUE,
         !is.na(noun_condition))

wr_presses <- df %>%
  filter(event_type         == "WR pressed",
         is_target_sentence == TRUE,
         is_probe_repeat    == TRUE,
         !is.na(noun_condition))

# ── FA rate: HF first showings only ──────────────────────────────────────────
n_hf_first <- df %>%
  filter(event_type         == "Sentence shown",
         is_target_sentence == FALSE,
         stim_prefix        == "HF",
         is_probe_repeat    == FALSE) %>%
  count(participant_id, name = "n_hf_shown")

n_fa <- df %>%
  filter(event_type         == "IR pressed",
         is_target_sentence == FALSE,
         stim_prefix        == "HF",
         is_probe_repeat    == FALSE) %>%
  count(participant_id, name = "n_fa")

fa_rate <- merge(n_hf_first, n_fa, by = "participant_id", all.x = TRUE) %>%
  mutate(n_fa    = ifelse(is.na(n_fa), 0, n_fa),
         fa_rate = n_fa / n_hf_shown)

# ── Build trial-level probe table ─────────────────────────────────────────────
probes <- probes_shown %>%
  left_join(
    ir_hits %>% select(participant_id, stimulus_id, block_id,
                       ir_hit = ir_accuracy,
                       ir_rt  = ir_reaction_time_ms),
    by = c("participant_id", "stimulus_id", "block_id")
  ) %>%
  mutate(ir_hit = ifelse(is.na(ir_hit), 0L, ir_hit)) %>%
  left_join(
    wr_presses %>% select(participant_id, stimulus_id, block_id,
                          wr_acc = wr_accuracy),
    by = c("participant_id", "stimulus_id", "block_id")
  )

# ── SECTION 0: Descriptive overview ──────────────────────────────────────────
cat("══════════════════════════════════════════════════════\n")
cat("SECTION 0: OVERVIEW\n")
cat("══════════════════════════════════════════════════════\n")

n_participants   <- n_distinct(probes$participant_id)
n_target_trials  <- nrow(probes)
n_valid_blocks   <- n_distinct(df %>% select(participant_id, block_id))
overall_hit_rate <- mean(probes$ir_hit, na.rm = TRUE)
overall_fa_rate  <- mean(fa_rate$fa_rate, na.rm = TRUE)

cat(sprintf("  Participants          : %d\n",    n_participants))
cat(sprintf("  Target probe trials  : %d\n",    n_target_trials))
cat(sprintf("  Valid blocks         : %d / %d (%.1f%%)\n",
    n_valid_blocks, n_participants * 3, n_valid_blocks / (n_participants * 3) * 100))
cat(sprintf("  Overall hit rate     : %.3f\n",  overall_hit_rate))
cat(sprintf("  Overall FA rate      : %.3f\n",  overall_fa_rate))
cat(sprintf("  Overall corrected IR : %.3f\n",  overall_hit_rate - overall_fa_rate))
cat(sprintf("  FA rate range        : %.3f – %.3f\n",
    min(fa_rate$fa_rate), max(fa_rate$fa_rate)))
cat(sprintf("  HF first showings    : %d – %d\n",
    min(n_hf_first$n_hf_shown), max(n_hf_first$n_hf_shown)))
cat("\n")


# ── SECTION 1: IR corrected recognition × noun condition ─────────────────────
cat("══════════════════════════════════════════════════════\n")
cat("SECTION 1: IR CORRECTED RECOGNITION × NOUN CONDITION\n")
cat("══════════════════════════════════════════════════════\n")

hit_by_cond <- probes %>%
  group_by(participant_id, noun_condition) %>%
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") %>%
  left_join(fa_rate %>% select(participant_id, fa_rate), by = "participant_id") %>%
  mutate(fa_rate      = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

cond_summary <- hit_by_cond %>%
  group_by(noun_condition) %>%
  summarise(M   = round(mean(corrected_ir,   na.rm = TRUE), 3),
            SD  = round(sd(corrected_ir,     na.rm = TRUE), 3),
            Mdn = round(median(corrected_ir, na.rm = TRUE), 3),
            n   = n(), .groups = "drop") %>%
  arrange(desc(M))

cat("Condition-level descriptives:\n")
print(as.data.frame(cond_summary))

kw_ir <- kruskal.test(corrected_ir ~ noun_condition, data = hit_by_cond)
cat(sprintf("\nKruskal-Wallis: H(%d) = %.3f, p = %.4f\n",
    kw_ir$parameter, kw_ir$statistic, kw_ir$p.value))

cat("\nPost-hoc pairwise Wilcoxon (Holm-corrected):\n")
pw_ir <- pairwise.wilcox.test(
  hit_by_cond$corrected_ir, hit_by_cond$noun_condition,
  p.adjust.method = "holm", paired = FALSE
)
print(pw_ir$p.value)
cat("\n")


# ── SECTION 2: WR accuracy × noun condition ───────────────────────────────────
cat("══════════════════════════════════════════════════════\n")
cat("SECTION 2: WR ACCURACY × NOUN CONDITION\n")
cat("══════════════════════════════════════════════════════\n")

wr_by_cond <- probes %>%
  filter(!is.na(wr_acc)) %>%
  group_by(participant_id, noun_condition) %>%
  summarise(wr_accuracy = mean(wr_acc, na.rm = TRUE), .groups = "drop")

wr_cond_summary <- wr_by_cond %>%
  group_by(noun_condition) %>%
  summarise(M   = round(mean(wr_accuracy,   na.rm = TRUE), 3),
            SD  = round(sd(wr_accuracy,     na.rm = TRUE), 3),
            Mdn = round(median(wr_accuracy, na.rm = TRUE), 3),
            n   = n(), .groups = "drop")

cat("WR accuracy by condition:\n")
print(as.data.frame(wr_cond_summary))

kw_wr <- kruskal.test(wr_accuracy ~ noun_condition, data = wr_by_cond)
cat(sprintf("\nKruskal-Wallis: H(%d) = %.3f, p = %.4f\n\n",
    kw_wr$parameter, kw_wr$statistic, kw_wr$p.value))


# ── SECTION 3: Voice effect on IR ────────────────────────────────────────────
cat("══════════════════════════════════════════════════════\n")
cat("SECTION 3: VOICE EFFECT ON IR\n")
cat("══════════════════════════════════════════════════════\n")

hit_by_voice <- probes %>%
  group_by(participant_id, voice) %>%
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") %>%
  left_join(fa_rate %>% select(participant_id, fa_rate), by = "participant_id") %>%
  mutate(fa_rate      = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

voice_summary <- hit_by_voice %>%
  group_by(voice) %>%
  summarise(M   = round(mean(corrected_ir,   na.rm = TRUE), 3),
            SD  = round(sd(corrected_ir,     na.rm = TRUE), 3),
            Mdn = round(median(corrected_ir, na.rm = TRUE), 3), .groups = "drop")
print(as.data.frame(voice_summary))

active_ir  <- hit_by_voice$corrected_ir[hit_by_voice$voice == "Active"]
passive_ir <- hit_by_voice$corrected_ir[hit_by_voice$voice == "Passive"]
wt_voice   <- wilcox.test(active_ir, passive_ir, paired = TRUE)
cat(sprintf("Wilcoxon signed-rank: V = %.0f, p = %.4f\n\n",
    wt_voice$statistic, wt_voice$p.value))


# ── SECTION 4: 8-cell condition × voice descriptives ─────────────────────────
cat("══════════════════════════════════════════════════════\n")
cat("SECTION 4: 8-CELL CONDITION × VOICE DESCRIPTIVES\n")
cat("══════════════════════════════════════════════════════\n")

hit_by_cv <- probes %>%
  group_by(participant_id, noun_condition, voice) %>%
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") %>%
  left_join(fa_rate %>% select(participant_id, fa_rate), by = "participant_id") %>%
  mutate(fa_rate      = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

cv_summary <- hit_by_cv %>%
  group_by(noun_condition, voice) %>%
  summarise(M  = round(mean(corrected_ir, na.rm = TRUE), 3),
            SD = round(sd(corrected_ir,   na.rm = TRUE), 3),
            n  = n(), .groups = "drop") %>%
  arrange(desc(M))
print(as.data.frame(cv_summary))
cat("\n")


# ── SECTION 5: Voice effect on WR ────────────────────────────────────────────
cat("══════════════════════════════════════════════════════\n")
cat("SECTION 5: VOICE EFFECT ON WR\n")
cat("══════════════════════════════════════════════════════\n")

wr_by_voice <- probes %>%
  filter(!is.na(wr_acc)) %>%
  group_by(participant_id, voice) %>%
  summarise(wr_accuracy = mean(wr_acc, na.rm = TRUE), .groups = "drop")

wr_voice_summary <- wr_by_voice %>%
  group_by(voice) %>%
  summarise(M   = round(mean(wr_accuracy,   na.rm = TRUE), 3),
            SD  = round(sd(wr_accuracy,     na.rm = TRUE), 3),
            Mdn = round(median(wr_accuracy, na.rm = TRUE), 3), .groups = "drop")
print(as.data.frame(wr_voice_summary))

active_wr  <- wr_by_voice$wr_accuracy[wr_by_voice$voice == "Active"]
passive_wr <- wr_by_voice$wr_accuracy[wr_by_voice$voice == "Passive"]
wt_wr      <- wilcox.test(active_wr, passive_wr, paired = TRUE)
cat(sprintf("Wilcoxon signed-rank: V = %.0f, p = %.4f\n", wt_wr$statistic, wt_wr$p.value))

cat("Above chance (vs 0.5):\n")
for (v in c("Active", "Passive")) {
  vals <- wr_by_voice$wr_accuracy[wr_by_voice$voice == v]
  wt   <- wilcox.test(vals, mu = 0.5, alternative = "greater")
  cat(sprintf("  %s: V = %.0f, p = %.6f\n", v, wt$statistic, wt$p.value))
}
cat("\n")


# ── SECTION 6: Block effects ──────────────────────────────────────────────────
cat("══════════════════════════════════════════════════════\n")
cat("SECTION 6: BLOCK EFFECTS\n")
cat("══════════════════════════════════════════════════════\n")

hit_by_block <- probes %>%
  group_by(participant_id, block_id) %>%
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") %>%
  left_join(fa_rate %>% select(participant_id, fa_rate), by = "participant_id") %>%
  mutate(fa_rate      = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

block_summary <- hit_by_block %>%
  group_by(block_id) %>%
  summarise(M  = round(mean(corrected_ir, na.rm = TRUE), 3),
            SD = round(sd(corrected_ir,   na.rm = TRUE), 3),
            n  = n(), .groups = "drop")
print(as.data.frame(block_summary))

kw_block <- kruskal.test(corrected_ir ~ factor(block_id), data = hit_by_block)
cat(sprintf("Kruskal-Wallis: H(%d) = %.3f, p = %.4f\n\n",
    kw_block$parameter, kw_block$statistic, kw_block$p.value))


# ── SUMMARY TABLE ─────────────────────────────────────────────────────────────
cat("══════════════════════════════════════════════════════\n")
cat("SUMMARY OF ALL TESTS\n")
cat("══════════════════════════════════════════════════════\n")

stats_summary <- data.frame(
  Test      = c("KW: IR × Noun Condition",
                "KW: WR × Noun Condition",
                "WSR: IR Active vs. Passive",
                "WSR: WR Active vs. Passive",
                "KW: IR × Block"),
  Statistic = round(c(kw_ir$statistic,  kw_wr$statistic,
                      wt_voice$statistic, wt_wr$statistic,
                      kw_block$statistic), 3),
  df        = c(kw_ir$parameter, kw_wr$parameter, NA, NA, kw_block$parameter),
  p_value   = round(c(kw_ir$p.value,  kw_wr$p.value,
                      wt_voice$p.value, wt_wr$p.value,
                      kw_block$p.value), 4),
  Sig       = ifelse(c(kw_ir$p.value, kw_wr$p.value,
                       wt_voice$p.value, wt_wr$p.value,
                       kw_block$p.value) < .05, "✓", "")
)

print(stats_summary, row.names = FALSE)
write.csv(stats_summary, "data/processed/stats_summary.csv", row.names = FALSE)
cat("\nSaved: data/processed/stats_summary.csv\n")

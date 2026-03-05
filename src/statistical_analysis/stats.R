# ── Correcting Recognition Scores ────────────────────────────────────────────
library(dplyr)

# ── Parser ────────────────────────────────────────────────────────────────────
parse_stimulus_id <- function(stimulus_id) {
  if (is.na(stimulus_id) || !grepl("^[A-Z]+_[0-9]+_[AP]$", stimulus_id)) {
    return(list(svo             = NA_character_,
                sentence_number = NA_integer_,
                probe_type      = NA_character_))
  }
  parts <- strsplit(stimulus_id, "_")[[1]]
  list(
    svo             = parts[1],
    sentence_number = as.integer(parts[2]),
    probe_type      = parts[3]
  )
}

# ── Load and parse ────────────────────────────────────────────────────────────
processed_data <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)

processed_data <- processed_data %>%
  mutate(
    parsed          = lapply(stimulus_id, parse_stimulus_id),
    svo             = sapply(parsed, function(x) x$svo),
    sentence_number = sapply(parsed, function(x) x$sentence_number),
    probe_type      = sapply(parsed, function(x) x$probe_type)
  ) %>%
  select(-parsed)

cat("Unique SVOs:", paste(sort(unique(processed_data$svo)), collapse = ", "), "\n\n")

# ── Split targets and fillers ─────────────────────────────────────────────────
# Targets  = HH, HL, LH, LL, HVL, LVH  (is_target_sentence == TRUE)
# Fillers  = HF + validation sentences  (is_target_sentence == FALSE)
target_data <- processed_data %>% filter(is_target_sentence == TRUE)
filler_data <- processed_data %>% filter(is_target_sentence == FALSE)

cat("Target rows :", nrow(target_data), "\n")
cat("Filler rows :", nrow(filler_data), "\n")
cat("Unique SVOs in target data:", paste(sort(unique(target_data$svo)), collapse = ", "), "\n")
cat("Unique SVOs in filler data:", paste(sort(unique(filler_data$svo)), collapse = ", "), "\n\n")

# ── 1. False Alarm Rate (per participant, global) ─────────────────────────────
# FA denominator: HF-only first showings (svo == "HF", is_probe_repeat == FALSE)
# Validation fillers are excluded — they serve a different experimental role
hf_first_shown <- filler_data %>%
  filter(event_type      == "Sentence shown",
         svo             == "HF",
         is_probe_repeat == FALSE) %>%
  count(participant_id, name = "n_hf_first_shown")

# FA numerator: any IR press on an HF first showing (pressing = wrong = false alarm)
hf_fa <- filler_data %>%
  filter(event_type      == "IR pressed",
         svo             == "HF",
         is_probe_repeat == FALSE) %>%
  count(participant_id, name = "n_hf_fa")

fa_rate <- merge(hf_first_shown, hf_fa, by = "participant_id", all.x = TRUE) %>%
  mutate(n_hf_fa = ifelse(is.na(n_hf_fa), 0, n_hf_fa),
         fa_rate = n_hf_fa / n_hf_first_shown)

cat("False Alarm Rate summary:\n")
print(summary(fa_rate$fa_rate))
cat(sprintf("  HF first showings range: %d – %d\n\n",
    min(hf_first_shown$n_hf_first_shown),
    max(hf_first_shown$n_hf_first_shown)))

# ── 2. Hit Rate (per participant × SVO condition × voice) ────────────────────
# Denominator: target probe showings per condition cell
probes_shown <- target_data %>%
  filter(event_type      == "Sentence shown",
         is_probe_repeat == TRUE) %>%
  count(participant_id, svo, probe_type, name = "n_probes_shown")

# Numerator: correct IR presses on target probes (ir_accuracy == 1 only)
probes_ir <- target_data %>%
  filter(event_type      == "IR pressed",
         is_probe_repeat == TRUE,
         ir_accuracy     == 1) %>%
  count(participant_id, svo, probe_type, name = "n_probes_ir")

hit_rate <- merge(probes_shown, probes_ir,
                  by  = c("participant_id", "svo", "probe_type"),
                  all.x = TRUE) %>%
  mutate(n_probes_ir = ifelse(is.na(n_probes_ir), 0, n_probes_ir),
         hit_rate    = n_probes_ir / n_probes_shown)

cat("Hit Rate summary:\n")
print(summary(hit_rate$hit_rate))
cat("Probes per participant × condition cell (expect 6):\n")
print(summary(hit_rate$n_probes_shown))
cat("\n")

# ── 3. Corrected Recognition Score: CR = hit_rate − fa_rate ──────────────────
corrected_recognition <- merge(hit_rate,
                                fa_rate %>% select(participant_id, fa_rate),
                                by    = "participant_id",
                                all.x = TRUE) %>%
  mutate(fa_rate         = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_score = hit_rate - fa_rate,
         voice           = ifelse(probe_type == "A", "active", "passive"),
         condition_8     = paste0(svo, "_", voice))

cat("Corrected Recognition Score summary:\n")
print(summary(corrected_recognition$corrected_score))

# ── 4. Condition-level summary ────────────────────────────────────────────────
cat("\nCR by condition (8 cells):\n")
cr_summary <- corrected_recognition %>%
  group_by(svo, voice) %>%
  summarise(
    n         = n(),
    mean_cr   = round(mean(corrected_score,   na.rm = TRUE), 3),
    median_cr = round(median(corrected_score, na.rm = TRUE), 3),
    sd_cr     = round(sd(corrected_score,     na.rm = TRUE), 3),
    min_cr    = round(min(corrected_score,    na.rm = TRUE), 3),
    max_cr    = round(max(corrected_score,    na.rm = TRUE), 3),
    .groups   = "drop"
  ) %>%
  arrange(desc(mean_cr))
print(cr_summary)

# Collapsed across voice: 4-condition table (direct input for Kruskal-Wallis)
cr_by_svo <- corrected_recognition %>%
  group_by(participant_id, svo) %>%
  summarise(corrected_score = mean(corrected_score, na.rm = TRUE), .groups = "drop")

cat("\nCR collapsed across voice (4 conditions):\n")
cr_svo_summary <- cr_by_svo %>%
  group_by(svo) %>%
  summarise(
    n         = n(),
    mean_cr   = round(mean(corrected_score,   na.rm = TRUE), 3),
    median_cr = round(median(corrected_score, na.rm = TRUE), 3),
    sd_cr     = round(sd(corrected_score,     na.rm = TRUE), 3),
    .groups   = "drop"
  ) %>%
  arrange(desc(mean_cr))
print(cr_svo_summary)

write.csv(corrected_recognition, "data/processed/cr_scores.csv",     row.names = FALSE)
write.csv(cr_summary,            "data/processed/cr_summary_8.csv",  row.names = FALSE)
write.csv(cr_by_svo,             "data/processed/cr_by_svo.csv",     row.names = FALSE)
write.csv(fa_rate,               "data/processed/fa_rate.csv",       row.names = FALSE)

cat("\nSaved: cr_scores.csv | cr_summary_8.csv | cr_by_svo.csv | fa_rate.csv\n")

# ── 5. Kruskal-Wallis Tests ───────────────────────────────────────────────────
# Map internal SVO labels to readable condition names before testing
cr_by_svo <- cr_by_svo %>%
  mutate(noun_condition = case_when(
    svo == "HH"  ~ "HH",
    svo == "HVL" ~ "HL",
    svo == "LVH" ~ "LH",
    svo == "LVL" ~ "LL",
    TRUE         ~ svo
  ))

corrected_recognition <- corrected_recognition %>%
  mutate(noun_condition = case_when(
    svo == "HH"  ~ "HH",
    svo == "HVL" ~ "HL",
    svo == "LVH" ~ "LH",
    svo == "LVL" ~ "LL",
    TRUE         ~ svo
  ))


# ── 5a. Primary: IR corrected recognition by noun condition ──────────────────
cat("═══════════════════════════════════════════════════════\n")
cat("TEST 1: Kruskal-Wallis — IR Corrected Recognition × Noun Condition\n")
cat("═══════════════════════════════════════════════════════\n")

kw_ir <- kruskal.test(corrected_score ~ noun_condition, data = cr_by_svo)
cat(sprintf("  H(%d) = %.3f,  p = %.4f\n\n",
    kw_ir$parameter, kw_ir$statistic, kw_ir$p.value))

# Post-hoc: pairwise Wilcoxon with Holm correction (only if KW is significant)
cat("POST-HOC: Pairwise Wilcoxon (Holm-corrected)\n")
pw_ir <- pairwise.wilcox.test(
  cr_by_svo$corrected_score,
  cr_by_svo$noun_condition,
  p.adjust.method = "holm",
  paired          = FALSE
)
print(pw_ir$p.value)
cat("\n")


# ── 5b. WR accuracy by noun condition ────────────────────────────────────────
cat("═══════════════════════════════════════════════════════\n")
cat("TEST 2: Kruskal-Wallis — WR Accuracy × Noun Condition\n")
cat("═══════════════════════════════════════════════════════\n")

# Need WR accuracy per participant × condition
wr_by_cond <- processed_data %>%
  filter(event_type         == "WR pressed",
         is_target_sentence == TRUE,
         is_probe_repeat    == TRUE,
         !is.na(wr_accuracy)) %>%
  mutate(noun_condition = case_when(
    svo == "HH"  ~ "HH",
    svo == "HVL" ~ "HL",
    svo == "LVH" ~ "LH",
    svo == "LVL" ~ "LL",
    TRUE         ~ svo
  )) %>%
  group_by(participant_id, noun_condition) %>%
  summarise(wr_acc = mean(wr_accuracy == 1, na.rm = TRUE), .groups = "drop")

kw_wr <- kruskal.test(wr_acc ~ noun_condition, data = wr_by_cond)
cat(sprintf("  H(%d) = %.3f,  p = %.4f\n\n",
    kw_wr$parameter, kw_wr$statistic, kw_wr$p.value))


# ── 5c. Voice effect on IR (active vs passive) ───────────────────────────────
cat("═══════════════════════════════════════════════════════\n")
cat("TEST 3: Wilcoxon Signed-Rank — Voice Effect on IR\n")
cat("═══════════════════════════════════════════════════════\n")

ir_by_voice <- corrected_recognition %>%
  group_by(participant_id, voice) %>%
  summarise(cr = mean(corrected_score, na.rm = TRUE), .groups = "drop")

active_scores  <- ir_by_voice$cr[ir_by_voice$voice == "active"]
passive_scores <- ir_by_voice$cr[ir_by_voice$voice == "passive"]

voice_summary <- ir_by_voice %>%
  group_by(voice) %>%
  summarise(M  = round(mean(cr, na.rm = TRUE), 3),
            SD = round(sd(cr,   na.rm = TRUE), 3),
            Mdn = round(median(cr, na.rm = TRUE), 3), .groups = "drop")
print(voice_summary)

wt_voice <- wilcox.test(active_scores, passive_scores, paired = TRUE)
cat(sprintf("  V = %.0f,  p = %.4f\n\n",
    wt_voice$statistic, wt_voice$p.value))


# ── 5d. Voice effect on WR ───────────────────────────────────────────────────
cat("═══════════════════════════════════════════════════════\n")
cat("TEST 4: Wilcoxon Signed-Rank — Voice Effect on WR\n")
cat("═══════════════════════════════════════════════════════\n")

wr_by_voice <- processed_data %>%
  filter(event_type         == "WR pressed",
         is_target_sentence == TRUE,
         is_probe_repeat    == TRUE,
         !is.na(wr_accuracy)) %>%
  group_by(participant_id, probe_type) %>%
  summarise(wr_acc = mean(wr_accuracy == 1, na.rm = TRUE), .groups = "drop")

wr_voice_summary <- wr_by_voice %>%
  group_by(probe_type) %>%
  summarise(M   = round(mean(wr_acc,   na.rm = TRUE), 3),
            SD  = round(sd(wr_acc,     na.rm = TRUE), 3),
            Mdn = round(median(wr_acc, na.rm = TRUE), 3), .groups = "drop") %>%
  mutate(voice = ifelse(probe_type == "A", "Active", "Passive"))
print(wr_voice_summary)

active_wr  <- wr_by_voice$wr_acc[wr_by_voice$probe_type == "A"]
passive_wr <- wr_by_voice$wr_acc[wr_by_voice$probe_type == "P"]

wt_wr_voice <- wilcox.test(active_wr, passive_wr, paired = TRUE)
cat(sprintf("  V = %.0f,  p = %.4f\n\n",
    wt_wr_voice$statistic, wt_wr_voice$p.value))

# One-sample test: both voices above chance (0.5)?
cat("  WR above chance (vs 0.5):\n")
for (v in c("A", "P")) {
  vals <- wr_by_voice$wr_acc[wr_by_voice$probe_type == v]
  wt   <- wilcox.test(vals, mu = 0.5, alternative = "greater")
  cat(sprintf("    %s: V = %.0f, p = %.6f\n",
      ifelse(v == "A", "Active ", "Passive"), wt$statistic, wt$p.value))
}


# ── 5e. Block effect (learning / fatigue) ────────────────────────────────────
cat("\n═══════════════════════════════════════════════════════\n")
cat("TEST 5: Kruskal-Wallis — IR Corrected Recognition × Block\n")
cat("═══════════════════════════════════════════════════════\n")

ir_by_block <- target_data %>%
  filter(event_type      == "Sentence shown",
         is_probe_repeat == TRUE) %>%
  left_join(
    target_data %>%
      filter(event_type  == "IR pressed",
             is_probe_repeat == TRUE,
             ir_accuracy == 1) %>%
      select(participant_id, stimulus_id, block_id) %>%
      mutate(hit = 1L),
    by = c("participant_id", "stimulus_id", "block_id")
  ) %>%
  mutate(hit = ifelse(is.na(hit), 0L, hit)) %>%
  group_by(participant_id, block_id) %>%
  summarise(hit_rate = mean(hit, na.rm = TRUE), .groups = "drop") %>%
  left_join(fa_rate %>% select(participant_id, fa_rate), by = "participant_id") %>%
  mutate(fa_rate      = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

block_means <- ir_by_block %>%
  group_by(block_id) %>%
  summarise(M  = round(mean(corrected_ir,   na.rm = TRUE), 3),
            SD = round(sd(corrected_ir,     na.rm = TRUE), 3),
            n  = n(), .groups = "drop")
print(block_means)

kw_block <- kruskal.test(corrected_ir ~ factor(block_id), data = ir_by_block)
cat(sprintf("  H(%d) = %.3f,  p = %.4f\n\n",
    kw_block$parameter, kw_block$statistic, kw_block$p.value))


# ── Summary table of all tests ───────────────────────────────────────────────
cat("═══════════════════════════════════════════════════════\n")
cat("SUMMARY OF ALL TESTS\n")
cat("═══════════════════════════════════════════════════════\n")
stats_summary <- data.frame(
  Test      = c("KW: IR × Noun Condition",
                "KW: WR × Noun Condition",
                "WSR: IR Active vs Passive",
                "WSR: WR Active vs Passive",
                "KW: IR × Block"),
  Statistic = c(round(kw_ir$statistic,    3),
                round(kw_wr$statistic,    3),
                round(wt_voice$statistic, 0),
                round(wt_wr_voice$statistic, 0),
                round(kw_block$statistic, 3)),
  df_or_df  = c(kw_ir$parameter,    kw_wr$parameter,
                NA,                 NA,
                kw_block$parameter),
  p_value   = round(c(kw_ir$p.value, kw_wr$p.value,
                      wt_voice$p.value, wt_wr_voice$p.value,
                      kw_block$p.value), 4),
  Sig       = ifelse(c(kw_ir$p.value, kw_wr$p.value,
                       wt_voice$p.value, wt_wr_voice$p.value,
                       kw_block$p.value) < .05, "✓", "")
)
print(stats_summary, row.names = FALSE)

write.csv(stats_summary, "data/processed/stats_summary.csv", row.names = FALSE)
cat("\nSaved: stats_summary.csv\n")

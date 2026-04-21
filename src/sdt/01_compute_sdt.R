# src/sdt/01_compute_sdt.R
# Computes Signal Detection Theory parameters (d', c, A') for the
# sentence memorability study.
#
# WHY SDT: Corrected IR = Hit Rate - FA Rate is a linear approximation.
# SDT decomposes recognition into sensitivity (d') and response bias (c)
# separately, allowing us to distinguish true memory-trace strength from
# strategic responding.
#
# FA NOTE: All HF lures are Active-voice only (confirmed from final_data).
# Therefore only a GLOBAL per-participant FA rate is computable. This rate
# is applied uniformly across conditions and voices — a standard approach
# when lures are not condition-differentiated.
#
# HAUTUS CORRECTION: (hits+0.5)/(n+1) and (fa+0.5)/(n+1) applied to all
# cells to avoid z(0)=-Inf and z(1)=+Inf with small per-cell N.
# Reference: Hautus (1995), Psychon Bull Rev.
#
# Input:  data/processed/final_data.csv
# Output: data/processed/sdt_scores.csv
#         data/processed/sdt_voice_scores.csv

suppressPackageStartupMessages({ library(dplyr); library(tidyr) })

cat("\n[sdt/01] Computing SDT parameters (d', c, A')...\n")

df <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)
df$is_target_sentence <- (df$is_target_sentence == TRUE |
                          df$is_target_sentence == "TRUE")

cat(sprintf("  Input rows : %d | participants : %d\n",
            nrow(df), length(unique(df$participant_id))))

# ── Global FA rate per participant ─────────────────────────────────────────────
# FA = IR pressed on HF sentences at their first showing (is_probe_repeat = NA)
hf_shown <- df %>%
  filter(event_type == "Sentence shown",
         noun_condition == "HF", is.na(is_probe_repeat)) %>%
  group_by(participant_id) %>%
  summarise(n_lures = n(), .groups = "drop")

hf_fa <- df %>%
  filter(event_type == "IR pressed",
         noun_condition == "HF", is.na(is_probe_repeat)) %>%
  group_by(participant_id) %>%
  summarise(n_fa = n(), .groups = "drop")

fa_global <- hf_shown %>%
  left_join(hf_fa, by = "participant_id") %>%
  mutate(n_fa = replace(n_fa, is.na(n_fa), 0L))

cat(sprintf("  Global FA  n_lures mean=%.0f | FA rate mean=%.3f sd=%.3f\n",
            mean(fa_global$n_lures),
            mean(fa_global$n_fa / fa_global$n_lures),
            sd(fa_global$n_fa / fa_global$n_lures)))

# ── Target probes and IR hits per participant × noun_condition ─────────────────
target_probes <- df %>%
  filter(event_type == "Sentence shown",
         is_target_sentence == TRUE,
         is_probe_repeat == TRUE,
         noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
  group_by(participant_id, noun_condition) %>%
  summarise(n_targets = n(), .groups = "drop")

ir_hits <- df %>%
  filter(event_type == "IR pressed",
         is_target_sentence == TRUE,
         is_probe_repeat == TRUE,
         noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
  group_by(participant_id, noun_condition) %>%
  summarise(n_hits = n(), .groups = "drop")

# ── Assemble and compute SDT parameters ───────────────────────────────────────
sdt_scores <- target_probes %>%
  left_join(ir_hits,    by = c("participant_id", "noun_condition")) %>%
  left_join(fa_global,  by = "participant_id") %>%
  mutate(
    n_hits = replace(n_hits, is.na(n_hits), 0L),

    # Hautus (1995) log-linear correction
    hit_adj = (n_hits + 0.5) / (n_targets + 1),
    fa_adj  = (n_fa   + 0.5) / (n_lures   + 1),

    # d' = z(H) - z(FA); higher = better sensitivity
    dprime  = qnorm(hit_adj) - qnorm(fa_adj),

    # c = -0.5 * [z(H) + z(FA)]; >0 = conservative, <0 = liberal
    c_crit  = -0.5 * (qnorm(hit_adj) + qnorm(fa_adj)),

    # A' = non-parametric ROC area (no Gaussian assumption)
    A_prime = ifelse(
      hit_adj >= fa_adj,
      0.5 + ((hit_adj - fa_adj) * (1 + hit_adj - fa_adj)) / (4 * hit_adj * (1 - fa_adj)),
      0.5 - ((fa_adj - hit_adj) * (1 + fa_adj - hit_adj)) / (4 * fa_adj * (1 - hit_adj))
    ),
    noun_condition = factor(noun_condition, levels = c("HH", "HL", "LH", "LL"))
  )

# Completeness check: Friedman's requires all 4 conditions per participant
complete_pids <- sdt_scores %>%
  group_by(participant_id) %>%
  summarise(n_cells = n(), .groups = "drop") %>%
  filter(n_cells == 4L) %>%
  pull(participant_id)

n_dropped <- length(unique(sdt_scores$participant_id)) - length(complete_pids)
cat(sprintf("  SDT condition-level: %d participants complete | %d dropped\n",
            length(complete_pids), n_dropped))

sdt_scores <- sdt_scores %>% filter(participant_id %in% complete_pids)

cat(sprintf("  d' range : [%.3f, %.3f]  mean=%.3f\n",
            min(sdt_scores$dprime), max(sdt_scores$dprime),
            mean(sdt_scores$dprime)))
cat(sprintf("  c  range : [%.3f, %.3f]  mean=%.3f\n",
            min(sdt_scores$c_crit), max(sdt_scores$c_crit),
            mean(sdt_scores$c_crit)))

# ── Per-voice SDT (using global FA — Active-only lures; noted as limitation) ──
target_voice <- df %>%
  filter(event_type == "Sentence shown",
         is_target_sentence == TRUE,
         is_probe_repeat == TRUE,
         noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
  group_by(participant_id, noun_condition, voice) %>%
  summarise(n_targets = n(), .groups = "drop")

hits_voice <- df %>%
  filter(event_type == "IR pressed",
         is_target_sentence == TRUE,
         is_probe_repeat == TRUE,
         noun_condition %in% c("HH", "HL", "LH", "LL")) %>%
  group_by(participant_id, noun_condition, voice) %>%
  summarise(n_hits = n(), .groups = "drop")

sdt_voice_scores <- target_voice %>%
  left_join(hits_voice, by = c("participant_id", "noun_condition", "voice")) %>%
  left_join(fa_global,  by = "participant_id") %>%
  mutate(
    n_hits  = replace(n_hits, is.na(n_hits), 0L),
    hit_adj = (n_hits + 0.5) / (n_targets + 1),
    fa_adj  = (n_fa   + 0.5) / (n_lures   + 1),
    dprime  = qnorm(hit_adj) - qnorm(fa_adj),
    c_crit  = -0.5 * (qnorm(hit_adj) + qnorm(fa_adj)),
    noun_condition = factor(noun_condition, levels = c("HH", "HL", "LH", "LL")),
    voice   = factor(voice, levels = c("Active", "Passive"))
  ) %>%
  filter(participant_id %in% complete_pids)

# ── Save ───────────────────────────────────────────────────────────────────────
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
write.csv(sdt_scores,       "data/processed/sdt_scores.csv",       row.names = FALSE)
write.csv(sdt_voice_scores, "data/processed/sdt_voice_scores.csv", row.names = FALSE)
cat(sprintf("  Saved -> data/processed/sdt_scores.csv       (%d rows)\n", nrow(sdt_scores)))
cat(sprintf("  Saved -> data/processed/sdt_voice_scores.csv (%d rows)\n", nrow(sdt_voice_scores)))

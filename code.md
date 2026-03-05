================================================================================
File: src/Sentence Memorability.txt
================================================================================

```
1. Relevant papers:
- https://www.sciencedirect.com/science/article/abs/pii/S0022537171800105
- https://www.sciencedirect.com/science/article/abs/pii/S0022537168800222
- https://www.sciencedirect.com/science/article/abs/pii/S002253717380060X
2. Brief on experiment and methodology:
- We generated simple Subject–Verb–Object (S–V–O) sentences by systematically varying the memorability of the subject and object nouns. High- and low-memorability nouns were drawn from established word memorability norms, while verbs were selected from a fixed set of medium-concreteness action verbs to minimize variability. This yielded four sentence types: HH, HL, LH, and LL. Sentences were short (≤8 words), used no proper nouns, and were phrased in natural spoken English. Automated fluency checks and semantic-coherence filters removed ungrammatical or implausible sentences, followed by manual screening. From the resulting pool, we selected 200 active-voice sentences (50 per type). Each sentence was also converted into a passive-voice form, producing paired active and passive variants. This resulted in 400 total sentences across eight conditions (HH, HL, LH, LL × active/passive), enabling tests of exact repetition and voice-transformed recognition.
- It's a continuous recognition experiment. Each participant sees 48 target sentences across 3 blocks.
3. Research question of Interest
- How memorability of sentences is affected by it's structure and constituent words
4. Statistical metrics
- Kruskal-Wallis test
- Corrected memorability scores
5. Types of variables
- Words (H and L) and voice (Active and passive)
6. Number of participants
- According to our power analysis we would require a total of 334 participants that are successfully completed the experiment for our hypotheses.
7. Exclusion Criteria
- The blocks that have not passed the validation test will be excluded from the final calculation of the memorability scores
- The validation formula: Number of Correct validation (IRs) > (Number of wrong IRs / 2 ) + Number of Missed IRs (Validation)
```

================================================================================
File: src/methods/results.md
================================================================================

```
# Results

## Overview

A total of 112 participants contributed data from 329 validated blocks
(97.9% pass rate; 7 of 336 possible participant-blocks failed the validation criterion).
The 329 valid blocks × 16 target probes per block yield **5,264 target probe trials**.
The mean false alarm rate across participants was **M = 0.160** (range: 0.000–0.427),
and the overall mean hit rate was **M = 0.832**. After correction, the overall mean
corrected recognition was **M = 0.673** (Mdn = 0.708, range: −0.141 to 1.000).

---

## 1. Effect of Noun Condition on Immediate Recognition (IR)

*Figure: `plots/01_ir_by_condition.png`*

Per-participant corrected IR scores (collapsed across active and passive voice) by noun
condition:

| Condition | *M* | *SD* | *Mdn* |
|---|---|---|---|
| HH | 0.689 | 0.185 | 0.740 |
| HL | 0.691 | 0.177 | 0.708 |
| LH | 0.679 | 0.188 | 0.729 |
| LL | 0.632 | 0.189 | 0.656 |

A Kruskal-Wallis test revealed a significant main effect of noun condition on corrected
IR, *H*(3) = 8.85, *p* = .031. Pairwise Wilcoxon tests (Holm-corrected) indicated that
the LL condition showed marginally lower corrected recognition than HL (*p* = .058) and
HH (*p* = .070). The LL vs. LH comparison did not reach significance (*p* = .130), and
all comparisons among the three mixed/high conditions were non-significant (all *p* =
1.00). This pattern is consistent with a threshold effect: the presence of at least one
high-memorability noun is sufficient to sustain normal recognition, with no further
benefit of having both nouns be high-memorability.

---

## 2. Effect of Noun Condition on Wording Recognition (WR)

*Figure: `plots/02_wr_by_condition.png`*

A Kruskal-Wallis test found no significant effect of noun condition on WR accuracy,
*H*(3) = 1.98, *p* = .576. Noun memorability affects whether a sentence is
recognised (IR) but does not affect how accurately participants discriminate the
grammatical voice of the repeated sentence (WR).

---

## 3. Noun Condition × Voice Interaction — IR

*Figure: `plots/03_ir_condition_x_voice.png`*

Mean corrected IR across the 8 condition × voice cells:

| Condition | Active *M* | Active *SD* | Passive *M* | Passive *SD* |
|---|---|---|---|---|
| HH | 0.683 | 0.199 | 0.695 | 0.220 |
| HL | 0.689 | 0.195 | 0.693 | 0.206 |
| LH | 0.677 | 0.202 | 0.681 | 0.216 |
| LL | 0.625 | 0.234 | 0.638 | 0.215 |

The noun condition effect (LL < HH, HL, LH) replicates consistently within both active
and passive voices, with no evidence of a voice × condition interaction.

---

## 4. Noun Condition × Voice Interaction — WR

*Figure: `plots/04_wr_condition_x_voice.png`*

WR accuracy was uniformly high across all 8 condition × voice cells, with no clear
interaction pattern, mirroring the null noun condition effect on WR reported in
Section 2.

---

## 5. Voice Effect on Immediate Recognition (IR)

*Figures: `plots/09_voice_slope.png`, `plots/03_ir_condition_x_voice.png`*

| Voice   | *M*   | *SD*  | *Mdn* |
|---------|-------|-------|-------|
| Active  | 0.668 | 0.166 | 0.688 |
| Passive | 0.677 | 0.175 | 0.708 |

A paired Wilcoxon signed-rank test found no significant voice effect on corrected IR,
*V* = 1704, *p* = .374. Whether a sentence was presented in active or passive voice did
not influence subsequent recognition of its meaning.

---

## 6. Voice Effect on Wording Recognition (WR)

*Figure: `plots/11_wr_accuracy_by_voice.png`*

| Voice   | *M*   | *SD*  | *Mdn* |
|---------|-------|-------|-------|
| Active  | 0.757 | 0.120 | 0.756 |
| Passive | 0.735 | 0.127 | 0.739 |

WR accuracy was numerically higher for active-voice sentences, but this difference was
not statistically significant, *V* = 3279, *p* = .113. Critically, both voices were
reliably above chance (0.5): Active *V* = 6322, *p* < .001; Passive *V* = 5990,
*p* < .001. Participants could accurately detect voice mismatches regardless of the
original grammatical form.

---

## 7. Block Effects

*Figure: `plots/07_block_learning.png`*

Mean corrected IR by block:

| Block | *M*   | *SD*  | *n* |
|-------|-------|-------|-----|
| 1     | 0.699 | 0.151 | 108 |
| 2     | 0.679 | 0.195 | 109 |
| 3     | 0.650 | 0.191 | 112 |

A Kruskal-Wallis test found no significant block effect, *H*(2) = 2.77, *p* = .250. The
numerically declining trend is consistent with mild proactive interference accumulating
across the session, but the effect does not reach statistical significance.

---

## 8. Summary of All Tests

*Figure: `plots/12_forest_plot.png`*

| Test | Statistic | *df* | *p* | Significant |
|---|---|---|---|---|
| KW: IR × Noun Condition    | *H* = 8.85  | 3  | .031 | ✓ |
| KW: WR × Noun Condition    | *H* = 1.98  | 3  | .576 |   |
| WSR: IR Active vs. Passive | *V* = 1704  | —  | .374 |   |
| WSR: WR Active vs. Passive | *V* = 3279  | —  | .113 |   |
| KW: IR × Block             | *H* = 2.77  | 2  | .250 |   |

```

================================================================================
File: src/methods/methods.md
================================================================================

```
# Methods

## Participants

Data were collected from online participants via a web-based experiment. A total of
114 participants started the experiment. Of these, 112 contributed at least one
validated block and are included in all analyses.

## Design

The study used a 4 (Noun Condition: HH, HL, LH, LL) × 2 (Voice: Active, Passive)
within-participants design. Noun conditions were defined by the memorability level of the
subject and object nouns in each sentence:

| Stimulus prefix | Condition label | Subject noun | Object noun |
|---|---|---|---|
| HH  | HH | High memorability | High memorability |
| HVL | HL | High memorability | Low memorability  |
| LVH | LH | Low memorability  | High memorability |
| LVL | LL | Low memorability  | Low memorability  |
| HF  | —  | Filler (non-target) | — |

Voice was encoded in the trailing character of the stimulus ID: `A` = active,
`P` = passive (e.g., `HH_172_A`, `LVL_45_P`).

## Stimuli

We generated simple Subject–Verb–Object (S–V–O) sentences by systematically varying
the memorability of the subject and object nouns. High- and low-memorability nouns were
drawn from established word memorability norms. Verbs were selected from a fixed set of
medium-concreteness action verbs to minimise variability. This yielded four sentence
types: HH, HL, LH, and LL. Sentences were short (≤8 words), used no proper nouns, and
were phrased in natural spoken English. Automated fluency checks and
semantic-coherence filters removed ungrammatical or implausible sentences, followed by
manual screening.

From the resulting pool, 200 active-voice sentences were selected (50 per condition).
Each was also converted into a passive-voice form, producing paired active and passive
variants. This resulted in 400 target sentences across 8 conditions (4 noun-pair types ×
2 voices). An additional set of high-frequency filler sentences (prefix `HF`) was
included to provide false alarm opportunities and reduce list learning.

## Procedure

Participants completed a **continuous recognition** task. On each trial, a sentence was
presented on screen. Participants pressed the **Spacebar** (Immediate Recognition, IR)
if they believed the sentence was a repeat of one they had seen earlier in the session.
After every IR press, a forced-choice wording judgment (Wording Recognition, WR) was
presented, asking participants whether the sentence matched the exact grammatical voice
of the original (`Yes` = same voice, `No` = different voice).

The experiment was divided into three blocks, separated by short rest phases. Each
participant saw **48 target sentences** (16 per block) across the full session, balanced
across the 8 experimental conditions. Each target sentence appeared exactly twice: once
as an **encoding** trial (first presentation, `is_probe_repeat = FALSE`) and once as a
**probe** trial (second presentation, `is_probe_repeat = TRUE`). Filler and validation
sentences were interspersed throughout.

## Block Exclusion Criteria

Each block was evaluated for attentiveness using validation sentences — sentences
embedded in the stream specifically to test whether participants were pressing
appropriately. Three event types were used in the validation formula:

- **Correct validations** (`correct_val`): IR pressed on a validation repeat
- **Wrong IR presses** (`wrong_ir`): IR pressed on a non-repeat sentence
- **Missed validations** (`missed_val`): no IR press on a validation repeat

A block was deemed **valid** if:

> `correct_val > (wrong_ir / 2) + missed_val`

Blocks failing this criterion were excluded from all downstream analyses. Rows from
failed blocks were dropped in `src/preliminary/finalcleaning.R` before any scoring.
Of 336 possible participant-blocks (112 participants × 3 blocks), **329 blocks passed**
validation (97.9% pass rate). The block-level participant counts were: Block 1 (*n* = 108),
Block 2 (*n* = 109), Block 3 (*n* = 112).

## Computed Measures

### IR Corrected Recognition

Corrected recognition isolates true discriminability from response bias (liberal vs.
conservative Spacebar pressing). It is computed per participant per condition as:

> **Corrected IR = Hit Rate − False Alarm Rate**

**Hit rate** (per participant × noun condition × voice): the proportion of target probe
`Sentence shown` events (`is_target_sentence = TRUE`, `is_probe_repeat = TRUE`) for
which `ir_accuracy = 1` was recorded on the associated `IR pressed` event. Trials with
no IR press count as misses (hit = 0). Aggregated to participant × condition level
before subtracting the FA rate.

**False alarm rate** (per participant, global): the proportion of HF-filler first
showings (`svo = "HF"`, `is_probe_repeat = FALSE`) on which an IR press was recorded.
Validation sentence first showings are excluded from this denominator because they serve
a different experimental function. The FA rate is computed globally per participant
(not per condition) and subtracted uniformly across all condition cells.

### WR Accuracy

For trials where the participant made an IR press, a wording judgment was recorded
(`wr_accuracy = 1` correct, `wr_accuracy = 0` incorrect). WR accuracy is the proportion
of correct wording judgments per participant per condition, computed only over trials
where an IR press was made.

### IR Reaction Time

Extracted from `ir_reaction_time_ms` on `IR pressed` events for target probes.
Implausible RTs (> 10,000 ms) are excluded from all RT analyses.

## Aggregation Strategy

All statistical tests and visualisations follow a **participant-level aggregation**
approach to respect the nested structure of the data:

1. Compute the metric of interest (hit rate, corrected recognition, WR accuracy,
   mean RT) per **participant per condition** first.
2. Summarise across participants (grand mean, SE, CI) only at the reporting or
   plotting stage.

This avoids pseudoreplication and ensures that error bars reflect
between-participant variability. Standard error: SE = SD / √*n*. 95% confidence
intervals use the *t*-distribution: CI = *t*(0.975, df = *n* − 1) × SE.

## Statistical Analysis

Differences across the four noun conditions were tested with a non-parametric
**Kruskal-Wallis test** (the pre-registered choice, robust to non-normality given the
bounded [−1, 1] range of corrected recognition scores). Significant Kruskal-Wallis
results were followed up with **pairwise Wilcoxon rank-sum tests** with Holm correction
for multiple comparisons.

Voice effects (Active vs. Passive) were tested with paired **Wilcoxon signed-rank
tests**, since the same participants contributed scores in both voice conditions.
Above-chance performance for WR accuracy was assessed with one-sample Wilcoxon tests
against *μ* = 0.5.

All analyses were conducted in R (≥ 4.3) using the packages `dplyr`, `tidyr`, `ggplot2`,
`stringr`, and `scales`. Plots were saved as 300 DPI PNG files.

```

================================================================================
File: src/methods/results_stats.R
================================================================================

```
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

```

================================================================================
File: src/statistical_analysis/stats.R
================================================================================

```
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

```

================================================================================
File: src/preliminary/events.R
================================================================================

```
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

```

================================================================================
File: src/preliminary/data.R
================================================================================

```
# This script is for loading and validating the log files in the data directory.

data_dir <- "data/raw"

# number of files in the data directory
num_files <- length(list.files(data_dir))
print(paste("Number of files in the data directory:", num_files))

# each log file contains comma-separated values (CSV) with some columns.
# ill load all the columns only from each file first and validate if each file has the same columns. If not, flag the files with missing columns.

files <- list.files(data_dir, full.names = TRUE)

column_names <- function(file) {
  data <- read.csv(file, nrows = 1, fileEncoding = "UTF-8-BOM") # read only the first row to get column names
  return(colnames(data))
}

columns_list <- lapply(files, column_names)

# check if all files have the same columns
unique_columns <- unique(columns_list)

if (length(unique_columns) == 1) {
  print("All files have the same columns. The columns are:")
  print(unique_columns[[1]])
} else {
  print("Files have different columns. Here are the unique column sets:")
  print(unique_columns)
}

# row count for each file
row_counts <- sapply(files, function(file) {
  data <- read.csv(file, fileEncoding = "UTF-8-BOM")
  return(nrow(data))
})

# rows which have different row counts
if (length(unique(row_counts)) == 1) {
  print("All files have the same number of rows. The row count is:")
  print(unique(row_counts))
} else {
  print("Files have different row counts. Here are the row counts for each file:")
  print(data.frame(file = files, row_count = row_counts))
}

# load final dataframe with all files combined
load_log <- function(file) {
  df             <- read.csv(file, fileEncoding = "UTF-8-BOM", na.strings = "N/A")
  df$participant_id <- as.integer(tools::file_path_sans_ext(basename(file)))
  return(df)
}

all_data <- do.call(rbind, lapply(files, load_log))
all_data <- all_data[, c("participant_id", setdiff(colnames(all_data), "participant_id"))]

all_data$isTarget <- all_data$isTarget == "true"
all_data$isRepeat <- all_data$isRepeat == "true"
all_data$isValidation <- all_data$isValidation == "true"

cat(sprintf("\nCombined data frame has %d rows and %d columns from %d participants.\n", nrow(all_data), ncol(all_data), length(unique(all_data$participant_id))))

# saving the generated data frame to a new file for future use
output_file <- "data/processed/combined_data.csv"
write.csv(all_data, output_file, row.names = FALSE)
cat(sprintf("Combined data frame saved to %s\n", output_file))

```

================================================================================
File: src/preliminary/flagging.R
================================================================================

```
# now to analyse all the types of sentences (target, validation, etc) and find invalid participants
# load the cleaned data with practice rows removed
library(dplyr)

processed_data <- read.csv("data/processed/cleaned_data.csv")

# ── Step 1: Sentence type counts per participant (sanity check) ───────────────
sentence_counts <- processed_data |>
  filter(Event == "Sentence shown") |>
  group_by(participant_id) |>
  summarise(
    n_target_enc   = sum(isTarget == TRUE  & (is.na(isRepeat) | isRepeat == FALSE)),
    n_target_probe = sum(isTarget == TRUE  & isRepeat == TRUE),
    n_validation   = sum(isValidation == TRUE & isRepeat == TRUE),  # validation repeats
    n_filler       = sum(isTarget == FALSE & isValidation == FALSE),
    n_total        = n(),
    .groups = "drop"
  )
cat("── Sentence type breakdown per participant (first 6):\n")
print(head(sentence_counts))

cat("\nSummary across all participants:\n")
print(summary(sentence_counts[, -1]))

# ── Step 2: Compute validation counts per participant × block ─────────────────
# Three event types feed into the formula:
#   "Validation IR pressed"       → correct_val  (hit on a validation repeat)
#   "Validation Wrong IR pressed" → wrong_ir      (spacebar on a non-repeat)
#   "Validation Missed"           → missed_val    (no spacebar on a validation repeat)

validation_counts <- processed_data |>
  filter(block_id %in% c(1, 2, 3)) |>
  group_by(participant_id, block_id) |>
  summarise(
    correct_val = sum(Event == "Validation IR pressed"),
    wrong_ir    = sum(Event == "Validation Wrong IR pressed"),
    missed_val  = sum(Event == "Validation Missed"),
    .groups     = "drop"
  )
cat("\n── Validation counts (first 10 rows):\n")
print(head(validation_counts, 10))

# ── Step 3: Apply validation formula ─────────────────────────────────────────
# correct_val > (wrong_ir / 2) + missed_val
validation_counts <- validation_counts |>
  mutate(
    threshold   = (wrong_ir / 2) + missed_val,
    block_valid = correct_val > threshold
  )
cat("\n── Validation results (first 10 rows):\n")
print(head(validation_counts, 10))

# ── Step 4: Block-level pass/fail summary ─────────────────────────────────────
cat("\n── Block-level pass/fail:\n")
block_summary <- validation_counts |>
  group_by(block_id) |>
  summarise(
    n_pass    = sum(block_valid),
    n_fail    = sum(!block_valid),
    pass_rate = round(mean(block_valid) * 100, 1),
    .groups   = "drop"
  )
print(block_summary)

# ── Step 5: Participant-level summary ─────────────────────────────────────────
participant_summary <- validation_counts |>
  group_by(participant_id) |>
  summarise(
    blocks_passed = sum(block_valid),
    blocks_failed = sum(!block_valid),
    all_pass      = all(block_valid),
    .groups       = "drop"
  )

cat("\n── Participants by number of valid blocks:\n")
print(table(participant_summary$blocks_passed))

cat(sprintf("\nAll 3 blocks valid  : %d participants\n", sum(participant_summary$all_pass)))
cat(sprintf("1-2 blocks valid    : %d participants\n", sum(!participant_summary$all_pass & participant_summary$blocks_passed > 0)))
cat(sprintf("0 blocks valid      : %d participants\n", sum(participant_summary$blocks_passed == 0)))

# ── Step 6: Flag failing blocks in detail ────────────────────────────────────
cat("\n── Failed blocks (showing why each failed):\n")
failed <- validation_counts |>
  filter(!block_valid) |>
  arrange(participant_id, block_id)
print(failed)

cat(sprintf("\nTotal valid blocks   : %d / %d (%.1f%%)\n",
    sum(validation_counts$block_valid),
    nrow(validation_counts),
    mean(validation_counts$block_valid) * 100))

# ── Step 7: Attach block_valid back to trial data ────────────────────────────
# This is the key column every downstream script filters on.
processed_data <- processed_data |>
  left_join(
    validation_counts |> select(participant_id, block_id, block_valid),
    by = c("participant_id", "block_id")
  )

cat(sprintf("\nblock_valid attached: TRUE=%d  FALSE=%d  NA=%d\n",
    sum(processed_data$block_valid == TRUE,  na.rm = TRUE),
    sum(processed_data$block_valid == FALSE, na.rm = TRUE),
    sum(is.na(processed_data$block_valid))))

# ── Step 8: Save ──────────────────────────────────────────────────────────────
write.csv(processed_data,       "data/processed/pruned_data.csv",         row.names = FALSE)
write.csv(validation_counts,    "data/processed/validation_report.csv",     row.names = FALSE)
write.csv(participant_summary,  "data/processed/participant_validity.csv",  row.names = FALSE)

cat("\nSaved: pruned_data.csv, validation_report.csv, participant_validity.csv\n")


```

================================================================================
File: src/preliminary/final_cleaning.R
================================================================================

```
# loading the pruned data, to basically work with all the non-excluded blocks and participants
processed_data <- read.csv("data/processed/pruned_data.csv")

processed_data$participant_id <- NULL

processed_data <- processed_data |>
  dplyr::rename(
    participant_id            = participant_ID,
    event_timestamp_ms        = Timestamp,
    event_type                = Event,
    stimulus_id               = Stimulus,
    is_target_sentence        = isTarget,
    is_validation_sentence    = isValidation,
    is_probe_repeat           = isRepeat,
    response_button           = Button,
    ir_accuracy               = Accuracy.IR,
    wr_accuracy               = Accuracy.WR,
    ir_reaction_time_ms       = Reaction_time_IR,
    wr_reaction_time_ms       = Reaction_time_WR,
    ir_corrected_recognition  = CR_IR,
    wr_corrected_recognition  = CR_WR,
    block_id                  = block_id,
    block_passed_validation   = block_valid
  )

# ── Drop all rows from invalid blocks ─────────────────────────────────────────
rows_before <- nrow(processed_data)

processed_data <- processed_data[processed_data$block_passed_validation == TRUE, ]

cat(sprintf("Rows before exclusion : %d\n", rows_before))
cat(sprintf("Rows after exclusion  : %d\n", nrow(processed_data)))
cat(sprintf("Rows dropped          : %d  (from failed blocks)\n",
            rows_before - nrow(processed_data)))

# block_passed_validation is now redundant — every remaining row is TRUE
processed_data$block_passed_validation <- NULL

cat("\nFinal column names:\n")
print(colnames(processed_data))

cat(sprintf("\nFinal dimensions: %d rows × %d columns\n",
            nrow(processed_data), ncol(processed_data)))

cat(sprintf("Participants remaining: %d\n",
            length(unique(processed_data$participant_id))))

cat(sprintf("Valid blocks remaining: %d\n",
            nrow(unique(processed_data[, c("participant_id", "block_id")]))))

write.csv(processed_data, "data/processed/final_data.csv", row.names = FALSE)
cat("\nSaved: data/processed/final_data.csv\n")

```

================================================================================
File: src/visualization/viz.R
================================================================================

```
# viz.R — Publication-quality visualisations for the Sentence Memorability study
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

# ── Aesthetic constants ───────────────────────────────────────────────────────
palette_condition <- c(HH = "#6C5CE7", HL = "#00B894", LH = "#FDCB6E", LL = "#E17055")
palette_voice     <- c(Active = "#0984E3", Passive = "#D63031")
palette_8 <- c(
  "HH Active" = "#6C5CE7", "HH Passive" = "#A29BFE",
  "HL Active" = "#00B894", "HL Passive" = "#55EFC4",
  "LH Active" = "#FDCB6E", "LH Passive" = "#FFEAA7",
  "LL Active" = "#E17055", "LL Passive" = "#FAB1A0"
)

theme_memo <- function(base_size = 13) {
  theme_minimal(base_size = base_size) %+replace% theme(
    text             = element_text(family = "sans", colour = "#2D3436"),
    plot.title       = element_text(face = "bold", size = rel(1.25), hjust = 0,
                                    margin = margin(b = 8)),
    plot.subtitle    = element_text(size = rel(0.9), colour = "#636E72", hjust = 0,
                                    margin = margin(b = 12)),
    plot.caption     = element_text(size = rel(0.7), colour = "#B2BEC3", hjust = 1,
                                    margin = margin(t = 10)),
    axis.title       = element_text(size = rel(0.95), face = "bold"),
    axis.text        = element_text(size = rel(0.85), colour = "#636E72"),
    legend.position  = "top",
    legend.title     = element_text(face = "bold", size = rel(0.85)),
    legend.text      = element_text(size = rel(0.8)),
    panel.grid.major = element_line(colour = "#DFE6E9", linewidth = 0.3),
    panel.grid.minor = element_blank(),
    strip.text       = element_text(face = "bold", size = rel(0.9)),
    plot.background  = element_rect(fill = "#FAFAFA", colour = NA),
    panel.background = element_rect(fill = "#FAFAFA", colour = NA),
    plot.margin      = margin(15, 15, 15, 15)
  )
}

# ── Load data (snake_case columns from finalcleaning.R) ──────────────────────
df <- read.csv("data/processed/final_data.csv", stringsAsFactors = FALSE)

# Parse stimulus_id  ← FIX: was "stimulusid"
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

# ── Analysis-ready subsets  ← FIX: all column names corrected ─────────────────
probes_shown <- df %>%                              # target probe showings
  filter(event_type         == "Sentence shown",    # was: eventtype
         is_target_sentence == TRUE,                # was: istargetsentence
         is_probe_repeat    == TRUE,                # was: isproberepeat
         !is.na(noun_condition))

ir_hits <- df %>%                                   # IR presses on target probes
  filter(event_type         == "IR pressed",
         is_target_sentence == TRUE,
         is_probe_repeat    == TRUE,
         !is.na(noun_condition))

wr_presses <- df %>%                               # WR presses on target probes
  filter(event_type         == "WR pressed",
         is_target_sentence == TRUE,
         is_probe_repeat    == TRUE,
         !is.na(noun_condition))

# ── FA Rate  ← FIX: denominator is HF-only first showings, not all non-targets
n_hf_first <- df %>%
  filter(event_type         == "Sentence shown",
         is_target_sentence == FALSE,
         stim_prefix        == "HF",               # HF fillers only
         is_probe_repeat    == FALSE) %>%
  count(participant_id, name = "n_hf_shown")        # was: participantid

n_fa <- df %>%
  filter(event_type         == "IR pressed",
         is_target_sentence == FALSE,
         stim_prefix        == "HF",
         is_probe_repeat    == FALSE) %>%
  count(participant_id, name = "n_fa")

fa_rate <- merge(n_hf_first, n_fa, by = "participant_id", all.x = TRUE) %>%
  mutate(n_fa    = ifelse(is.na(n_fa), 0, n_fa),
         fa_rate = n_fa / n_hf_shown)

# ── Per-participant hit rates ──────────────────────────────────────────────────
hit_rates <- probes_shown %>%
  left_join(
    ir_hits %>% select(participant_id, stimulus_id, block_id,   # was: blockid
                       ir_hit = ir_accuracy,                    # was: iraccuracy
                       ir_rt  = ir_reaction_time_ms),           # was: irreactiontimems
    by = c("participant_id", "stimulus_id", "block_id")
  ) %>%
  mutate(ir_hit = ifelse(is.na(ir_hit), 0L, ir_hit)) %>%
  left_join(
    wr_presses %>% select(participant_id, stimulus_id, block_id,
                          wr_acc = wr_accuracy,                 # was: wraccuracy
                          wr_rt  = wr_reaction_time_ms),        # was: wrreactiontimems
    by = c("participant_id", "stimulus_id", "block_id")
  )

# Aggregated tables
hit_by_cond <- hit_rates %>%
  group_by(participant_id, noun_condition) %>%
  summarise(n_probes = n(), n_hits = sum(ir_hit, na.rm = TRUE),
            hit_rate = n_hits / n_probes, .groups = "drop") %>%
  left_join(fa_rate %>% select(participant_id, fa_rate), by = "participant_id") %>%
  mutate(fa_rate      = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

hit_by_cond_voice <- hit_rates %>%
  group_by(participant_id, noun_condition, voice) %>%
  summarise(n_probes = n(), n_hits = sum(ir_hit, na.rm = TRUE),
            hit_rate = n_hits / n_probes, .groups = "drop") %>%
  left_join(fa_rate %>% select(participant_id, fa_rate), by = "participant_id") %>%
  mutate(fa_rate      = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate)

wr_by_cond <- hit_rates %>%
  filter(!is.na(wr_acc)) %>%
  group_by(participant_id, noun_condition) %>%
  summarise(wr_accuracy = mean(wr_acc, na.rm = TRUE), .groups = "drop")

wr_by_cond_voice <- hit_rates %>%
  filter(!is.na(wr_acc)) %>%
  group_by(participant_id, noun_condition, voice) %>%
  summarise(wr_accuracy = mean(wr_acc, na.rm = TRUE), .groups = "drop")

# Factor ordering
lvls <- c("HH", "HL", "LH", "LL")
hit_by_cond$noun_condition           <- factor(hit_by_cond$noun_condition, levels = lvls)
hit_by_cond_voice$noun_condition     <- factor(hit_by_cond_voice$noun_condition, levels = lvls)
hit_by_cond_voice$voice              <- factor(hit_by_cond_voice$voice, levels = c("Active","Passive"))
wr_by_cond$noun_condition            <- factor(wr_by_cond$noun_condition, levels = lvls)
wr_by_cond_voice$noun_condition      <- factor(wr_by_cond_voice$noun_condition, levels = lvls)
wr_by_cond_voice$voice               <- factor(wr_by_cond_voice$voice, levels = c("Active","Passive"))

dir.create("plots", showWarnings = FALSE, recursive = TRUE)

# ── Plot 1: IR Corrected Recognition by Noun Condition ───────────────────────
p1 <- ggplot(hit_by_cond, aes(x = noun_condition, y = corrected_ir, fill = noun_condition)) +
  geom_violin(alpha = 0.35, colour = NA, width = 0.8, trim = FALSE) +
  geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.7,
               colour = "#2D3436", linewidth = 0.4) +
  geom_jitter(aes(colour = noun_condition), width = 0.08, alpha = 0.45,
              size = 1.2, shape = 16) +
  scale_fill_manual(values = palette_condition, guide = "none") +
  scale_colour_manual(values = palette_condition, guide = "none") +
  labs(title    = "Immediate Recognition (IR) by Noun Condition",
       subtitle = "Per-participant corrected recognition (hit rate − FA rate)",
       x        = "Noun Condition",
       y        = "Corrected Recognition",
       caption  = "Each point = one participant. HH = High–High, HL = High–Low, LH = Low–High, LL = Low–Low") +
  theme_memo() + theme(legend.position = "none")
ggsave("plots/01_ir_by_condition.png", p1, width = 8, height = 6, dpi = 300)

# ── Plot 2: WR Accuracy by Noun Condition ────────────────────────────────────
p2 <- ggplot(wr_by_cond, aes(x = noun_condition, y = wr_accuracy, fill = noun_condition)) +
  geom_violin(alpha = 0.35, colour = NA, width = 0.8, trim = FALSE) +
  geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.7,
               colour = "#2D3436", linewidth = 0.4) +
  geom_jitter(aes(colour = noun_condition), width = 0.08, alpha = 0.45,
              size = 1.2, shape = 16) +
  geom_hline(yintercept = 0.5, linetype = "dotted", colour = "#B2BEC3") +
  scale_fill_manual(values = palette_condition, guide = "none") +
  scale_colour_manual(values = palette_condition, guide = "none") +
  labs(title    = "Wording Recognition (WR) Accuracy by Noun Condition",
       subtitle = "Per-participant proportion correct voice judgments",
       x        = "Noun Condition", y = "Proportion Correct",
       caption  = "Dotted line = chance (50%). Each point = one participant.") +
  theme_memo() + theme(legend.position = "none")
ggsave("plots/02_wr_by_condition.png", p2, width = 8, height = 6, dpi = 300)

# ── Plot 3: Condition × Voice Interaction — IR ───────────────────────────────
ir_interaction <- hit_by_cond_voice %>%
  group_by(noun_condition, voice) %>%
  summarise(M  = mean(corrected_ir, na.rm = TRUE),
            SE = sd(corrected_ir,   na.rm = TRUE) / sqrt(n()), .groups = "drop")

p3 <- ggplot(ir_interaction, aes(x = noun_condition, y = M, fill = voice)) +
  geom_col(position = position_dodge(0.7), width = 0.6, alpha = 0.85) +
  geom_errorbar(aes(ymin = M - SE, ymax = M + SE),
                position = position_dodge(0.7), width = 0.18,
                linewidth = 0.5, colour = "#2D3436") +
  scale_fill_manual(values = palette_voice, name = "Voice") +
  labs(title    = "Noun Condition × Voice Interaction (IR)",
       subtitle = "Mean corrected recognition ± 1 SE",
       x = "Noun Condition", y = "Mean Corrected Recognition",
       caption  = "Error bars = ±1 SE") +
  theme_memo()
ggsave("plots/03_ir_condition_x_voice.png", p3, width = 9, height = 6, dpi = 300)

# ── Plot 4: Condition × Voice Interaction — WR ───────────────────────────────
wr_interaction <- wr_by_cond_voice %>%
  group_by(noun_condition, voice) %>%
  summarise(M  = mean(wr_accuracy, na.rm = TRUE),
            SE = sd(wr_accuracy,   na.rm = TRUE) / sqrt(n()), .groups = "drop")

p4 <- ggplot(wr_interaction, aes(x = noun_condition, y = M, fill = voice)) +
  geom_col(position = position_dodge(0.7), width = 0.6, alpha = 0.85) +
  geom_errorbar(aes(ymin = M - SE, ymax = M + SE),
                position = position_dodge(0.7), width = 0.18,
                linewidth = 0.5, colour = "#2D3436") +
  geom_hline(yintercept = 0.5, linetype = "dotted", colour = "#B2BEC3") +
  scale_fill_manual(values = palette_voice, name = "Voice") +
  labs(title    = "Noun Condition × Voice Interaction (WR)",
       subtitle = "Mean proportion correct wording judgments ± 1 SE",
       x = "Noun Condition", y = "Mean Proportion Correct",
       caption  = "Dotted line = chance (50%). Error bars = ±1 SE.") +
  theme_memo()
ggsave("plots/04_wr_condition_x_voice.png", p4, width = 9, height = 6, dpi = 300)

# ── Plot 5: RT Distributions by Noun Condition ───────────────────────────────
ir_rt <- ir_hits %>%
  filter(!is.na(ir_reaction_time_ms),           # was: irreactiontimems
         ir_reaction_time_ms > 0,
         ir_reaction_time_ms < 10000) %>%
  mutate(noun_condition = factor(noun_condition, levels = lvls))

p5 <- ggplot(ir_rt, aes(x = ir_reaction_time_ms, fill = noun_condition,
                         colour = noun_condition)) +
  geom_density(alpha = 0.3, linewidth = 0.7) +
  scale_fill_manual(values = palette_condition, name = "Noun Condition") +
  scale_colour_manual(values = palette_condition, name = "Noun Condition") +
  scale_x_continuous(labels = scales::comma_format()) +
  labs(title    = "IR Reaction Time Distributions by Noun Condition",
       subtitle = "Density of reaction times (ms) for IR presses on target probes",
       x = "Reaction Time (ms)", y = "Density",
       caption  = "RTs > 10 s excluded. Kernel density estimate.") +
  theme_memo()
ggsave("plots/05_ir_rt_density.png", p5, width = 9, height = 5.5, dpi = 300)

# ── Plot 6: Hit Rate vs False Alarm Rate ─────────────────────────────────────
participant_perf <- probes_shown %>%
  left_join(ir_hits %>% select(participant_id, stimulus_id, block_id,
                                ir_hit = ir_accuracy),
            by = c("participant_id", "stimulus_id", "block_id")) %>%
  mutate(ir_hit = ifelse(is.na(ir_hit), 0L, ir_hit)) %>%
  group_by(participant_id) %>%
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") %>%
  left_join(fa_rate %>% select(participant_id, fa_rate), by = "participant_id") %>%
  mutate(fa_rate = ifelse(is.na(fa_rate), 0, fa_rate))

p6 <- ggplot(participant_perf, aes(x = fa_rate, y = hit_rate)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed",
              colour = "#B2BEC3", linewidth = 0.5) +
  geom_point(colour = "#6C5CE7", alpha = 0.55, size = 2.5, shape = 16) +
  geom_smooth(method = "lm", se = TRUE, colour = "#D63031",
              fill = "#D63031", alpha = 0.15, linewidth = 0.8) +
  labs(title    = "Hit Rate vs. False Alarm Rate (IR)",
       subtitle = "Each point = one participant's overall performance",
       x = "False Alarm Rate", y = "Hit Rate",
       caption  = "Dashed line = chance performance. Red = linear fit ± 95% CI.") +
  theme_memo() +
  coord_fixed(xlim = c(0, 1), ylim = c(0, 1))
ggsave("plots/06_hit_vs_fa.png", p6, width = 7.5, height = 7, dpi = 300)

# ── Plot 7: Corrected IR Across Blocks ───────────────────────────────────────
hit_by_block <- hit_rates %>%
  group_by(participant_id, block_id, noun_condition) %>%      # was: blockid
  summarise(hit_rate = mean(ir_hit, na.rm = TRUE), .groups = "drop") %>%
  left_join(fa_rate %>% select(participant_id, fa_rate), by = "participant_id") %>%
  mutate(fa_rate      = ifelse(is.na(fa_rate), 0, fa_rate),
         corrected_ir = hit_rate - fa_rate,
         noun_condition = factor(noun_condition, levels = lvls))

block_summary <- hit_by_block %>%
  group_by(block_id, noun_condition) %>%
  summarise(M  = mean(corrected_ir, na.rm = TRUE),
            SE = sd(corrected_ir,   na.rm = TRUE) / sqrt(n()), .groups = "drop")

p7 <- ggplot(block_summary, aes(x = factor(block_id), y = M,
                                  colour = noun_condition, group = noun_condition)) +
  geom_line(linewidth = 1, alpha = 0.8) +
  geom_point(size = 3.5, shape = 21,
             aes(fill = noun_condition), colour = "#2D3436", stroke = 0.6) +
  geom_errorbar(aes(ymin = M - SE, ymax = M + SE), width = 0.12, linewidth = 0.5) +
  scale_colour_manual(values = palette_condition, name = "Noun Condition") +
  scale_fill_manual(values = palette_condition, name = "Noun Condition") +
  labs(title    = "IR Corrected Recognition Across Blocks",
       subtitle = "Mean ± 1 SE per noun condition across three experimental blocks",
       x = "Block", y = "Mean Corrected Recognition",
       caption  = "Blocks 1–3 = consecutive segments of the experiment.") +
  theme_memo()
ggsave("plots/07_block_learning.png", p7, width = 8, height = 5.5, dpi = 300)

# ── Plot 8: Per-Participant Heatmap ───────────────────────────────────────────
pid_order <- hit_by_cond %>%
  group_by(participant_id) %>%
  summarise(overall = mean(corrected_ir, na.rm = TRUE), .groups = "drop") %>%
  arrange(overall) %>%
  pull(participant_id)

heatmap_data <- hit_by_cond %>%
  mutate(participant_id = factor(participant_id, levels = pid_order))

p8 <- ggplot(heatmap_data, aes(x = noun_condition, y = participant_id,
                                 fill = corrected_ir)) +
  geom_tile(colour = "#FAFAFA", linewidth = 0.3) +
  scale_fill_gradient2(low = "#D63031", mid = "#FAFAFA", high = "#00B894",
                        midpoint = 0, name = "Corrected\nIR") +
  labs(title    = "Per-Participant IR Performance Heatmap",
       subtitle = "Rows sorted by overall mean corrected recognition (low → high)",
       x = "Noun Condition", y = "Participant (sorted)",
       caption  = "Green = strong recognition. Red = poor/negative.") +
  theme_memo() +
  theme(axis.text.y  = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid   = element_blank())
ggsave("plots/08_participant_heatmap.png", p8, width = 6.5, height = 10, dpi = 300)

# ── Plot 9: Voice Slope Chart ─────────────────────────────────────────────────
voice_summary <- hit_by_cond_voice %>%
  group_by(noun_condition, voice) %>%
  summarise(M  = mean(corrected_ir, na.rm = TRUE),
            SE = sd(corrected_ir,   na.rm = TRUE) / sqrt(n()), .groups = "drop")

p9 <- ggplot(voice_summary, aes(x = voice, y = M,
                                  colour = noun_condition, group = noun_condition)) +
  geom_line(linewidth = 1.2, alpha = 0.7) +
  geom_point(size = 4, shape = 19) +
  geom_errorbar(aes(ymin = M - SE, ymax = M + SE), width = 0.1, linewidth = 0.5) +
  scale_colour_manual(values = palette_condition, name = "Noun Condition") +
  labs(title    = "Active vs. Passive Voice Effect on IR",
       subtitle = "Mean corrected recognition ± 1 SE, connected by condition",
       x = "Grammatical Voice", y = "Mean Corrected Recognition",
       caption  = "Lines connect the same noun condition across voices.") +
  theme_memo()
ggsave("plots/09_voice_slope.png", p9, width = 7.5, height = 5.5, dpi = 300)

# ── Plot 10: IR vs WR Scatter ─────────────────────────────────────────────────
ir_wr_comp <- hit_by_cond %>%
  select(participant_id, noun_condition, corrected_ir) %>%
  left_join(wr_by_cond %>% select(participant_id, noun_condition, wr_accuracy),
            by = c("participant_id", "noun_condition"))

p10 <- ggplot(ir_wr_comp, aes(x = corrected_ir, y = wr_accuracy,
                                colour = noun_condition)) +
  geom_point(alpha = 0.5, size = 2, shape = 16) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.7, alpha = 0.7) +
  scale_colour_manual(values = palette_condition, name = "Noun Condition") +
  labs(title    = "IR Corrected Recognition vs. WR Accuracy",
       subtitle = "Per-participant, per-condition scores",
       x = "IR Corrected Recognition", y = "WR Proportion Correct",
       caption  = "Solid lines = per-condition linear fits.") +
  theme_memo()
ggsave("plots/10_ir_vs_wr.png", p10, width = 8, height = 6.5, dpi = 300)

# ── Plot 11: WR Accuracy by Voice ─────────────────────────────────────────────
wr_voice <- hit_rates %>%
  filter(!is.na(wr_acc)) %>%
  group_by(participant_id, voice) %>%
  summarise(prop_correct = mean(wr_acc, na.rm = TRUE), .groups = "drop") %>%
  mutate(voice = factor(voice, levels = c("Active", "Passive")))

p11 <- ggplot(wr_voice, aes(x = voice, y = prop_correct, fill = voice)) +
  geom_violin(alpha = 0.3, colour = NA, width = 0.7, trim = FALSE) +
  geom_boxplot(width = 0.15, outlier.shape = NA, alpha = 0.7,
               colour = "#2D3436", linewidth = 0.4) +
  geom_jitter(aes(colour = voice), width = 0.06, alpha = 0.4,
              size = 1.3, shape = 16) +
  geom_hline(yintercept = 0.5, linetype = "dotted", colour = "#B2BEC3") +
  scale_fill_manual(values = palette_voice, guide = "none") +
  scale_colour_manual(values = palette_voice, guide = "none") +
  labs(title    = "Wording Recognition Accuracy by Voice",
       subtitle = "Per-participant proportion correct on voice judgments",
       x = "Original Voice of Sentence", y = "Proportion Correct",
       caption  = "Dotted line = chance (50%). Each point = one participant.") +
  theme_memo() + theme(legend.position = "none")
ggsave("plots/11_wr_accuracy_by_voice.png", p11, width = 7, height = 6, dpi = 300)

# ── Plot 12: Forest Plot ──────────────────────────────────────────────────────
forest_data <- hit_by_cond_voice %>%
  group_by(noun_condition, voice) %>%
  summarise(M     = mean(corrected_ir, na.rm = TRUE),
            SE    = sd(corrected_ir,   na.rm = TRUE) / sqrt(n()),
            n     = n(),
            CI95  = qt(0.975, n - 1) * SE, .groups = "drop") %>%
  mutate(label = paste0(noun_condition, " ", voice))

forest_data$label <- factor(forest_data$label,
                              levels = forest_data$label[order(forest_data$M)])

p12 <- ggplot(forest_data, aes(x = M, y = label, colour = voice)) +
  geom_vline(xintercept = 0, linetype = "dashed",
             colour = "#B2BEC3", linewidth = 0.4) +
  geom_errorbar(aes(xmin = M - CI95, xmax = M + CI95),
                height = 0.25, linewidth = 0.6) +
  geom_point(size = 3.5, shape = 19) +
  scale_colour_manual(values = palette_voice, name = "Voice") +
  labs(title    = "Forest Plot: IR Corrected Recognition by Condition × Voice",
       subtitle = "Mean ± 95% CI (participant-level), ranked by mean",
       x = "Mean Corrected Recognition", y = NULL,
       caption  = "Dashed line = zero (no discrimination). CI = 95% t-interval.") +
  theme_memo() + theme(panel.grid.major.y = element_blank())
ggsave("plots/12_forest_plot.png", p12, width = 9, height = 5.5, dpi = 300)

cat("All 12 plots saved to plots/\n")

```


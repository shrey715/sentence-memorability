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

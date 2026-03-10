# Methods

## Participants

Data were collected from online participants via a web-based continuous recognition experiment. A total of 114 participants started the experiment. Two participants (IDs 271 and 299) failed the validation criterion on all three blocks and were excluded entirely, leaving **112 participants** in the final sample.

## Design

The study used a **4 (Noun Condition: HH, HL, LH, LL) × 2 (Voice: Active, Passive)** within-participants design. Noun conditions were defined by crossing the imageability/memorability level of the subject and object nouns in each sentence:

| Code | Subject Noun | Object Noun |
|------|-------------|-------------|
| HH   | High memorability | High memorability |
| HL   | High memorability | Low memorability  |
| LH   | Low memorability  | High memorability |
| LL   | Low memorability  | Low memorability  |

Grammatical voice (active vs. passive) was fully crossed with noun condition, yielding **8 within-participant cells**. An additional set of high-frequency filler sentences (coded HF) served as lures for computing false alarm rates.

## Stimuli

Simple Subject–Verb–Object (S–V–O) sentences were constructed by systematically varying the memorability of the subject and object nouns. High- and low-memorability nouns were drawn from established word memorability norms. Verbs were selected from a fixed set of medium-concreteness action verbs to minimise verb-level variability. This yielded four sentence types (HH, HL, LH, LL). Sentences were short (≤ 8 words), contained no proper nouns, and were phrased in natural spoken English. Automated fluency checks and semantic-coherence filters removed ungrammatical or implausible items, followed by manual screening.

From the resulting pool, 200 active-voice sentences were selected (50 per condition). Each sentence was also converted into a passive-voice form, producing paired active and passive variants. This yielded **400 target sentences** across the 8 conditions. An additional set of HF filler sentences was included to provide false alarm opportunities and reduce list-learning strategies.

## Procedure

Participants completed a **continuous recognition** task. On each trial, a sentence was displayed on screen. Participants pressed the **Spacebar** (Immediate Recognition, IR) if they believed the sentence was a repeat of one seen earlier in the session. After every IR press, a forced-choice wording judgment (Wording Recognition, WR) was presented, asking whether the sentence matched the exact grammatical voice of the original (Yes = same voice, No = different voice).

The experiment was divided into **three blocks**, separated by short rest phases. Each participant saw 222 sentences per session, of which **48 were target sentences** (16 per block), balanced across the 8 experimental conditions. Each target sentence appeared exactly twice: once as an **encoding trial** (first presentation) and once as a **probe trial** (second presentation). Filler and validation sentences were interspersed throughout.

## Data Processing Pipeline

### Step 1: Loading and Combining Raw Data

Individual participant log files (`.log` format, CSV-encoded) were loaded from `data/raw/`. Column names were standardised (e.g., `participant_ID` → `participant_id`, `Reaction_time_IR` → `ir_reaction_time_ms`), and Boolean fields (`isTarget`, `isRepeat`, `isValidation`) were converted from string to logical type. The combined dataset was saved as `combined_data.csv`.

### Step 2: Event Cleaning

Practice trials and inter-stimulus-interval (`gap_time`) rows were removed. A `block_id` variable was assigned by counting `Rest Phase started` events within each participant, and only blocks 1–3 were retained. The cleaned dataset was saved as `cleaned_data.csv`.

### Step 3: Participant and Block Validation

Each block was evaluated for attentiveness using embedded validation sentences. Three quantities were computed per participant per block:

- **Correct validations** (`correct_val`): IR presses on validation repeats
- **Wrong IR presses** (`wrong_ir`): IR presses on non-repeat sentences
- **Missed validations** (`missed_val`): no IR press on validation repeats

A block was deemed **valid** if and only if:

$$\text{correct\_val} > \frac{\text{wrong\_ir}}{2} + \text{missed\_val}$$

Of 336 possible participant-blocks (112 participants × 3 blocks), **329 passed** (97.9% pass rate). Block-level counts after exclusion were: Block 1 (*n* = 108), Block 2 (*n* = 109), Block 3 (*n* = 112). Failed blocks were flagged, and all rows from failed blocks were removed in the next step. The validated dataset was saved as `pruned_data.csv`.

### Step 4: Finalisation

Rows from failed blocks were dropped. Noun condition labels were normalised (e.g., `HVL` → `HL`, `LVH` → `LH`, `LVL` → `LL`). Grammatical voice was parsed from the trailing character of each stimulus ID (`A` = Active, `P` = Passive). Reaction time outliers were trimmed: any IR or WR reaction time below 200 ms or exceeding the participant's mean + 3 SD was set to `NA`. The final analysis-ready dataset (`final_data.csv`) comprised **72,627 rows** across 15 columns.

## Dependent Variables

### Corrected IR (Immediate Recognition)

Corrected recognition isolates true discriminability from response bias. It was computed per participant per condition as:

$$\text{Corrected IR} = \text{Hit Rate} - \text{False Alarm Rate}$$

- **Hit rate** (per participant × noun condition × voice): the proportion of target probe presentations on which an IR press was recorded.
- **False alarm rate** (per participant, global): the proportion of HF-filler first showings on which an IR press was recorded. This rate was computed once per participant and subtracted uniformly across all condition cells.

### WR Accuracy (Wording Recognition)

For trials where an IR press was made, the subsequent wording judgment was scored: `wr_accuracy = 1` (correct voice identification) or `wr_accuracy = 0` (incorrect). WR accuracy is the proportion of correct wording judgments per participant per condition, conditional on an IR response having been made.

### Reaction Times

IR and WR reaction times (in ms) were extracted from target probe trials. After outlier trimming (< 200 ms or > *M* + 3*SD* per participant), mean reaction times were computed per participant per condition.

### Signal Detection Measures

Sensitivity (*d'*) and response criterion (*c*) were also computed per condition to complement the corrected recognition analysis.

## Aggregation Strategy

All statistical tests and visualisations followed a **participant-level aggregation** approach:

1. Compute each metric (corrected recognition, WR accuracy, mean RT) per **participant per condition**.
2. Summarise across participants (grand mean, SE, CI) only at the reporting or plotting stage.

This avoids pseudoreplication and ensures that error bars and test statistics reflect between-participant variability. Standard errors were computed as SE = SD / √*n*; 95% confidence intervals used the *t*-distribution.

## Statistical Analysis

Normality of the four key metrics (IR corrected recognition, WR accuracy, IR RT, WR RT) was assessed using **Shapiro–Wilk tests**. All metrics showed significant departures from normality (*p* < .05), justifying non-parametric inference throughout.

Differences across the four noun conditions (HH, HL, LH, LL) were tested with **Kruskal–Wallis rank-sum tests**. Significant omnibus results were followed up with **pairwise Wilcoxon rank-sum tests** with Holm correction for multiple comparisons. Effect sizes were quantified using **epsilon-squared** (ε²) for the omnibus test and **Cliff's delta** (δ) for pairwise comparisons.

The interaction between noun condition and grammatical voice was assessed using the **Scheirer–Ray–Hare test** (a non-parametric analogue of two-way ANOVA, suitable for rank-based data).

Voice effects (Active vs. Passive) were tested with paired **Wilcoxon signed-rank tests**. Above-chance WR performance was verified with one-sample Wilcoxon tests against μ = 0.5.

Block effects on IR were tested with a Kruskal–Wallis test across the three blocks. Lag effects (encoding-to-probe distance) were examined by binning trials into quartiles by lag and computing mean IR hit rate and WR accuracy per bin.

Bootstrap 95% confidence intervals (10,000 resamples, bias-corrected and accelerated) were computed for each condition's mean corrected IR.

All analyses were conducted in **R (≥ 4.3)** using the packages `dplyr`, `tidyr`, `ggplot2`, `ggdist`, `stringr`, `moments`, `rcompanion`, and `boot`. Visualisations were saved as 200 DPI PNG files.

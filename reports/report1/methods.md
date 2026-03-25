# Methods

## Participants

Data were collected from online participants via a web-based continuous recognition experiment. A total of 114 participants started the experiment. Two participants failed the validation criterion on all three blocks and were excluded entirely, leaving **112 participants** in the final sample.

## Design

The study used a **4 (Noun Condition: HH, HL, LH, LL) x 2 (Voice: Active, Passive)** within-participants design. Noun conditions were defined by crossing the memorability level of the subject and object nouns in each sentence:

| Code | Subject Noun      | Object Noun       |
| ---- | ----------------- | ----------------- |
| HH   | High memorability | High memorability |
| HL   | High memorability | Low memorability  |
| LH   | Low memorability  | High memorability |
| LL   | Low memorability  | Low memorability  |

Grammatical voice (active vs. passive) was fully crossed with noun condition, yielding **8 within-participant cells**. An additional set of high-frequency filler sentences (coded HF) served as lures for computing false alarm rates.

## Stimuli

Simple Subject-Verb-Object (S-V-O) sentences were constructed by systematically varying the memorability of the subject and object nouns. High- and low-memorability nouns were selected from established norms, while verbs were drawn from a fixed set of medium-concreteness action verbs.

Sentences were kept short (8 words or fewer), contained no proper nouns, and used natural spoken English. They were filtered for semantic coherence and fluency, then manually screened. From the resulting pool, 200 active-voice sentences were selected (50 per condition). Each was converted into a passive-voice form, yielding **400 target sentences** across 8 conditions. An additional set of HF filler sentences was included to provide false alarm opportunities.

## Procedure

Participants completed a **continuous recognition** task. Each participant saw 48 target sentences across **3 blocks**. As probes appeared, participants provided judgments regarding whether they recognised the sentence (Immediate Recognition, IR) or whether its grammatical voice matched the original presentation (Wording Recognition, WR).

## Data Processing Pipeline

### Step 1: Loading and Combining Raw Data (`01_load_and_combine.R`)

Individual participant log files (`.log` format, CSV-encoded) were loaded from `data/raw/`. Column names were standardised and Boolean fields were converted from string to logical type. The combined dataset was saved as `combined_data.csv`.

### Step 2: Event Cleaning (`02_clean_events.R`)

Practice trials and inter-stimulus-interval (`gap_time`) rows were removed. A `block_id` variable was assigned by counting `Rest Phase started` events within each participant, and only blocks 1-3 were retained. The cleaned dataset was saved as `cleaned_data.csv`.

### Step 3: Block Validation (`03_validate_participants.R`)

Each block was evaluated using the validation formula:

$$\text{Correct Validations (IRs)} > \frac{\text{Wrong IRs}}{2} + \text{Missed Validations (IRs)}$$

Failed blocks were flagged and the validation report was saved.

### Step 4: Finalisation (`04_finalize_dataset.R`)

Rows from failed blocks were dropped. Noun condition labels were normalised (e.g., `HVL` to `HL`). Grammatical voice was parsed from each stimulus ID (`A` = Active, `P` = Passive). The final analysis-ready dataset was saved as `final_data.csv`.

## Dependent Variables

### Corrected IR (Immediate Recognition)

Corrected recognition was computed per participant per condition as:

$$\text{Corrected IR} = \text{Hit Rate} - \text{False Alarm Rate}$$

- **Hit rate** (per participant x noun condition x voice): proportion of target probe presentations on which an IR press was recorded.
- **False alarm rate** (per participant, global): proportion of HF-filler first showings on which an IR press was recorded.

### WR Accuracy (Wording Recognition)

For trials where an IR press was made, the wording judgment was scored: `wr_accuracy = 1` (correct voice identification) or `wr_accuracy = 0` (incorrect). WR accuracy is the proportion of correct wording judgments per participant per condition, conditional on an IR response having been made.

### Reaction Times

IR reaction times (in ms) were extracted from target probe trials. Mean reaction times were computed per participant per condition.

## Statistical Analysis

Normality of the key metrics (IR corrected recognition, WR accuracy, IR RT) was assessed using **Shapiro-Wilk tests**. All metrics showed significant departures from normality (_p_ < .05), justifying non-parametric inference throughout.

The following tests were conducted:

1. **Kruskal-Wallis rank-sum tests**: Differences across the four noun conditions (HH, HL, LH, LL) for corrected IR, WR accuracy, and IR RT. Effect sizes were quantified using **epsilon-squared** (epsilon^2).
2. **Pairwise Wilcoxon rank-sum tests**: Post-hoc comparisons with Holm correction, conducted only when the omnibus KW test was significant.
3. **Scheirer-Ray-Hare tests**: Non-parametric analogue of two-way ANOVA, testing the noun condition x voice interaction on corrected IR and WR accuracy.
4. **Paired Wilcoxon signed-rank tests**: Active vs. Passive voice effects on corrected IR and WR accuracy (collapsed across noun conditions).
5. **One-sample Wilcoxon tests**: WR accuracy vs. chance (0.5) for each voice, testing whether participants could discriminate voice above chance.

All analyses were conducted in **R (>= 4.3)** using `dplyr`, `tidyr`, `ggplot2`, `ggdist`, `stringr`, and `rcompanion`.

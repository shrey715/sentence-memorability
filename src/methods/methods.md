# Methods — Visualization Analysis

## 1. Data Source & Filtering

All analyses use **`data/processed/final_data.csv`** — the fully validated dataset (72,627 event rows × 15 columns, 112 participants, 329 valid blocks).

### Analysis Subset

Visualizations focus exclusively on **target probe sentences**, identified by:

```
event_type == "Sentence shown"  AND
is_target_sentence == TRUE      AND
is_probe_repeat == TRUE
```

This yields the second presentation of each target sentence — the moment when recognition is tested. Each participant contributes 48 target probes (16 per block × 3 blocks), balanced across 8 conditions (4 noun-pair types × 2 voices).

### Condition Coding

Stimulus IDs (e.g., `HH_172_A`) encode experimental conditions:

| Data prefix | Mapped condition | Subject noun | Object noun |
|-------------|-----------------|--------------|-------------|
| `HH`        | HH              | High         | High        |
| `HVL`       | HL              | High         | Low         |
| `LVH`       | LH              | Low          | High        |
| `LVL`       | LL              | Low          | Low         |
| `HF`        | (filler)        | —            | —           |

The trailing character denotes **voice**: `A` = active, `P` = passive.

---

## 2. Computed Measures

### 2.1 IR Corrected Recognition

Since the `ir_corrected_recognition` column is not pre-computed in the data file, we derive it from the raw event-level data:

1. **Hit rate** (per participant × condition): Proportion of target probe sentences where the participant pressed the spacebar (IR pressed), computed from `ir_accuracy == 1` on IR-pressed rows linked back to `Sentence shown` target probes. Misses (no IR press on a target probe) count as 0.

2. **False alarm rate** (per participant, global): Proportion of non-target, non-repeat sentences that received an erroneous IR press, divided by the total number of non-target sentence presentations.

3. **Corrected recognition**: `hit_rate − fa_rate` (per participant × condition). This subtraction removes response bias (liberal vs. conservative pressing tendency) and isolates true discrimination.

### 2.2 WR (Wording Recognition) Accuracy

For each target probe where the participant made an IR press and then judged the wording (Yes/No), `wr_accuracy == 1` indicates a correct voice judgment. WR accuracy is computed as the proportion of correct wording judgments, aggregated per participant × condition × voice.

### 2.3 IR Reaction Time

Extracted from `ir_reaction_time_ms` on `IR pressed` events for target probes. Implausible RTs (> 10,000 ms) are excluded.

---

## 3. Aggregation Strategy

All visualizations follow a **participant-level aggregation** approach to respect the nested data structure:

1. Compute the relevant metric (hit rate, corrected recognition, WR accuracy, mean RT) **per participant per condition** first.
2. Summarize across participants (grand mean, SE, CI) only at the plotting stage.

This avoids pseudoreplication and ensures that error bars / confidence intervals reflect between-participant variability, not trial-level noise.

Standard error: `SE = SD / √n`, where `n` = number of participants contributing to that cell.
95% confidence intervals use the t-distribution: `CI = t₀.₉₇₅,df × SE`.

---

## 4. Plot Descriptions & Significance

### Plot 1 — IR Corrected Recognition by Noun Condition
**File:** `plots/01_ir_by_condition.png`

- **Type:** Violin + boxplot + jittered points (rain-cloud hybrid)
- **What it shows:** Distribution of per-participant corrected IR scores for each noun condition (HH, HL, LH, LL).
- **Significance:** This is the **primary outcome measure**. If noun memorability affects sentence recognition, we expect HH > HL ≈ LH > LL — a graded pattern reflecting the contribution of individual nouns. The violin captures the full distributional shape, the box summarizes quartiles, and individual points show potential outliers or floor/ceiling effects.

---

### Plot 2 — WR Accuracy by Noun Condition
**File:** `plots/02_wr_by_condition.png`

- **Type:** Violin + boxplot + jittered points
- **What it shows:** Per-participant proportion of correct wording (voice) judgments for each noun condition.
- **Significance:** Tests whether noun memorability also affects sensitivity to **surface form** (active vs. passive). A dotted line at 0.50 marks chance — above-chance performance indicates participants can discriminate exact wording, not just meaning.

---

### Plot 3 — Noun Condition × Voice Interaction (IR)
**File:** `plots/03_ir_condition_x_voice.png`

- **Type:** Grouped bar chart with ±1 SE error bars
- **What it shows:** Mean corrected IR recognition for each of the 8 cells (4 conditions × 2 voices).
- **Significance:** Tests the **interaction hypothesis** — does the voice manipulation differentially affect recognition of high- vs. low-memorability sentences? If voice changes disrupt recognition more for LL sentences, this would imply that low-memorability nouns make recognition more fragile and dependent on surface cues.

---

### Plot 4 — Noun Condition × Voice Interaction (WR)
**File:** `plots/04_wr_condition_x_voice.png`

- **Type:** Grouped bar chart with ±1 SE error bars
- **What it shows:** Mean WR accuracy across the 8 condition × voice cells.
- **Significance:** Parallels Plot 3 for wording recognition. Differential WR accuracy by voice (e.g., if active sentences are better discriminated than passive ones) or by condition (e.g., if HH shows higher WR) reveals whether **deep encoding** (high-memorability nouns) also preserves veridical surface form memory.

---

### Plot 5 — IR Reaction Time Distributions by Noun Condition
**File:** `plots/05_ir_rt_density.png`

- **Type:** Overlapping kernel density curves
- **What it shows:** RT distributions (in ms) for IR presses on target probes, separated by noun condition.
- **Significance:** RT is a proxy for **recognition confidence and processing effort**. Faster RTs for HH sentences would suggest stronger or more automatic memory traces. The density approach reveals the full shape (skew, modality) rather than just means — important because RT distributions are typically right-skewed.

---

### Plot 6 — Hit Rate vs False Alarm Rate (IR)
**File:** `plots/06_hit_vs_fa.png`

- **Type:** Scatter plot with linear regression line
- **What it shows:** Per-participant overall hit rate (y-axis) against false alarm rate (x-axis).
- **Significance:** Visualizes **individual differences in signal detection**. The diagonal dashed line represents chance (hit = FA). Points well above the diagonal indicate good discriminability (d' > 0), while the spread reveals participant-level variability. A negative relationship (high FA → low hits) would suggest response bias contaminating discrimination. This plot validates that the corrected recognition measure is appropriate.

---

### Plot 7 — IR Corrected Recognition Across Blocks
**File:** `plots/07_block_learning.png`

- **Type:** Connected line plot with ±1 SE error bars
- **What it shows:** Mean corrected IR by condition across Blocks 1, 2, and 3.
- **Significance:** Tests for **practice/fatigue effects** over the experiment. If recognition improves, participants are learning the task; if it declines, they may be fatiguing or experiencing proactive interference (old sentences contaminating new ones). Condition-specific slopes reveal whether some conditions are more susceptible to these temporal dynamics.

---

### Plot 8 — Per-Participant IR Heatmap
**File:** `plots/08_participant_heatmap.png`

- **Type:** Tile heatmap (rows = participants, columns = conditions)
- **What it shows:** Each cell is one participant's corrected IR score for one condition. Rows are sorted by overall performance.
- **Significance:** Reveals **individual differences and condition-specific patterns** at a glance. Consistent green bands across conditions indicate uniformly strong participants; red bands indicate weak ones. Systematic colour shifts across columns (e.g., HH always greener than LL) confirm the group-level effect is not driven by a few outliers.

---

### Plot 9 — Active vs Passive Voice: Slope Chart (IR)
**File:** `plots/09_voice_slope.png`

- **Type:** Slope/slopegraph with ±1 SE error bars
- **What it shows:** Each line connects the same noun condition across Active and Passive voice.
- **Significance:** Directly visualizes the **main effect of voice** and possible interactions. Parallel lines indicate no interaction (voice affects all conditions equally). Convergent or divergent lines indicate an interaction — e.g., if voice changes hurt LL recognition more than HH, the LL line would show a steeper slope.

---

### Plot 10 — IR Corrected Recognition vs WR Accuracy
**File:** `plots/10_ir_vs_wr.png`

- **Type:** Scatter with per-condition linear fits
- **What it shows:** Per-participant per-condition IR scores (x-axis) vs. WR accuracy (y-axis).
- **Significance:** Tests the **relationship between meaning and wording memory**. A positive correlation suggests that participants who discriminate meaning better also remember the exact voice — consistent with a unitary trace theory. Dissociation (weak correlation) would support dual-trace theories where meaning and surface form are stored independently.

---

### Plot 11 — WR Accuracy by Voice
**File:** `plots/11_wr_accuracy_by_voice.png`

- **Type:** Violin + boxplot + jittered points
- **What it shows:** Per-participant WR accuracy, split by whether the sentence was originally presented in active vs. passive voice.
- **Significance:** Tests whether **active-voice sentences produce stronger surface-form memory** than passive-voice sentences (or vice versa). The dotted chance line at 0.50 contextualizes the magnitude of the effect. Asymmetry between voices would indicate a voice-specific encoding advantage.

---

### Plot 12 — Forest Plot: IR Corrected Recognition by Condition × Voice
**File:** `plots/12_forest_plot.png`

- **Type:** Forest plot (point estimates + 95% CI horizontal error bars)
- **What it shows:** All 8 condition × voice cells ranked by mean corrected recognition.
- **Significance:** Provides a **summary overview** of the entire factorial design in one figure. The 95% CIs allow informal assessment of which conditions differ — non-overlapping CIs suggest statistically reliable differences. The vertical dashed line at zero distinguishes genuine recognition from chance. This plot is ideal for an at-a-glance comparison of all experimental conditions.

---

## 5. Software & Packages

All visualizations are produced in **R** using:
- `ggplot2` — grammar-of-graphics plotting
- `dplyr` / `tidyr` — data wrangling
- `stringr` — stimulus ID parsing
- `scales` — axis formatting

Plots are saved as 300 DPI PNG files in the `plots/` directory.

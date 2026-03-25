# Analysis Pipeline

## Overview

The pipeline is orchestrated by `src/main.R`, which sources each script in sequence
and logs all output to a timestamped log file.

```
┌──────────────────────────────────────────────────────────────────┐
│                         src/main.R                               │
│              (orchestrator — runs all phases)                     │
└──────────────────────────┬───────────────────────────────────────┘
                           │
         ┌─────────────────┼─────────────────────┐
         ▼                 ▼                     ▼
   PHASE 1            PHASE 2              PHASE 3
 Preprocessing    Descriptives &        Inferential
                   Normality            Statistics
         │                 │                     │
         ▼                 ▼                     ▼
   PHASE 4
 Visualization
```

---

## Phase 1: Preprocessing

```
data/raw/*.log
      │
      ▼
┌─────────────────────────────────────┐
│  01_load_and_combine.R              │
│  • Load all .log files              │
│  • Standardise column names         │
│  • Convert boolean strings → logic  │
│  • Merge into single data frame     │
├─────────────────────────────────────┤
│  Output: combined_data.csv          │
│  (all raw rows, all participants)   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  02_clean_events.R                  │
│  • Remove practice trials           │
│  • Remove gap_time rows             │
│  • Assign block_id (1, 2, 3)        │
│  • Cap at 3 blocks per participant  │
├─────────────────────────────────────┤
│  Output: cleaned_data.csv           │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  03_validate_participants.R         │
│  • Count correct_val, wrong_ir,     │
│    missed_val per participant×block  │
│  • Apply validation formula:        │
│    correct > wrong/2 + missed       │
│  • Flag blocks as valid/invalid     │
├─────────────────────────────────────┤
│  Output: pruned_data.csv            │
│          validation_report.csv      │
│          validation_summary.txt     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  04_finalize_dataset.R              │
│  • Drop rows from failed blocks     │
│  • Normalise condition labels       │
│    (HVL→HL, LVH→LH, LVL→LL)       │
│  • Parse voice from stimulus ID     │
│    (trailing A/P → Active/Passive)  │
│  • Trim RT outliers                 │
│    (<200ms or >M+3SD per person)    │
├─────────────────────────────────────┤
│  Output: final_data.csv             │
│  (72,627 rows × 15 cols,            │
│   112 participants, 329 blocks)     │
└──────────────┬──────────────────────┘
               │
               ▼
      ╔════════════════════╗
      ║  ANALYSIS-READY    ║
      ║  final_data.csv    ║
      ╚════════╤═══════════╝
               │
    ┌──────────┴──────────┐
    ▼                     ▼
```

---

## Phase 2: Descriptives & Normality (`results_stats.R`)

```
final_data.csv
      │
      ▼
┌─────────────────────────────────────┐
│  results_stats.R                    │
│                                     │
│  Step 1: IR False Alarm Rates       │
│    • Count HF first-showings        │
│    • Count IR presses on HF firsts  │
│    • Compute per-participant FA rate │
│                                     │
│  Step 2: IR Hit Counts              │
│    • Count target probe showings    │
│    • Count IR hits on target probes │
│    per participant × condition × v. │
│                                     │
│  Step 3: WR Conditional Accuracy    │
│    • Among WR presses on targets:   │
│      proportion with wr_accuracy=1  │
│                                     │
│  Step 4: Mean Reaction Times        │
│    • Mean IR RT and WR RT per       │
│      participant × condition × voice│
│                                     │
│  Step 5: Compile CR Scores          │
│    • Join hits, FA, WR, RTs         │
│    • Corrected IR = hit rate − FA   │
│                                     │
│  Step 6: Descriptive Statistics     │
│    • N, Mean, Median, Min, Max,     │
│      IQR, Skewness, Kurtosis       │
│    per condition × voice × metric   │
│                                     │
│  Step 7: Shapiro-Wilk Normality     │
│    • Test each metric for normality │
│    • All non-normal → justifies     │
│      non-parametric tests           │
├─────────────────────────────────────┤
│  Outputs:                           │
│    data/processed/cr_scores.csv     │
│    data/processed/stats_summary.csv │
│    outputs/stats/fa_rates.txt       │
│    outputs/stats/descriptives.txt   │
│    outputs/stats/normality.txt      │
└──────────────┬──────────────────────┘
               │
               ▼
```

---

## Phase 3: Inferential Statistics (`05_statistical_tests.R`)

```
cr_scores.csv
      │
      ▼
┌─────────────────────────────────────┐
│  05_statistical_tests.R             │
│                                     │
│  Omnibus Tests (Kruskal-Wallis):    │
│    • ir_cr ~ noun_condition         │
│    • wr_acc_score ~ noun_condition  │
│    • ir_rt ~ noun_condition         │
│    + epsilon² effect sizes          │
│                                     │
│  Post-hoc (if p < .05):            │
│    • Pairwise Wilcoxon (Holm corr.) │
│                                     │
│  Interaction Tests:                 │
│    • Scheirer-Ray-Hare:             │
│      ir_cr ~ condition * voice      │
│      wr_acc ~ condition * voice     │
│                                     │
│  Additional analyses:               │
│    • Cliff's delta pairwise         │
│    • Voice paired Wilcoxon          │
│    • Block effects (KW)             │
│    • Lag quartile analysis          │
│    • SDT (d', criterion c)          │
│    • Bootstrap CIs                  │
├─────────────────────────────────────┤
│  Outputs:                           │
│    outputs/stats/statistical_tests  │
│    data/processed/stats/*.csv       │
│    (16 summary CSV files)           │
└──────────────┬──────────────────────┘
               │
               ▼
```

---

## Phase 4: Visualization (`06_generate_plots.R`)

```
cr_scores.csv
      │
      ▼
┌─────────────────────────────────────┐
│  06_generate_plots.R                │
│                                     │
│  Plot 1: IR CR Raincloud            │
│    • Density + boxplot + jitter     │
│    • By noun condition (HH/HL/LH/LL│
│                                     │
│  Plot 2: WR Accuracy Raincloud      │
│    • Same layout for WR accuracy    │
│                                     │
│  Plot 3: Q-Q Plot (IR RT)           │
│    • Faceted by noun condition      │
│    • Confirms non-normality of RTs  │
├─────────────────────────────────────┤
│  Outputs:                           │
│    outputs/plots/                   │
│      01_ir_by_condition_raincloud   │
│      02_wr_accuracy_raincloud       │
│      07_qq_ir_rt                    │
│    outputs/stats/plots_manifest.txt │
└─────────────────────────────────────┘
```

---

## File Dependency Graph

```
data/raw/*.log
   │
   └─► combined_data.csv
          │
          └─► cleaned_data.csv
                 │
                 └─► pruned_data.csv + validation_report.csv
                        │
                        └─► final_data.csv  ◄── ANALYSIS ENTRY POINT
                               │
                               ├─► cr_scores.csv + stats_summary.csv
                               │      │
                               │      ├─► statistical_tests.txt
                               │      ├─► data/processed/stats/*.csv
                               │      └─► outputs/plots/*.png
                               │
                               └─► outputs/stats/{fa_rates, descriptives, normality}.txt
```

---

## How to Run

```bash
cd sentence-memorability
Rscript src/main.R
```

All outputs (logs, stats tables, plots) are generated automatically.
The run log is saved to `outputs/logs/pipeline_run_<timestamp>.log`.

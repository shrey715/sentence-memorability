# Results

## Overview

A total of **112 participants** contributed data from **329 validated blocks** (96.2% pass rate). Each participant completed 48 target probes across 3 blocks, yielding **5,264 target probe trials**. Of these, **4,384 received an IR press** (overall IR hit rate = 83.3%), with a mean false alarm rate of 16.1%, producing an **overall corrected recognition of 0.672**.

---

## 1. The Effect of Noun Memorability on Sentence Recognition (IR)

**Figure:** `plots/01_ir_by_condition.png`

Corrected IR scores were computed as hit rate minus false alarm rate, aggregated per participant per condition. Mean corrected recognition scores were:

| Condition | M     | SD    | Mdn   |
|-----------|-------|-------|-------|
| HH        | 0.689 | 0.185 | 0.740 |
| HL        | 0.691 | 0.177 | 0.708 |
| LH        | 0.679 | 0.188 | 0.729 |
| LL        | 0.632 | 0.189 | 0.656 |

A Kruskal-Wallis test revealed a **significant main effect of noun condition** on corrected IR, **H(3) = 8.660, *p* = .034**. Pairwise Wilcoxon tests (Holm-corrected) indicated that the LL condition had marginally lower corrected recognition compared to HL (*p* = .064) and HH (*p* = .075), while no other pairwise differences reached significance. The data pattern indicates that sentences consisting entirely of low-memorability nouns (LL) are recognized more poorly than sentences containing at least one high-memorability noun.

---

## 2. Wording Recognition (WR) Accuracy by Noun Condition

**Figure:** `plots/02_wr_by_condition.png`

WR accuracy (proportion of correct voice judgments among trials where an IR press was made) was uniformly high across conditions:

| Condition | M     | SD    |
|-----------|-------|-------|
| HH        | 0.748 | 0.151 |
| HL        | 0.747 | 0.145 |
| LH        | 0.762 | 0.160 |
| LL        | 0.730 | 0.173 |

A Kruskal-Wallis test found **no significant effect** of noun condition on WR accuracy, **H(3) = 1.981, *p* = .576**. Participants were equally good at discriminating the wording (active vs. passive voice) regardless of the memorability of the constituent nouns. Crucially, all conditions were well above chance (50%), indicating that participants retained surface-form information alongside meaning.

---

## 3. Noun Condition × Voice Interaction (IR)

**Figure:** `plots/03_ir_condition_x_voice.png`

The interaction between noun condition and grammatical voice was explored descriptively. Key cell means (corrected IR):

| Condition | Active | Passive |
|-----------|--------|---------|
| HH        | 0.689  | 0.689   |
| HL        | 0.686  | 0.695   |
| LH        | 0.676  | 0.682   |
| LL        | 0.621  | 0.643   |

The LL condition showed a slight numerical advantage for passive voice, but the overall voice main effect was **not statistically significant** (*p* = .446; see Section 5 below). The interaction pattern appears minimal, with the noun condition effect replicating consistently within both active and passive conditions.

---

## 4. Noun Condition × Voice Interaction (WR)

**Figure:** `plots/04_wr_condition_x_voice.png`

WR accuracy was examined across the 8 cells of the condition × voice design. WR accuracy was uniformly high across all cells, with no clear interaction pattern. This mirrors the null noun condition effect on WR found in Section 2.

---

## 5. Voice Effect on Immediate Recognition

**Figures:** `plots/09_voice_slope.png`, `plots/03_ir_condition_x_voice.png`

A Wilcoxon signed-rank test comparing active (M = 0.668, SD = 0.166) and passive (M = 0.677, SD = 0.175) corrected IR found **no significant voice effect**, **V = 1654, *p* = .446**. Whether a sentence was originally presented in active or passive voice did not influence how well participants recognized its meaning upon the second presentation.

---

## 6. Voice Effect on Wording Recognition

**Figure:** `plots/11_wr_accuracy_by_voice.png`

WR accuracy was numerically higher for active-voice sentences (M = 0.757, SD = 0.120) than passive-voice sentences (M = 0.735, SD = 0.127), but this difference was **not statistically significant**, **V = 3279, *p* = .113**. Both voices were recognized **highly above chance** (one-sample Wilcoxon test vs. 0.50): active *p* < .000001, passive *p* < .000001. Participants could reliably detect whether the sentence had been presented in the same voice or a different voice, regardless of the original form.

---

## 7. Reaction Time Analysis

**Figure:** `plots/05_ir_rt_density.png`

Mean IR reaction times (excluding RTs > 10 s) were:

| Condition | M (ms)  | SD (ms) | Mdn (ms) |
|-----------|---------|---------|----------|
| HH        | 1,725   | 319     | 1,618    |
| HL        | 1,729   | 365     | 1,647    |
| LH        | 1,677   | 335     | 1,589    |
| LL        | 1,762   | 336     | 1,661    |

A Kruskal-Wallis test found **no significant effect** of noun condition on RT, **H(3) = 4.442, *p* = .218**. While LL showed numerically the slowest responses and LH the fastest, these differences did not reach statistical significance. All conditions produced similarly right-skewed RT distributions (see density plot), with the bulk of responses concentrated between 800–2,500 ms.

---

## 8. Block Effects (Learning / Fatigue)

**Figure:** `plots/07_block_learning.png`

Mean corrected IR showed a numerically declining trend across blocks:

| Block | M     | SD    | n   |
|-------|-------|-------|-----|
| 1     | 0.699 | 0.151 | 108 |
| 2     | 0.679 | 0.195 | 109 |
| 3     | 0.650 | 0.191 | 112 |

However, this decline was **not statistically significant**, **H(2) = 2.771, *p* = .250**. The small downward trend is consistent with mild proactive interference or fatigue, but the effect is modest and insufficient to compromise the overall quality of recognition performance.

---

## 9. Signal Detection: Hit Rate vs False Alarm Rate

**Figure:** `plots/06_hit_vs_fa.png`

Individual hit rates ranged from 0.188 to 1.000, and false alarm rates from 0.000 to 0.427. Across participants, there was a **significant positive correlation** between hit rate and false alarm rate, Spearman **ρ = .208, *p* = .028**. This suggests a response bias component: more liberal responders (higher FA) also tended to hit more target probes. This correlation underscores the importance of the corrected recognition measure (hit − FA) to separate sensitivity from bias.

---

## 10. Relationship Between Meaning and Wording Memory

**Figure:** `plots/10_ir_vs_wr.png`

IR corrected recognition and WR accuracy were **significantly positively correlated**, Spearman **ρ = .248, *p* < .0001**. Participants who better discriminated meaning (higher IR) also showed superior memory for exact wording. This positive association suggests that meaning and surface-form representations are **not fully independent** — stronger encoding of a sentence's content appears to co-occur with better retention of its grammatical form. However, the modest magnitude of the correlation (ρ ≈ .25) also indicates that the two memory systems are not redundant, consistent with partially dissociable representations.

---

## 11. Individual Differences in Recognition

**Figure:** `plots/08_participant_heatmap.png`

The heatmap reveals substantial between-participant variability. Some participants showed uniformly strong recognition across all four conditions (green band), while others performed near floor (red band). The condition effect (LL < HH/HL/LH) is visible as a systematic colour shift within many participants' rows, confirming that the group-level effect is not driven by a small number of outliers.

---

## 12. Summary: Forest Plot

**Figure:** `plots/12_forest_plot.png`

The forest plot ranks all 8 condition × voice cells by mean corrected IR with 95% confidence intervals. The LL conditions cluster at the lower end, while HH, HL, and LH conditions are interspersed at the upper end. No systematic active/passive stratification is visible, corroborating the null voice effect. All 95% CIs exclude zero, confirming that recognition performance was well above chance in every experimental condition.

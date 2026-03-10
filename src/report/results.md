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

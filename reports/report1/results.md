# Results

## Overview

A total of **112 participants** contributed data from **329 validated blocks** (97.9% pass rate). The data check plots (00a-00d) confirm balanced design across all conditions and voices.

All key metrics departed significantly from normality (Shapiro-Wilk: Corrected IR _W_ = 0.94, _p_ < .001; IR RT _W_ = 0.99, _p_ < .001; WR Accuracy _W_ = 0.91, _p_ < .001). Non-parametric tests were used throughout.

---

## 1. Effect of Noun Condition on Corrected IR

_Plot: `01_ir_cr_by_condition.png`_

Per-participant corrected IR scores (collapsed across voice) by noun condition:

- HH: _M_ = 0.689, _SD_ = 0.210
- HL: _M_ = 0.691, _SD_ = 0.200
- LH: _M_ = 0.679, _SD_ = 0.209
- LL: _M_ = 0.632, _SD_ = 0.224

A Kruskal-Wallis test revealed a significant main effect of noun condition on corrected IR, $H(3) = 11.26$, $p = .010$. The effect size was small ($\epsilon^2 = 0.013$).

Post-hoc pairwise Wilcoxon tests (Holm-corrected) showed that LL was significantly lower than both HH ($p = .024$) and HL ($p = .024$). The LL vs. LH comparison approached significance ($p = .077$). All comparisons among HH, HL, and LH were non-significant ($p = 1.000$).

---

## 2. Effect of Noun Condition on WR Accuracy

_Plot: `02_wr_acc_by_condition.png`_

Mean WR accuracy by noun condition:

- HH: _M_ = 0.747, _SD_ = 0.208
- HL: _M_ = 0.747, _SD_ = 0.209
- LH: _M_ = 0.762, _SD_ = 0.203
- LL: _M_ = 0.730, _SD_ = 0.220

A Kruskal-Wallis test found **no significant effect** of noun condition on WR accuracy, $H(3) = 2.52$, $p = .471$, $\epsilon^2 = 0.003$.

---

## 3. Noun Condition × Voice Interaction

_Plots: `03_ir_cr_condition_x_voice.png`, `04_wr_acc_condition_x_voice.png`_

Scheirer-Ray-Hare tests were run for both corrected IR and WR accuracy to test the noun condition × voice interaction.

For **Corrected IR**, there was a main effect of noun condition ($H = 11.26$, $p = .010$), but **no main effect of voice** ($H = 0.76$, $p = .384$) and **no noun condition × voice interaction** ($H = 0.22$, $p = .975$).

For **WR Accuracy**, there were no significant main effects of noun condition ($H = 2.51$, $p = .473$) or voice ($H = 1.19$, $p = .276$), and no interaction ($H = 4.30$, $p = .231$).

---

## 4. Voice Effects

Paired Wilcoxon signed-rank tests compared Active vs. Passive voice (collapsed across noun conditions):

- **Corrected IR**: No significant difference between Active (_M_ = 0.668) and Passive (_M_ = 0.677), $V = 1916.5$, $p = .485$.
- **WR Accuracy**: No significant difference between Active (_M_ = 0.756) and Passive (_M_ = 0.734), $V = 3520.5$, $p = .114$.

---

## 5. WR Above Chance

One-sample Wilcoxon signed-rank tests confirmed that WR accuracy significantly exceeded chance (0.5) for both Active ($V = 6317.5$, $p < .001$) and Passive ($V = 6202.0$, $p < .001$) voice presentations.

---

## 6. Reaction Time Analysis

_Plot: `05_ir_rt_by_condition.png`_

Mean IR reaction time across noun conditions:

- HH: _M_ = 1726 ms, _SD_ = 367
- HL: _M_ = 1729 ms, _SD_ = 433
- LH: _M_ = 1670 ms, _SD_ = 369
- LL: _M_ = 1762 ms, _SD_ = 397

A Kruskal-Wallis test found **no significant effect** of noun condition on IR RT, $H(3) = 6.05$, $p = .109$, $\epsilon^2 = 0.007$.

---

## Summary of Statistical Tests

| Test                           | DV           | Statistic    | df  | _p_   | Sig. |
| ------------------------------ | ------------ | ------------ | --- | ----- | ---- |
| KW: noun condition             | Corrected IR | _H_ = 11.26  | 3   | .010  | ✓    |
| KW: noun condition             | WR Accuracy  | _H_ = 2.52   | 3   | .471  |      |
| KW: noun condition             | IR RT        | _H_ = 6.05   | 3   | .109  |      |
| SRH: condition × voice         | Corrected IR | _H_ = 0.22   | 3   | .975  |      |
| SRH: condition × voice         | WR Accuracy  | _H_ = 4.30   | 3   | .231  |      |
| Paired WSR: voice              | Corrected IR | _V_ = 1916.5 |     | .485  |      |
| Paired WSR: voice              | WR Accuracy  | _V_ = 3520.5 |     | .114  |      |
| One-sample W: Active WR > 0.5  | WR Accuracy  | _V_ = 6317.5 |     | <.001 | ✓    |
| One-sample W: Passive WR > 0.5 | WR Accuracy  | _V_ = 6202.0 |     | <.001 | ✓    |

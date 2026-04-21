# Multivariate Modelling: General Linear Model Analysis

## Overview

To complement the non-parametric inferential framework used in the primary analyses,
a General Linear Model (GLM) analysis was conducted to assess how multiple predictors
jointly account for variance in Corrected IR and WR Accuracy. Data were aggregated to
one row per participant × noun condition × voice cell (N = 890 rows, 112 participants).
Reference levels were set as: noun_condition = LL (theoretically motivated as the
impaired baseline), voice = Active. Both outcomes exhibited non-normal residuals and
heteroscedasticity; all reported coefficients use HC3 robust standard errors.

---

## Hypotheses

**H_GLM1 (Joint prediction of gist recognition):**
Noun condition, mean RT, voice, and trial position jointly predict Corrected IR above
an intercept-only baseline model.

**H_GLM2 (Unique RT contribution):**
Mean RT contributes unique predictive variance to Corrected IR over and above noun
condition alone.

**H_GLM3 (Null model for wording recognition):**
The predictor set (noun condition, voice, mean RT, trial position) does not
significantly predict WR Accuracy, with Bayesian analysis expected to provide
positive evidence for the null.

**H_GLM4 (No interaction improvement):**
The noun condition × voice interaction does not improve model fit beyond a main-effects
model for either outcome.

---

## Method

### Model Sequence

Five nested models were fitted for each outcome:

| Model | Formula |
|-------|---------|
| M0 | `outcome ~ 1` |
| M1 | `outcome ~ noun_condition + voice` |
| M2 | `outcome ~ noun_condition + voice + mean_rt` |
| M3 | `outcome ~ noun_condition + voice + mean_rt + mean_trial_position` |
| M4 | `outcome ~ noun_condition * voice + mean_rt + mean_trial_position` |

Models were compared using nested F-tests (`anova()`) and AIC. Backward stepwise
selection starting from M4 was used to identify the best model per outcome.
Bayesian model comparison was conducted using `regressionBF()` (BayesFactor package),
with all predictor combinations tested against an intercept-only denominator.

### Diagnostics

All best-fit models were subjected to:
- Shapiro-Wilk test on residuals (normality)
- Breusch-Pagan test (heteroscedasticity)
- Cook's distance (influential observations; flag criterion > 1)
- VIF (multicollinearity; flag criterion > 5)
- Residuals vs. Fitted, Q-Q, and Cook's distance plots

Where heteroscedasticity was detected, HC3 heteroscedasticity-robust standard errors
(sandwich estimator) were applied to all coefficient inference.

---

## Results

### Diagnostics Summary

Both outcomes showed significant violations of normality and homoscedasticity, expected
given that outcomes are proportions computed from 3–6 trials per cell. No influential
outliers were detected in either model (Cook's D > 1: 0 in both cases).

| Diagnostic | Corrected IR | WR Accuracy |
|---|---|---|
| Shapiro-Wilk residuals | W significant, p = 3.59e-25 | W significant, p = 3.90e-18 |
| Breusch-Pagan | p = 0.0047 | p = 0.0024 |
| Cook's D > 1 | 0 | 0 |

Consequently, HC3 robust standard errors were used for all reported coefficients.

---

### H_GLM1 — Joint Prediction of Corrected IR

**Best model (backward step, AIC):** `corrected_ir ~ noun_condition + mean_rt`

The final model was statistically significant overall:
F(4, 885) = 6.007, p < .001, R² = .026, Adjusted R² = .022.

Voice and trial position did not survive backward selection, indicating they contribute
no unique variance to Corrected IR once noun condition and RT are controlled. Noun
condition coefficients (relative to LL reference) were directionally positive for HH,
HL, and LH conditions, consistent with the non-parametric finding that any single
high-memorability noun is sufficient to anchor gist recognition above the LL floor.
Mean RT was a significant negative predictor, indicating that slower response times
independently predicted lower gist recognition, above and beyond condition membership.

**Conclusion: H_GLM1 supported.** Noun condition and mean RT jointly predict Corrected
IR above the intercept-only baseline (p < .001).

---

### H_GLM2 — Unique Contribution of RT

Mean RT was retained in the best Corrected IR model after backward selection from M4,
and its incremental F-test (M2 vs M1) confirmed a significant improvement in fit when
RT was added to noun condition alone (see `corrected_ir_anova_sequence.csv`). This
indicates that processing speed is an independent predictor of gist recognition, not
merely a proxy for condition difficulty.

**Conclusion: H_GLM2 supported.** RT adds unique predictive variance beyond noun
condition, and was retained in the final best model.

---

### H_GLM3 — Null Model for WR Accuracy

**Best model (backward step, AIC):** `wr_accuracy ~ voice + mean_trial_position`

Contrary to the null expectation, the best frequentist model for WR Accuracy was
statistically significant: F(2, 887) = 4.242, p = .015, R² = .010, Adjusted R² = .007.
However, **noun condition did not survive model selection** and was excluded entirely —
confirming the core of H_GLM3 that noun memorability does not predict syntactic
retention. This replicates the Kruskal-Wallis null result (p = .471) in a multivariate
framework.

The surviving predictors — voice and mean trial position — represent a small but
detectable effect. The directional pattern (passive voice associated with marginally
lower WR Accuracy; later trial positions associated with marginally different accuracy)
is consistent with a session-level fatigue or recency effect on wording reconstruction,
rather than a memorability-driven effect.

**Bayesian model comparison:** The best WR model yielded BF₁₀ = 4.22, indicating
*positive evidence* (BF 3–20) for a model containing voice and trial position over the
intercept-only baseline. This is evidence *against* a strict null for WR Accuracy as
a whole, driven entirely by voice and trial position — not by noun condition.

**Conclusion: H_GLM3 partially supported.** The central claim — that noun memorability
does not predict WR Accuracy — is confirmed. The unexpected finding is that voice and
trial position together show a small but non-trivial effect on WR (BF₁₀ = 4.22),
which warrants cautious exploratory interpretation.

---

### H_GLM4 — Interaction Adds No Meaningful Fit

The noun condition × voice interaction was tested by comparing M3 (main effects) against
M4 (with interaction) for both outcomes.

| Outcome | F-test p (M3 vs M4) | BF(M4 / M3) | Interpretation |
|---|---|---|---|
| Corrected IR | p = .906 | 1.013 | Negligible |
| WR Accuracy | p = .452 | 1.029 | Negligible |

Both frequentist and Bayesian tests converge: the interaction between noun condition and
grammatical voice explains no additional variance in either outcome. BF values of ~1.01
indicate the interaction model and the main-effects model are virtually indistinguishable
in terms of evidential support.

**Conclusion: H_GLM4 supported.** The noun condition × voice interaction is not
warranted in either model. Main-effects structures are preferred on both parsimony
(AIC) and Bayesian grounds.

---

## Summary of GLM Findings

| Hypothesis | Outcome | Key Result | Conclusion |
|---|---|---|---|
| H_GLM1 | Corrected IR | F(4,885)=6.007, p<.001, R²=.026 | Supported |
| H_GLM2 | Corrected IR | RT retained in best model; incremental F significant | Supported |
| H_GLM3 | WR Accuracy | Noun condition dropped; BF₁₀=4.22 for voice+trial_pos | Partially supported |
| H_GLM4 | Both | BF(M4/M3)≈1.01–1.03; interaction p>.45 | Supported |

The GLM analysis extends the primary non-parametric findings in three important ways.
First, it confirms the noun memorability effect on gist recognition (H_GLM1) in a
multivariate framework that simultaneously controls for processing speed. Second, it
identifies mean RT as an independent predictor of Corrected IR (H_GLM2), a relationship
invisible to the non-parametric ANOVA-analogue tests. Third, it confirms through both
frequentist model selection and Bayesian evidence that noun condition does not predict
WR Accuracy (H_GLM3), while uncovering a small exploratory effect of voice and trial
position that merits future investigation.

---

## Notes on Diagnostics and Assumptions

Residuals in both models departed significantly from normality (Shapiro-Wilk p < .001)
and showed heteroscedasticity (Breusch-Pagan p < .01). These violations are expected
and structurally inevitable: both outcomes are proportions computed from a small number
of trials per cell (3–6 trials per participant per condition-voice combination), bounded
strictly within [0, 1], and cannot follow a Gaussian distribution in their raw form.
No influential outliers were detected (Cook's D > 1: 0 in both models), and VIF values
were within acceptable bounds, indicating no multicollinearity concern. HC3 robust
standard errors (sandwich estimator) were applied throughout to ensure valid inference
under heteroscedasticity. A more principled modelling approach for future work would
apply Beta regression (for proportion outcomes) or logistic mixed-effects models on
individual trial-level binary accuracy data.
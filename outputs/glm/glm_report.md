# GLM Deliverables

Generated: 2026-04-23 01:07:00

## Data aggregation
One row per participant x noun_condition x voice cell was used from data/processed/glm_cell_data.csv,
including mean Corrected IR, mean WR Accuracy, mean RT, and mean trial position.
Reference levels: noun_condition = LL, voice = Active.

## H1 and H2 (Corrected IR)
Best model selected (AIC/backward step): corrected_ir ~ noun_condition + mean_trial_position
Sample size used: 890 rows
Overall model fit: F(4, 885)=7.8886, p=3.00468e-06, R2=0.0344, Adj R2=0.0301
Full model BF10 (main effects vs null): BF10 = 10.76 (positive evidence for H1)
Robust Wald sequence (HC3) saved in outputs/glm/corrected_ir_robust_wald_sequence.csv; delta AIC in outputs/glm/corrected_ir_model_aic.csv.

## H3 (WR Accuracy null-focused)
Best model selected (AIC/backward step): wr_accuracy ~ voice + mean_trial_position
Sample size used: 890 rows
Overall model fit: F(2, 887)=4.2423, p=0.0146665, R2=0.0095, Adj R2=0.0072
Block BF comparisons (noun_condition as factor) are in outputs/glm/wr_accuracy_bayesfactor_models.csv.
WR main-effects BF10 (vs null): BF10 = 0.0009741 [BF01 = 1027] (very strong evidence for H0)

## H4 (Interaction)
Corrected IR interaction M3 vs M4 (robust Wald HC3): F(3,880)=0.0981, p=0.961058
Corrected IR BF(interact/main): BF10 = 0.01026 [BF01 = 97.45] (strong evidence for H0)
WR Accuracy interaction M3 vs M4 (robust Wald HC3): F(3,880)=0.8799, p=0.450981
WR Accuracy BF(interact/main): BF10 = 0.02822 [BF01 = 35.43] (strong evidence for H0)

## Diagnostics
Corrected IR residual Shapiro-Wilk p=1.98271e-14
  Q-Q plot (corrected_ir_qq_residuals.png): heavy tails consistent with SW p=1.98271e-14;
  non-normality addressed via HC3 robust SEs — OLS point estimates remain unbiased.
Corrected IR Breusch-Pagan p=0.0401976
Corrected IR Cook's D > 1 count: 0
WR residual Shapiro-Wilk p=3.90287e-18
  Q-Q plot (wr_accuracy_qq_residuals.png): heavy tails consistent with SW p=3.90287e-18;
  non-normality addressed via HC3 robust SEs — OLS point estimates remain unbiased.
WR Breusch-Pagan p=0.00239608
WR Cook's D > 1 count: 0
Residual plots, Q-Q, and Cook's distance plots are saved under outputs/glm/*png.
VIF tables are saved under outputs/glm/*_best_model_vif.csv (flag criterion > 5).
If heteroscedasticity was detected, HC3 robust coefficients were saved as *_best_model_hc3_coefficients.csv.

## Coefficients and CIs
Unstandardized coefficients (beta, SE, t, p, 95% CI) are saved as:
- outputs/glm/corrected_ir_best_model_coefficients.csv
- outputs/glm/wr_accuracy_best_model_coefficients.csv
Standardized-coefficient models refit the best model with mean_rt and mean_trial_position
z-scored inline (scale()). Factor terms are unchanged. Results are saved as:
- outputs/glm/corrected_ir_best_model_standardized_coefficients.csv
- outputs/glm/wr_accuracy_best_model_standardized_coefficients.csv


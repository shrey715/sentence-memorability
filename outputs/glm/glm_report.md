# GLM Deliverables

Generated: 2026-04-22 04:41:18

## Data aggregation
One row per participant x noun_condition x voice cell was used from data/processed/glm_cell_data.csv,
including mean Corrected IR, mean WR Accuracy, mean RT, and mean trial position.
Reference levels: noun_condition = LL, voice = Active.

## H_GLM1 and H_GLM2 (Corrected IR)
Best model selected (AIC/backward step): corrected_ir ~ noun_condition + mean_rt
Sample size used: 890 rows
Overall model fit: F(4, 885)=6.0074, p=9.02333e-05, R2=0.0264, Adj R2=0.0220
Full model BF10 (main effects vs null): 0.88557 (supports null (BF < 1))
Robust Wald sequence (HC3) saved in outputs/glm/corrected_ir_robust_wald_sequence.csv; delta AIC in outputs/glm/corrected_ir_model_aic.csv.

## H_GLM3 (WR Accuracy null-focused)
Best model selected (AIC/backward step): wr_accuracy ~ voice + mean_trial_position
Sample size used: 890 rows
Overall model fit: F(2, 887)=4.2423, p=0.0146665, R2=0.0095, Adj R2=0.0072
Block BF comparisons (noun_condition as factor) are in outputs/glm/wr_accuracy_bayesfactor_models.csv.
WR main-effects BF10 (vs null): 0.000950199 (supports null (BF < 1))

## H_GLM4 (Interaction)
Corrected IR interaction M3 vs M4 (robust Wald HC3): F(3,880)=0.1824, p=0.908345
Corrected IR BF(interact/main): 0.010925 (supports null (BF < 1))
WR Accuracy interaction M3 vs M4 (robust Wald HC3): F(3,880)=0.8799, p=0.450981
WR Accuracy BF(interact/main): 0.0381796 (supports null (BF < 1))

## Diagnostics
Corrected IR residual Shapiro-Wilk p=3.58783e-25
Corrected IR Breusch-Pagan p=0.00470907
Corrected IR Cook's D > 1 count: 0
WR residual Shapiro-Wilk p=3.90287e-18
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


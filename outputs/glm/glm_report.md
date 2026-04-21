# GLM Deliverables

Generated: 2026-04-22 02:27:47

## Data aggregation
One row per participant x noun_condition x voice cell was used from data/processed/glm_cell_data.csv,
including mean Corrected IR, mean WR Accuracy, mean RT, and mean trial position.
Reference levels: noun_condition = LL, voice = Active.

## H_GLM1 and H_GLM2 (Corrected IR)
Best model selected (AIC/backward step): corrected_ir ~ noun_condition + mean_rt
Sample size used: 890 rows
Overall model fit: F(4, 885)=6.0074, p=9.02333e-05, R2=0.0264, Adj R2=0.0220
Model sequence F-tests and delta AIC are saved in outputs/glm/corrected_ir_anova_sequence.csv and outputs/glm/corrected_ir_model_aic.csv.

## H_GLM3 (WR Accuracy null-focused)
Best model selected (AIC/backward step): wr_accuracy ~ voice + mean_trial_position
Sample size used: 890 rows
Overall model fit: F(2, 887)=4.2423, p=0.0146665, R2=0.0095, Adj R2=0.0072
Bayes factors for all model combinations are in outputs/glm/wr_accuracy_bayesfactor_models.csv.
Best WR BF10 = 4.21859 (positive)

## H_GLM4 (Interaction)
Corrected IR interaction comparison M3 vs M4 (anova) p-value: 0.906472
Corrected IR BF(M4/M3): 1.01324 (negligible)
WR Accuracy interaction comparison M3 vs M4 (anova) p-value: 0.451962
WR Accuracy BF(M4/M3): 1.02936 (negligible)

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
Standardized-coefficient models are saved as:
- outputs/glm/corrected_ir_best_model_standardized_coefficients.csv
- outputs/glm/wr_accuracy_best_model_standardized_coefficients.csv


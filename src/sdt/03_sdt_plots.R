# src/sdt/03_sdt_plots.R
# Visualizations for the SDT analysis.
# Style mirrors 06b_results_plots.R (same theme_pub, palettes, raincloud pattern).
#
# Plot 01: d' by Noun Condition (raincloud)
# Plot 02: c  by Noun Condition (raincloud)
# Plot 03: A' by Noun Condition (raincloud) — robustness check
# Plot 04: d' vs Corrected IR scatter (convergent validity, per condition)
# Plot 05: d' and c — Active vs Passive (paired dot + boxplot)
#
# Input:  data/processed/sdt_scores.csv
#         data/processed/sdt_voice_scores.csv
#         data/processed/cr_scores.csv
# Output: outputs/sdt/01-05_*.png

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(ggplot2); library(ggdist)
})

cat("\n[sdt/03] Generating SDT visualizations...\n")

sdt  <- read.csv("data/processed/sdt_scores.csv", stringsAsFactors=FALSE) %>%
  mutate(noun_condition = factor(noun_condition, levels=c("HH","HL","LH","LL")))
sdt_v <- read.csv("data/processed/sdt_voice_scores.csv", stringsAsFactors=FALSE) %>%
  mutate(noun_condition = factor(noun_condition, levels=c("HH","HL","LH","LL")),
         voice = factor(voice, levels=c("Active","Passive")))
cr <- read.csv("data/processed/cr_scores.csv", stringsAsFactors=FALSE) %>%
  filter(noun_condition %in% c("HH","HL","LH","LL")) %>%
  group_by(participant_id, noun_condition) %>%
  summarise(ir_cr = mean(ir_cr, na.rm=TRUE), .groups="drop") %>%
  mutate(noun_condition = factor(noun_condition, levels=c("HH","HL","LH","LL")))

dir.create("outputs/sdt", showWarnings=FALSE, recursive=TRUE)

palette_cond  <- c(HH="#E69F00", HL="#56B4E9", LH="#009E73", LL="#CC79A7")
cond_labels   <- c(HH="HH (High-High)", HL="HL (High-Low)",
                   LH="LH (Low-High)", LL="LL (Low-Low)")
palette_voice <- c(Active="#0072B2", Passive="#D55E00")

theme_pub <- theme_minimal(base_size=13) +
  theme(legend.position="top", plot.title=element_text(face="bold"))
save_plot <- function(path, w=8, h=6) {
  ggsave(path, width=w, height=h, dpi=200)
  cat(sprintf("  Saved -> %s\n", path))
}

# ── Plot 01: d' by Noun Condition (raincloud) ──────────────────────────────────
cat("  [1/5] d' by condition (raincloud)...\n")
ggplot(sdt, aes(x=noun_condition, y=dprime, fill=noun_condition)) +
  stat_halfeye(adjust=0.6, width=0.5, justification=-0.3,
               point_colour=NA, .width=0, na.rm=TRUE) +
  geom_boxplot(width=0.12, outlier.shape=NA, alpha=0.5, na.rm=TRUE) +
  geom_point(position=position_jitter(width=0.08, seed=42),
             size=1.2, alpha=0.25, na.rm=TRUE) +
  geom_hline(yintercept=0, linetype="dotted", colour="gray40") +
  scale_fill_manual(values=palette_cond, name="Noun Condition",
                    labels=cond_labels) +
  labs(title="Recognition Sensitivity (d') by Noun Condition",
       subtitle="Higher d' = stronger memory signal; dotted line = chance",
       x="Noun Condition", y="d' (sensitivity)") +
  theme_pub
save_plot("outputs/sdt/01_dprime_by_condition.png")

# ── Plot 02: c by Noun Condition (raincloud) ───────────────────────────────────
cat("  [2/5] c by condition (raincloud)...\n")
ggplot(sdt, aes(x=noun_condition, y=c_crit, fill=noun_condition)) +
  stat_halfeye(adjust=0.6, width=0.5, justification=-0.3,
               point_colour=NA, .width=0, na.rm=TRUE) +
  geom_boxplot(width=0.12, outlier.shape=NA, alpha=0.5, na.rm=TRUE) +
  geom_point(position=position_jitter(width=0.08, seed=42),
             size=1.2, alpha=0.25, na.rm=TRUE) +
  geom_hline(yintercept=0, linetype="dotted", colour="gray40") +
  scale_fill_manual(values=palette_cond, name="Noun Condition",
                    labels=cond_labels) +
  labs(title="Response Criterion (c) by Noun Condition",
       subtitle="c > 0 = conservative; c < 0 = liberal; dotted = neutral",
       x="Noun Condition", y="c (criterion)") +
  theme_pub
save_plot("outputs/sdt/02_c_by_condition.png")

# ── Plot 03: A' by Noun Condition (raincloud) ──────────────────────────────────
cat("  [3/5] A' by condition (raincloud, robustness)...\n")
ggplot(sdt, aes(x=noun_condition, y=A_prime, fill=noun_condition)) +
  stat_halfeye(adjust=0.6, width=0.5, justification=-0.3,
               point_colour=NA, .width=0, na.rm=TRUE) +
  geom_boxplot(width=0.12, outlier.shape=NA, alpha=0.5, na.rm=TRUE) +
  geom_point(position=position_jitter(width=0.08, seed=42),
             size=1.2, alpha=0.25, na.rm=TRUE) +
  geom_hline(yintercept=0.5, linetype="dotted", colour="gray40") +
  scale_fill_manual(values=palette_cond, name="Noun Condition",
                    labels=cond_labels) +
  labs(title="Non-Parametric Sensitivity (A') by Noun Condition",
       subtitle="A' = ROC area; no Gaussian assumption; validates d' pattern",
       x="Noun Condition", y="A' (non-parametric sensitivity)") +
  theme_pub
save_plot("outputs/sdt/03_Aprime_by_condition.png")

# ── Plot 04: d' vs Corrected IR scatter (convergent validity) ──────────────────
cat("  [4/5] d' vs Corrected IR scatter (convergent validity)...\n")
conv_data <- sdt %>%
  left_join(cr, by=c("participant_id","noun_condition"))

ggplot(conv_data, aes(x=ir_cr, y=dprime, colour=noun_condition)) +
  geom_point(size=1.4, alpha=0.4, na.rm=TRUE) +
  geom_smooth(method="lm", se=TRUE, linewidth=0.8, na.rm=TRUE) +
  scale_colour_manual(values=palette_cond, name="Noun Condition",
                      labels=cond_labels) +
  labs(title="Convergent Validity: d' vs Corrected IR",
       subtitle="Strong rho validates Corrected IR as a proxy; weak rho signals bias contamination",
       x="Corrected IR (Hit Rate - FA Rate)", y="d' (SDT sensitivity)") +
  facet_wrap(~noun_condition, labeller=labeller(noun_condition=cond_labels)) +
  theme_pub
save_plot("outputs/sdt/04_dprime_vs_corrIR.png")

# ── Plot 05: d' and c by Voice (paired boxplot) ────────────────────────────────
cat("  [5/5] d' and c by voice (paired boxplot)...\n")
sdt_v_long <- sdt_v %>%
  group_by(participant_id, voice) %>%
  summarise(dprime=mean(dprime, na.rm=TRUE),
            c_crit=mean(c_crit, na.rm=TRUE), .groups="drop") %>%
  pivot_longer(cols=c(dprime, c_crit), names_to="metric", values_to="value") %>%
  mutate(metric=recode(metric, dprime="d' (sensitivity)", c_crit="c (criterion)"))

ggplot(sdt_v_long, aes(x=voice, y=value, fill=voice)) +
  stat_halfeye(adjust=0.6, width=0.45, justification=-0.3,
               point_colour=NA, .width=0, na.rm=TRUE) +
  geom_boxplot(width=0.12, outlier.shape=NA, alpha=0.5, na.rm=TRUE) +
  geom_hline(yintercept=0, linetype="dotted", colour="gray40") +
  scale_fill_manual(values=palette_voice, guide="none") +
  facet_wrap(~metric, scales="free_y") +
  labs(title="SDT Parameters by Grammatical Voice",
       subtitle="Active vs Passive — note: global FA used for both voices (all lures are Active)",
       x="Voice", y="Parameter value") +
  theme_pub
save_plot("outputs/sdt/05_sdt_by_voice.png")

cat("  All SDT plots saved to outputs/sdt/\n")

cat("\n[05_statistical_tests] Running non-parametric inferential statistics...\n")

library(dplyr)
library(rcompanion)

cr_scores <- read.csv("data/processed/cr_scores.csv") %>% filter(noun_condition %in% c("HH", "HL", "LH", "LL"))
cr_scores$noun_condition <- as.factor(cr_scores$noun_condition)
cr_scores$voice <- as.factor(cr_scores$voice)

cat(sprintf("  Input : %d observations | conditions : %s | voices : %s\n",
            nrow(cr_scores),
            paste(levels(cr_scores$noun_condition), collapse="/"),
            paste(levels(cr_scores$voice), collapse="/")))

# Capture all test output to text for reports
.stat_lines <- character(0)
.log_test <- function(...) {
  lines <- c(...)
  .stat_lines <<- c(.stat_lines, lines)
  cat(paste(lines, collapse="\n"), "\n")
}

run_omnibus <- function(metric_name) {
  header <- sprintf("\n----------------------------------------------------------------\nOmnibus Kruskal-Wallis: %s ~ noun_condition\n----------------------------------------------------------------", metric_name)
  .log_test(header)

  res <- kruskal.test(as.formula(paste(metric_name, "~ noun_condition")), data = cr_scores)
  .stat_lines <<- c(.stat_lines, capture.output(print(res)))
  print(res)

  eps <- epsilonSquared(x = cr_scores[[metric_name]], g = cr_scores$noun_condition)
  eff_line <- sprintf("  Effect Size (epsilon^2) = %.4f", eps)
  .log_test(eff_line)
  cat(sprintf("  Interpretation: %s\n",
      if(eps < 0.01) "negligible" else if(eps < 0.06) "small" else if(eps < 0.14) "medium" else "large"))

  if (res$p.value < 0.05) {
    ph_header <- sprintf("\n  Post-hoc Pairwise Wilcoxon (Holm correction) for %s:", metric_name)
    .log_test(ph_header)
    ph <- pairwise.wilcox.test(cr_scores[[metric_name]], cr_scores$noun_condition, p.adjust.method = "holm")
    .stat_lines <<- c(.stat_lines, capture.output(print(ph)))
    print(ph)
  } else {
    cat("  No post-hoc test (p >= .05)\n")
  }
}

run_omnibus("ir_cr")
run_omnibus("wr_acc_score")
run_omnibus("ir_rt")

cat("\n----------------------------------------------------------------\nScheirer-Ray-Hare: Noun Condition x Voice Interaction\n----------------------------------------------------------------\n")
.stat_lines <- c(.stat_lines,
  "", "================================================================",
  "Scheirer-Ray-Hare: ir_cr ~ noun_condition * voice")
srh_ir <- scheirerRayHare(ir_cr ~ noun_condition * voice, data = cr_scores)
.stat_lines <- c(.stat_lines, capture.output(print(srh_ir)))
cat("\n  DV: ir_cr\n")
print(srh_ir)

.stat_lines <- c(.stat_lines, "", "Scheirer-Ray-Hare: wr_acc_score ~ noun_condition * voice")
srh_wr <- scheirerRayHare(wr_acc_score ~ noun_condition * voice, data = cr_scores)
.stat_lines <- c(.stat_lines, capture.output(print(srh_wr)))
cat("\n  DV: wr_acc_score\n")
print(srh_wr)

# ── Save to outputs/stats/ ─────────────────────────────────────────────────
if (exists("stat_dir")) {
  writeLines(.stat_lines, file.path(stat_dir, "statistical_tests.txt"))
  cat(sprintf("\n  Saved -> %s/statistical_tests.txt\n", stat_dir))
}

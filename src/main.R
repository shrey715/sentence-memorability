# Main Execution Script for Sentence Memorability Study
options(scipen = 999)

# ── Output directories ────────────────────────────────────────────────────────
run_timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
log_dir <- "outputs/logs"
stat_dir <- "outputs/stats"
dir.create(log_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(stat_dir, showWarnings = FALSE, recursive = TRUE)

# ── Dual-output sink: console + timestamped log file ─────────────────────────
log_file <- file.path(log_dir, paste0("pipeline_run_", run_timestamp, ".log"))
.log_con <- file(log_file, open = "wt")
sink(.log_con, type = "output", split = TRUE)

cat("================================================================\n")
cat("  Sentence Memorability Study — Analysis Pipeline\n")
cat("================================================================\n")
cat(sprintf("  Run started : %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Log file    : %s\n", log_file))
cat(sprintf("  Stats dir   : %s\n", stat_dir))
cat("================================================================\n")

cat("\n\n================================================================\n")
cat("  PHASE 1: Preprocessing\n")
cat("================================================================\n")
source("src/preprocessing/01_load_and_combine.R")
source("src/preprocessing/02_clean_events.R")
source("src/preprocessing/03_validate_participants.R")
source("src/preprocessing/04_finalize_dataset.R")

cat("\n\n================================================================\n")
cat("  PHASE 2: Data Integrity Checks\n")
cat("================================================================\n")
source("src/analysis/visualization/06a_data_checks.R")

cat("\n\n================================================================\n")
cat("  PHASE 3: Compute Scores & Descriptives\n")
cat("================================================================\n")
source("src/analysis/stats/05a_compute_scores.R")

cat("\n\n================================================================\n")
cat("  PHASE 4: Inferential Statistics\n")
cat("================================================================\n")
source("src/analysis/stats/05b_statistical_tests.R")

cat("\n\n================================================================\n")
cat("  PHASE 5: Result Visualizations\n")
cat("================================================================\n")
source("src/analysis/visualization/06b_results_plots.R")

cat("\n\n================================================================\n")
cat(sprintf("  Run completed : %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat("  PIPELINE COMPLETE\n")
cat(sprintf("  Log    -> %s\n", log_file))
cat(sprintf("  Stats  -> %s/\n", stat_dir))
cat(sprintf("  Plots  -> outputs/plots/\n"))
cat("================================================================\n")

# ── Close sink cleanly ───────────────────────────────────────────────────────
sink(type = "output")
close(.log_con)
cat(sprintf("\nFull run log saved to: %s\n", log_file))

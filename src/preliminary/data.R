# This script is for loading and validating the log files in the data directory.

data_dir <- "data/raw"

# number of files in the data directory
num_files <- length(list.files(data_dir))
print(paste("Number of files in the data directory:", num_files))

# each log file contains comma-separated values (CSV) with some columns.
# ill load all the columns only from each file first and validate if each file has the same columns. If not, flag the files with missing columns.

files <- list.files(data_dir, full.names = TRUE)

column_names <- function(file) {
  data <- read.csv(file, nrows = 1, fileEncoding = "UTF-8-BOM") # read only the first row to get column names
  return(colnames(data))
}

columns_list <- lapply(files, column_names)

# check if all files have the same columns
unique_columns <- unique(columns_list)

if (length(unique_columns) == 1) {
  print("All files have the same columns. The columns are:")
  print(unique_columns[[1]])
} else {
  print("Files have different columns. Here are the unique column sets:")
  print(unique_columns)
}

# row count for each file
row_counts <- sapply(files, function(file) {
  data <- read.csv(file, fileEncoding = "UTF-8-BOM")
  return(nrow(data))
})

# rows which have different row counts
if (length(unique(row_counts)) == 1) {
  print("All files have the same number of rows. The row count is:")
  print(unique(row_counts))
} else {
  print("Files have different row counts. Here are the row counts for each file:")
  print(data.frame(file = files, row_count = row_counts))
}

# load final dataframe with all files combined
load_log <- function(file) {
  df             <- read.csv(file, fileEncoding = "UTF-8-BOM", na.strings = "N/A")
  df$participant_id <- as.integer(tools::file_path_sans_ext(basename(file)))
  return(df)
}

all_data <- do.call(rbind, lapply(files, load_log))
all_data <- all_data[, c("participant_id", setdiff(colnames(all_data), "participant_id"))]

all_data$isTarget <- all_data$isTarget == "true"
all_data$isRepeat <- all_data$isRepeat == "true"
all_data$isValidation <- all_data$isValidation == "true"

cat(sprintf("\nCombined data frame has %d rows and %d columns from %d participants.\n", nrow(all_data), ncol(all_data), length(unique(all_data$participant_id))))

# saving the generated data frame to a new file for future use
output_file <- "data/processed/combined_data.csv"
write.csv(all_data, output_file, row.names = FALSE)
cat(sprintf("Combined data frame saved to %s\n", output_file))

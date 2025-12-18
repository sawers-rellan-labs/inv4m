#!/usr/bin/env Rscript
# Generic rendering script for the inv4m project

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Please provide the path to an .Rmd file (e.g., scripts/inversion_paper/analysis.Rmd)")
}

input_path <- args[1]
# Get the directory of the script (e.g., "inversion_paper")
paper_folder <- basename(dirname(input_path))

# Define the root results directory relative to project root
# We assume the user runs this from the 'inv4m' project root
output_dir <- file.path("docs", paper_folder)

# Create the results directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

cat(sprintf("Rendering %s to %s...\n", input_path, output_dir))

rmarkdown::render(
  input = input_path,
  output_dir = output_dir,
  output_format = "html_document",
  envir = new.env(), # Clean environment
  clean = TRUE
)

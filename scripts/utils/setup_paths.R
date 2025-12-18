#' Setup Project Paths (Flat data/ Structure)
#'
#' Centralized path configuration using here::here()
#' Works with flat data/ directory (symlinked, read-only)
#'
#' @param paper Character string: "phosphorus_paper", "inversion_paper", or "shared_paper"
#' @return Named list of standardized project paths
#' @examples
#' library(here)
#' source(here("scripts", "utils", "setup_paths.R"))
#' paths <- setup_project_paths("phosphorus_paper")
#' read.csv(file.path(paths$data, "my_file.csv"))

setup_project_paths <- function(paper = "phosphorus_paper") {

  # Validate paper argument
  valid_papers <- c("phosphorus_paper", "inversion_paper", "shared_paper")
  if (!paper %in% valid_papers) {
    stop(sprintf("Invalid paper: '%s'. Must be one of: %s",
                 paper, paste(valid_papers, collapse = ", ")))
  }

  # Check for here package
  if (!requireNamespace("here", quietly = TRUE)) {
    stop("Package 'here' required. Install with: install.packages('here')")
  }

  # Build path list
  paths <- list(
    # Project root
    root = here::here(),

    # Data directory (flat, symlinked - read-only for our purposes)
    data = here::here("data"),

    # Results directories (paper-specific)
    results = here::here("results", paper),
    intermediate = here::here("results", paper, "intermediate"),
    figures = here::here("results", paper, "figures"),
    tables = here::here("results", paper, "tables"),
    reports = here::here("results", paper, "reports")
  )

  # Create missing result directories (cannot modify data/)
  result_dirs <- c(
    paths$intermediate,
    paths$figures,
    paths$tables,
    paths$reports
  )

  for (dir_path in result_dirs) {
    if (!dir.exists(dir_path)) {
      dir.create(dir_path, recursive = TRUE, showWarnings = FALSE)
    }
  }

  # Return paths invisibly
  invisible(paths)
}

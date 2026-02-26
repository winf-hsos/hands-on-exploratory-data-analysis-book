library(tidyverse)

find_project_dir <- function(start_dir = getwd()) {
  dir <- normalizePath(start_dir)
  repeat {
    if (file.exists(file.path(dir, "_quarto.yml")) || file.exists(file.path(dir, "_quarto-slides.yml"))) {
      return(dir)
    }
    parent <- dirname(dir)
    if (parent == dir) stop("Project root not found")
    dir <- parent
  }
}

project_dir <- find_project_dir()

survey <- read_csv(
  file.path(project_dir, "data", "mds12_schoko_milch.csv"),
  show_col_types = FALSE
)

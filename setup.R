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

tweets <- readRDS(file.path(project_dir, "data", "tweets_ampel.rds"))
orders <- read_csv(file.path(project_dir, "data", "orders.csv"))
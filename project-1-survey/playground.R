library(tidyverse)
library(janitor)
md <- read_csv("data/mds12_schoko_milch.csv", show_col_types = FALSE) |> 
  clean_names()


md |> 
  colnames()


names(md) %>%
  as_tibble_col("colname") %>%
  transmute(
    combo  = str_extract(colname, "[A-Za-z]+\\d{3}"),
    number = str_extract(combo, "\\d{3}$") %>% as.integer(),
    colname
  ) |>
  drop_na() |> 
  arrange(number) |> 
  print(n = 140)

md |> 
  names() |> 
  as_tibble_col("col")

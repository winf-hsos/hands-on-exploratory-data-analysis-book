library(tidyverse)
library(janitor)
md <- read_csv("data/mds12_schoko_milch.csv", show_col_types = FALSE) |> 
  clean_names()

library(tidyverse)
survey <- read_csv("data/mds12_schoko_milch.csv", show_col_types = FALSE)



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


survey |>
  ggplot() +
  aes(x = u013pzahl_1weihen) +
  geom_boxplot() +
  coord_cartesian(xlim = c(0, 10))


survey |>
  ggplot() +
  aes(x = u013pzahl_1weihen) +
  geom_histogram()

survey |>
  filter(u013pzahl_1weihen < 10.0) |>
  ggplot() +
  aes(x = u013pzahl_1weihen) +
  geom_histogram(binwidth = 0.5)



survey |> 
  select(q002geburt)

format(Sys.Date(), "%Y")



Sys.Date()

current_year <- year(Sys.Date())

survey |>
  transmute(age = current_year - q002geburt)

survey |>
  transmute(age = 2025 - q002geburt) |>
  distinct()


library(janitor)

install.packages("skimr")
library(skimr)

skimr::skim(my_data)


survey |>
  transmute(age = 2025 - q002geburt) |> 
  tabyl(age)

survey |>
  transmute(age = 2025 - q002geburt) |> 
  skim(age)


survey |>
  transmute(age = 2025 - q002geburt) |>
  ggplot() +
  aes(x = age) +
  geom_bar()


survey |>
  transmute(age = 2025 - q002geburt) |>
  ggplot() +
  aes(x = age) +
  geom_histogram()


survey <- 
  survey |>
  mutate(Q002age = as.integer(2025 - q002geburt), .after = "q002geburt")


survey |> 
  select(Q002age) |> 
  skim()


survey |> 
  select(tail(names(survey), 10))





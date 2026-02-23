#renv::install("pacman")
pacman::p_load(tidyverse, janitor, skimr, lubridate, infer, rstatix, gtsummary, summarytools, broom, googlesheets4, readxl)

install.packages("xml2")
install.packages("downlit")

md <- read_csv("data/mds12_schoko_milch.csv", show_col_types = FALSE) |> 
  clean_names()

survey <- read_csv("data/mds12_schoko_milch.csv", show_col_types = FALSE)

limo_meta <- read_sheet("1Sq_CWA-oTN90d0EpA6rEDB3C77dyIXv0HZTq3YWuyy8")

limo_meta |> 
  mutate(data_type = as_factor(data_type)) |>
  pull(data_type) |> 
  levels()


datatypes <- factor(
  levels = c("int", "string", "double", "character", "logical"), 
  labels = c("Integer", "String", "Double", "Character", "Logical")
)


read_sheet("https://docs.google.com/spreadsheets/d/1Sq_CWA-oTN90d0EpA6rEDB3C77dyIXv0HZTq3YWuyy8/edit")

survey |> 
  select(q001hheinkauf, q004geschlecht) |>
  tbl_summary()

survey |> 
  select(q001hheinkauf, q004geschlecht) |>
  tbl_summary(by = q004geschlecht)

survey |> 
  select(q001hheinkauf) |>
  freq() |> 
  broom::tidy()
  
survey %>%
  drop_na(U015p1reaktion4_1weihen, AD015p1reaktion4f) |> 
  anova_test(U015p1reaktion4_1weihen ~ AD015p1reaktion4f) |> 
  as_tibble() |> 
  clean_names() 


survey |>  
  drop_na(U027kaufalpro5, Q002altergru4f) |> 
  anova_test(U027kaufalpro5 ~ Q002altergru4f)


md |> 
  colnames()

survey |> 
  count(q001hheinkauf)


survey |> 
  count(q001hheinkauf, v041diaet_1lowcarb)

survey |> 
  tabyl(q001hheinkauf)

survey |> 
  tabyl(q001hheinkauf, v041diaet_1lowcarb) 
  adorn_percentages("row") |> 
  adorn_pct_formatting()



survey |> 
  glimpse()



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





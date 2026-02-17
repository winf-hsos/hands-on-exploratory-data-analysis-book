library(tidyverse)

ts <- read_csv("data/tagesschau.zip", show_col_types = FALSE) |>
	mutate(
		date_time = ymd_hms(date_time, tz = "UTC"),
		date_modified = ymd_hms(date_modified, tz = "UTC")
	)
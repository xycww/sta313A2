library(readr)
library(arrow)

raw_data <- read_csv("./data/00-raw_data/census_21_metro.csv")
write_parquet(raw_data, "./data/00-raw_data/raw_census_data.parquet")


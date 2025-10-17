### Required Packages ###
library(tidyverse)
library(arrow)
library(readr)

# read data 
data <- read_parquet("./data/00-raw_data/raw_census_data.parquet")

select_data <- data %>%
  # keep only the needed attributes
  select(AGEGRP, Gender, HDGREE, FPTWK, VISMIN, Wages, COW, WKSWRK, NAICS) %>%
  # apply filters
  filter(
    AGEGRP %in% 7:16,          # ages 18–65
    FPTWK == 1,                # full-time work only
    COW == 1,                  # employee only
    WKSWRK == 6,               # worked 49-52 weeks only
    !Wages %in% c(88888888, 99999999),      # remove unknown / not stated
    !HDGREE %in% c(88, 99),   # remove unknown / not stated
    !VISMIN %in% c(12, 13, 88),
    !NAICS %in% c(888, 999)
  )

clean_data <- select_data %>%
  mutate(
    Edu3 = case_when(
      HDGREE %in% 1:2   ~ "HS or less",
      HDGREE %in% 3:8   ~ "Non-degree postsec",
      HDGREE %in% 9:13  ~ "BA or higher",
      TRUE ~ NA_character_
    ),
    Edu3 = factor(Edu3, levels = c("HS or less","Non-degree postsec","BA or higher"))
  )


# save cleaned data for analysis in data/analysis_data
write_parquet(clean_data, "./data/01-cleaned_data/cleaned_census_data.parquet")

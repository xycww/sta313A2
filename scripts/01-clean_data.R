### Required Packages ###
library(tidyverse)
library(arrow)
library(readr)

# read data 
data <- read_parquet("./data/00-raw_data/raw_census_data.parquet")

# read data 
data <- read_parquet("./data/00-raw_data/raw_census_data.parquet")

clean_data <- data %>%
  select(AGEGRP, Gender, HDGREE, FPTWK, VISMIN, Wages, COW, WKSWRK, NAICS) %>%
  filter(
    AGEGRP %in% 7:16,
    FPTWK == 1,
    COW == 1,
    WKSWRK == 6,
    !Wages %in% c(88888888, 99999999),
    !HDGREE %in% c(88, 99),
    !VISMIN %in% c(12, 13, 88),
    !NAICS %in% c(888, 999)
  ) %>%
  mutate(
    Edu3 = case_when(
      HDGREE %in% 1:2  ~ "HS or less",
      HDGREE %in% 3:8  ~ "Non-degree postsec",
      HDGREE %in% 9:13 ~ "BA or higher",
      TRUE ~ NA_character_
    ),
    Edu3 = factor(Edu3, levels = c("HS or less","Non-degree postsec","BA or higher")),
    # Recode Gender HERE and save it
    Gender = recode(as.character(Gender), `1` = "Women", `2` = "Men")
  )


# save cleaned data for analysis in data/analysis_data
write_parquet(clean_data, "./data/01-cleaned_data/cleaned_census_data.parquet")

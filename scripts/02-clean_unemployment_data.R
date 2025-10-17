### Required Packages ###
library(tidyverse)
library(arrow)
library(readr)

# read data 
raw <- read_parquet("./data/00-raw_data/raw_census_data.parquet")

clean_unemp <- raw %>%
  select(AGEGRP, Gender, LFACT, PKIDS) %>%
  filter(
    AGEGRP %in% 9:16,       # 25–29 ... 60–64
    !LFACT %in% c(88, 99),  # valid labour-force codes
    !PKIDS %in% c(8, 9)     # drop unknown PKIDS if present
  ) %>%
  mutate(
    # tidy labels
    Age = recode(as.character(AGEGRP),
                 `9`="25–29", `10`="30–34", `11`="35–39", `12`="40–44",
                 `13`="45–49", `14`="50–54", `15`="55–59", `16`="60–64") |>
      factor(levels = c("25–29","30–34","35–39","40–44","45–49","50–54","55–59","60–64")),
    Gender = recode(as.character(Gender), `1`="Women", `2`="Men"),
    # employment buckets from LFACT
    Employment_status = case_when(
      LFACT %in% c(1, 2)   ~ "Employed",          # worked / absent
      LFACT %in% 3:10      ~ "Unemployed",        # all unemployed subtypes
      LFACT %in% 11:14     ~ "Not in labour force",
      TRUE                 ~ NA_character_
    ) |> factor(levels = c("Employed","Unemployed","Not in labour force")),
    # children flag
    ChildStatus = case_when(
      PKIDS == 1 ~ "Has children",
      PKIDS == 0 ~ "No children",
      TRUE       ~ NA_character_
    ) |> factor(levels = c("No children","Has children")),
    # convenient logicals
    InLF       = Employment_status %in% c("Employed","Unemployed"),
    Unemployed = Employment_status == "Unemployed"
  ) %>%
  # keep only labour force rows for unemployment-rate work
  filter(InLF) %>%
  select(AGEGRP, Age, Gender, PKIDS, ChildStatus, LFACT, Employment_status, Unemployed)


# save cleaned data for analysis in data/analysis_data
write_parquet(clean_unemp, "./data/01-cleaned_data/cleaned_unemployment_data.parquet")
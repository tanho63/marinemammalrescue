library(tidyverse)
library(lubridate)
library(jsonlite)

# import JSON file, scraped from mmrpatients.org on July1, 2021
raw_data <- read_json(here("data/sitedata.json"))

# unnest our lists and create a tibble - THANK YOU TAN <3
data <- raw_data %>% 
  purrr::pluck("patients") %>% 
  tibble::tibble() %>% 
  tidyr::unnest_wider(1)

# a little bit of data wrangling
data <- data %>% 
  mutate(sex = as.factor(sex),
         collection_site = as.factor(collection_site),
         reason_for_admit = str_trim(reason_for_admit),
         admit_date = date(admit_date),
         admit_weight = as.numeric(admit_weight),
         release_date = ymd(release_date), 
         release_site = as.factor(release_site),
         release_weight = as.numeric(release_weight),
         transfer_date = ymd(transfer_date)) 

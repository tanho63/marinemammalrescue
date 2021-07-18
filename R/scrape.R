library(rvest)
library(tidyverse)
library(janitor)

scrape_patient_list <- function(year){

  url <- paste0("https://mmrpatients.org/?season=",year)

  patient_node <- read_html(url) %>%
    html_node("#patient-list")

  extra_stuff <- tibble(
    sex = patient_node %>% html_nodes('span[class^="sex"]') %>% html_attr("class") %>% str_remove("^sex\\-"),
    url = patient_node %>% html_nodes('.table-image a') %>% html_attr("href")
  )

  patient_table <- html_table(patient_node) %>%
    bind_cols(extra_stuff)

  return(patient_table)
}

patient_list_all <- c(2018:2021) %>%
  map(scrape_patient_list) %>%
  tibble(data = .) %>%
  hoist(1,
        "patient_id" = "#",
        "Name",
        "Species",
        "sex",
        "Admitted",
        "Collection Site",
        "Reason for Admission",
        "Status"=11,
        "url"
        ) %>%
  select(-data) %>%
  janitor::clean_names() %>%
  unnest(c(patient_id, name, species, sex, admitted, collection_site,
           reason_for_admission, status, url)) %>%
  distinct(patient_id, .keep_all = TRUE)

# get_patient_details <- function(page){
#
#   patient_html <- read_html(page)
#
#   patient_info <- patient_html %>%
#     html_nodes(".card .clear") %>%
#     html_text() %>%
#     str_remove_all("\n|\t") %>%
#     str_split(":") %>%
#     tibble() %>%
#     hoist(1,
#           "name" = 1,
#           "value" = 2
#           ) %>%
#     pivot_wider(names_from = name, values_from = value)
#
#   return(patient_info)
# }
#
# x <- patient_list %>%
#   mutate(patient_info = map(url,get_patient_details))
#
# y <- x %>%
#   unnest_wider(patient_info)
#

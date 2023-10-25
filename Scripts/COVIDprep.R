covid_df <- group_resp_data(resp_percents, condition = "COVID") %>%
  filter(Year>=2020) %>%
  mutate(drop = case_when(
    Year==2021 & Week >= 26 ~ TRUE,
    Year==2022 & Week <=12 ~ TRUE
  ),
  percent = COVID*100) %>%
  filter(is.na(drop)) %>%
  select(Year, Week, percent)
write.csv(covid_df,file = "Data/covid_df.csv",
          row.names = FALSE)
## USE MEM SHINY APP TO DETERMINE THRESHOLDS AND FILL IN BELOW
covid_thresholds <- data.frame(
  Condition = "COVID",
  epidemic = NA,
  medium = NA, 
  high = NA, 
  veryhigh = NA)
save(covid_thresholds, file = "Data/covid_thresholds.RData")
load("Data/covid_thresholds.RData")

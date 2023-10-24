
get_essence_data <- function(url, start_date = NULL, end_date = NULL) {
  
  api_type <- str_extract(url,"(?<=api/).+(?=\\?)")
  
  url_new <- change_dates(url, start_date, end_date)
  
  if (api_type == "timeSeries") {
    api_response <- myProfile$get_api_response(url_new)
    api_response_json <- content(api_response, as = "text")
    api_data <- fromJSON(api_response_json) %>%
      extract2("timeSeriesData")
  } else if (api_type == "timeSeries/graph") {
    api_png <- myProfile$get_api_tsgraph(url_new)
    knitr::include_graphics(api_png$tsgraph)
  } else if (api_type == "tableBuilder") {
    api_data <- myProfile$get_api_data(url_new)
  } else if (api_type == "tableBuilder/csv") {
    api_data <- myProfile$get_api_data(url_new, fromCSV = TRUE)
  } else if (api_type == "dataDetails") {
    api_data <- myProfile$get_api_data(url_new) %>%
      extract2("dataDetails")
  } else if (api_type == "dataDetails/csv") {
    api_data <- myProfile$get_api_data(url_new, fromCSV = TRUE) 
  } else if (api_type == "summaryData") {
    api_data <- myProfile$get_api_data(url_new) %>%
      extract2("summaryData")
  } else if (api_type == "alerts/regionSyndromeAlerts") {
    api_data <- myProfile$get_api_data(url_new) %>%
      extract2("regionSyndromeAlerts")
  } else if (api_type == "alerts/hospitalSyndromeAlerts") {
    api_data <- myProfile$get_api_data(url_new) %>%
      extract2("hospitalSyndromeAlerts")
  } else {
    writeLines("Error: API did not work as expected. Please check your URL, dates, and password before trying again.")
  }
  
}

base_url <- "https://essence2.syndromicsurveillance.org/nssp_essence/api/tableBuilder?datasource=va_hosp&startDate=25Jun2023&medicalGroupingSystem=essencesyndromes&userId=5099&endDate=30Sep2023&percentParam=noPercent&hospFacilityType=emergency%20care&aqtTarget=TableBuilder&geographySystem=hospitalregion&detector=nodetectordetector&timeResolution=weekly&hasBeenE=1&rowFields=timeResolution&columnField=geographyhospitalregion"

urls <- data.frame(
  Condition = c(
    "COVID",
    "Influenza",
    "RSV",
    "Combined_3",
    "RESP_DD",
    "RESP_CC",
    "RESP_CCDD",
    "Denominator"
  ),
  url = c(
    # COVID
    "&ccddCategory=cdc%20covid-specific%20dd%20v1",
    # Influenza
    "&ccddCategory=cdc%20influenza%20dd%20v1",
    # RSV
    "&ccddCategory=cdc%20respiratory%20syncytial%20virus%20dd%20v1",
    # Combined_3
    "&ccddCategoryFreeText=%5ECDC%20COVID-Specific%20DD%20v1%5E,or,%5ECDC%20Influenza%20DD%20v1%5E,or,%5ECDC%20Respiratory%20Syncytial%20Virus%20DD%20v1%5E",
    # BAR
    "&ccddCategory=cdc%20broad%20acute%20respiratory%20dd%20v1",
    # RESP
    "&medicalGrouping=resp",
    # BAR_RESP
    "&ccddCategoryFreeTextApplyTo=syndromeFreeText&ccddCategoryFreeText=%5ECDC%20Broad%20Acute%20Respiratory%20DD%20v1%5E,or,%5ERESP%5E,andnot,(,%5Erespiratory%20syn%5E,or,%5Erespiratory%20ill%5E,)",
  # DENOMINATOR
  ""
  )
)

new_start <- "2017-09-03"
new_end <- ceiling_date(Sys.Date()-7, "week")-1

get_resp_data <- function(base_url, url_add_on, geo, 
                          new_start, new_end) {
  
  geo_new <- geo #geo_apis$APIsyntax[geo_apis$GeoName==geo]
  
  new_url <- paste0(base_url, url_add_on, geo_new)
  
  df_raw <- get_essence_data(new_url, start_date = new_start, end_date = new_end)
  
  df_clean <- df_raw %>%
    separate(timeResolution, c("Year", "Week"), sep = "-", convert = TRUE) %>%
    mutate(WeekEnd = MMWRweek2Date(Year, Week, 7),
           Condition = urls$Condition[i]) %>%
    select(Year, Week, WeekEnd, Condition, Visits = count) %>%
    pivot_wider(names_from = Condition, values_from = Visits)
  
  return(df_clean)
  
}

resp_list <- list()

for (i in 1:nrow(urls)) {
  
  resp_list[[i]] <- get_resp_data(base_url, urls$url[i], geo = geo,
                                  new_start = "2017-09-03", new_end = new_end)
  
}

resp_data <- full_join(resp_list[[1]], resp_list[[2]]) %>%
  full_join(resp_list[[3]]) %>%
  full_join(resp_list[[4]]) %>%
  full_join(resp_list[[5]]) %>%
  full_join(resp_list[[6]]) %>%
  full_join(resp_list[[7]]) %>%
  full_join(resp_list[[8]])

resp_percents <- resp_data%>%
  pivot_longer(cols = COVID:RESP_CCDD, names_to = "Condition", values_to = "Visits") %>%
  mutate(Percent = Visits/Denominator) %>% 
  arrange(WeekEnd) %>%
      mutate(
        start = if_else(Week >= 36, Year, Year - 1), # Season is week 36 through 35
        end = start + 1,
        season = paste0(start, "-", end),
        drop = if_else(season == "2019-2020" & Week > 10 & Week < 36, TRUE, FALSE) # Drop weeks 10-36 of 2020
      ) %>%
      relocate(c(start, end, season), .after = Week) %>%
      group_by(season) %>%
      dplyr::mutate(week_in_season = row_number()) %>%
      ungroup() %>%
      relocate(week_in_season, .after = Week)

save(resp_percents, file = "Data/resp_percents.RData")

write.csv(resp_data, file = "Data/resp_data.csv")

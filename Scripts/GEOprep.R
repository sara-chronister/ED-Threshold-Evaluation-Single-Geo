### Geo-specific prep

# covid
covid_df <- group_resp_data(resp_percents, condition = "COVID")
# write.csv(covid_df,file = "Thresholds/Data/covid_df.csv")
# covid_thresholds <- data.frame(
#   Condition = "COVID",
#   epidemic = .0434,
#   medium = .0622, 
#   high = .1094, 
#   veryhigh = .1404)
load("Data/covid_thresholds.RData")
mem_covid <- add_covid_thresholds(covid_df, covid_thresholds)
covid_ts <- plot_resp_data(mem_covid, include_3 = FALSE,
                                 name = "COVID")
covid_levels <- plot_method_comparison(mem_covid)

# Influenza
flu_df <- group_resp_data(resp_percents, condition = "Influenza")
mem_flu <- calc_mem_threshold(flu_df, condition = "Influenza")
flu_ts <- plot_resp_data(mem_flu, include_3 = FALSE,
                               name = "Influenza")
flu_levels <- plot_method_comparison(mem_flu)

# RSV
rsv_df <- group_resp_data(resp_percents, condition = "RSV")
mem_rsv <- calc_mem_threshold(rsv_df, condition = "RSV")
rsv_ts <- plot_resp_data(mem_rsv, include_3 = FALSE,
                               name = "RSV")
rsv_levels <- plot_method_comparison(mem_rsv)

# individual thresholds

geo_ind_mems <- data.frame(
  Condition = c(
    "COVID",
    "Influenza",
    "RSV"
  ),
  Epidemic = c(
    round(unique(mem_covid$epidemic),3),
    round(unique(mem_flu$epidemic),3),
    round(unique(mem_rsv$epidemic),3)
  ),
  Medium = c(
    round(unique(mem_covid$medium),3),
    round(unique(mem_flu$medium),3),
    round(unique(mem_rsv$medium),3)
  ),
  High = c(
    round(unique(mem_covid$high),3),
    round(unique(mem_flu$high),3),
    round(unique(mem_rsv$high),3)
  ),
  `Very High` = c(
    round(unique(mem_covid$veryhigh),3),
    round(unique(mem_flu$veryhigh),3),
    round(unique(mem_rsv$veryhigh),3)
  )
) %>%
  mutate_if(is.numeric, scales::label_percent(accuracy = .1))

geo_ind_levels <- data.frame(
  WeekEnd = mem_covid$WeekEnd,
  covid_level = mem_covid$level,
  flu_level = mem_flu$level,
  rsv_level = mem_rsv$level
) %>%
  mutate(
    level = case_when(
      covid_level == "Very High" | flu_level == "Very High" | rsv_level == "Very High" ~ "Very High",
      covid_level == "High" | flu_level == "High" | rsv_level == "High" ~ "High",
      covid_level == "Medium" | flu_level == "Medium" | rsv_level == "Medium" ~ "Medium",
      covid_level == "Epidemic" | flu_level == "Epidemic" | rsv_level == "Epidemic" ~ "Epidemic",
      TRUE ~ "Low"
    ),
    level = factor(level, levels = c("Low", "Epidemic", "Medium", "High", "Very High"))
  )

ind_levels <- plot_method_comparison(geo_ind_levels)

# big3
big3_df <- group_resp_data(resp_percents, condition = "Combined_3")
mem_big3 <- calc_mem_threshold(big3_df, condition = "Combined_3")
big3_ts <- plot_resp_data(mem_big3, include_3 = TRUE,
                                name = "Any of COVID, Flu, or RSV")
big3_levels <- plot_method_comparison(mem_big3)


# BAR
bar_df <- group_resp_data(resp_percents, condition = "RESP_DD")
mem_bar<- calc_mem_threshold(bar_df, condition = "RESP_DD")
bar_ts <- plot_resp_data(mem_bar, include_3 = TRUE,
                          name = "Respiratory DD")
bar_levels <- plot_method_comparison(mem_bar)


# allresp
resp_df <- group_resp_data(resp_percents, condition = "RESP_CCDD")
mem_resp <- calc_mem_threshold(resp_df, condition = "RESP_CCDD")
resp_ts <- plot_resp_data(mem_resp, include_3 = TRUE,
                                name = "Respiratory Terms or DD")
resp_levels <- plot_method_comparison(mem_resp)


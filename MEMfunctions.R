group_resp_data <- function(df, condition) {
  
  new_df <- df
  
  if (condition=="Combined_3") {
    grouped_data <- new_df %>%
      ungroup() %>%
      filter(Condition=="Combined_3"|Condition=="COVID"|Condition=="Influenza"|Condition=="RSV") %>%
      group_by(Year, Week, start, end, season, WeekEnd, Condition) %>%
      summarise_at(c("Visits", "Denominator"), sum, na.rm = TRUE) %>%
      ungroup() %>%
      mutate(Percent = Visits/Denominator) %>%
      # filter(season=="2022-2023") %>%
      select(-Visits, -Denominator) %>%
      pivot_wider(names_from = Condition, values_from = Percent)
  } else if (condition=="RESP_CCDD") {
    grouped_data <- new_df %>%
      ungroup() %>%
      filter(Condition=="RESP_CCDD"|Condition=="COVID"|Condition=="Influenza"|Condition=="RSV") %>%
      group_by(Year, Week, start, end, season, WeekEnd, Condition) %>%
      summarise_at(c("Visits", "Denominator"), sum, na.rm = TRUE) %>%
      ungroup() %>%
      mutate(Percent = Visits/Denominator) %>%
      # filter(season=="2022-2023") %>%
      select(-Visits, -Denominator) %>%
      pivot_wider(names_from = Condition, values_from = Percent)
  }  else if (condition=="RESP_DD") {
    grouped_data <- new_df %>%
      ungroup() %>%
      filter(Condition=="RESP_DD"|Condition=="COVID"|Condition=="Influenza"|Condition=="RSV") %>%
      group_by(Year, Week, start, end, season, WeekEnd, Condition) %>%
      summarise_at(c("Visits", "Denominator"), sum, na.rm = TRUE) %>%
      ungroup() %>%
      mutate(Percent = Visits/Denominator) %>%
      # filter(season=="2022-2023") %>%
      select(-Visits, -Denominator) %>%
      pivot_wider(names_from = Condition, values_from = Percent)
  } else if (condition=="COVID") {
    grouped_data <- new_df %>%
      ungroup() %>%
      filter(Condition=="COVID") %>%
      group_by(Year, Week, start, end, season, WeekEnd, Condition) %>%
      summarise_at(c("Visits", "Denominator"), sum, na.rm = TRUE) %>%
      ungroup() %>%
      mutate(Percent = Visits/Denominator) %>%
      # filter(season=="2022-2023") %>%
      select(-Visits, -Denominator) %>%
      pivot_wider(names_from = Condition, values_from = Percent)
  } else if (condition=="Influenza") {
    grouped_data <- new_df %>%
      ungroup() %>%
      filter(Condition=="Influenza") %>%
      group_by(Year, Week, start, end, season, WeekEnd, Condition) %>%
      summarise_at(c("Visits", "Denominator"), sum, na.rm = TRUE) %>%
      ungroup() %>%
      mutate(Percent = Visits/Denominator) %>%
      # filter(season=="2022-2023") %>%
      select(-Visits, -Denominator) %>%
      pivot_wider(names_from = Condition, values_from = Percent)
  } else if (condition=="RSV") {
    grouped_data <- new_df %>%
      ungroup() %>%
      filter(Condition=="RSV") %>%
      group_by(Year, Week, start, end, season, WeekEnd, Condition) %>%
      summarise_at(c("Visits", "Denominator"), sum, na.rm = TRUE) %>%
      ungroup() %>%
      mutate(Percent = Visits/Denominator) %>%
      # filter(season=="2022-2023") %>%
      select(-Visits, -Denominator) %>%
      pivot_wider(names_from = Condition, values_from = Percent)
  }
  
  
  
  return(grouped_data)
  
}


calc_mem_threshold <- function(data, condition) {
  
  # condition <- "BAR"
  
  data_mem <- data %>%
    filter(season %in% c("2017-2018", 
                         "2018-2019", 
                         "2019-2020", 
                         "2022-2023")) %>%
    dplyr::select(season, 
                  Week, 
                  percent = !!condition) %>%
    pivot_wider(names_from = "season", 
                values_from = "percent") %>%
    select(-Week)
  
  # Calculate thresholds for next season
  thresholds <- memevolution(data_mem, i.evolution.method = "cross")$evolution.data["next",]
  
  mem_df <- data %>%
    select(-Year, -Week, -start, -end,WeekEnd, season, percent = !!condition, everything()) %>%
    filter(season == "2022-2023")%>%
    mutate(
      epidemic = thresholds$epidemic,
      medium = thresholds$medium,
      high = thresholds$high,
      veryhigh = thresholds$veryhigh
    ) %>%
    mutate(
      level = case_when(
        percent < epidemic ~ "Low",
        percent >= epidemic & percent < medium ~ "Epidemic",
        percent >= medium & percent < high ~ "Medium",
        percent >= high & percent < veryhigh ~ "High",
        percent >= veryhigh ~ "Very High"
      ),
      level = factor(level, levels = c("Low", "Epidemic", "Medium", "High", "Very High"))
    )
  
}

add_covid_thresholds <- function(df, thresh_df) {
  
  thresholds <- thresh_df
  
  mem_df <- df %>%
    ungroup() %>%
    select(-Year, -Week, -start, -end, WeekEnd, season, percent = COVID, everything()) %>%
    filter(season == "2022-2023") %>%
    mutate(
      epidemic = thresholds$epidemic,
      medium = thresholds$medium,
      high = thresholds$high,
      veryhigh = thresholds$veryhigh
    ) %>%
    mutate(
      level = case_when(
        percent < epidemic ~ "Low",
        percent >= epidemic & percent < medium ~ "Epidemic",
        percent >= medium & percent < high ~ "Medium",
        percent >= high & percent < veryhigh ~ "High",
        percent >= veryhigh ~ "Very High"
      ),
      level = factor(level, levels = c("Low", "Epidemic", "Medium", "High", "Very High"))
    )
  
}

plot_resp_data <- function(df, include_3 = TRUE,
                           name) {
  
  line_color <- case_when(
    name=="COVID" ~ "#C70371",
    name=="Influenza" ~"#FFC000",
    name=="RSV" ~ "#2399BB",
    TRUE ~ "#000000"
  )
  
  resp_plot <- plot_ly(data = df, x = ~WeekEnd) %>%
    add_trace(y = ~percent, type = "scatter", mode = "line", name = name,
              line = list(color = line_color))
  
  if (include_3 == TRUE) {
    resp_plot <- resp_plot %>%
      add_trace(y = ~COVID, type = "scatter", mode = "line", name = "COVID",
                line = list(color = "#C70371")) %>%
      add_trace(y = ~Influenza, type = "scatter", mode = "line", name = "Flu",
                line = list(color = "#FFC000")) %>%
      add_trace(y = ~RSV, type = "scatter", mode = "line", name = "RSV",
                line = list(color = "#2399BB"))%>%
      layout(
        shapes = list(
          # epidemic line
          list(
            type = "line", 
            x0 = 0, x1 = 1, xref = "paper",
            y0 = unique(df$epidemic), y1 = unique(df$epidemic),
            line = list(color = "#fec44f", dash = "dash")
          ),
          # medium line
          list(
            type = "line", 
            x0 = 0, x1 = 1, xref = "paper",
            y0 = unique(df$medium), y1 = unique(df$medium),
            line = list(color = "#fe9929", dash = "dash")
          ),
          # high line
          list(
            type = "line", 
            x0 = 0, x1 = 1, xref = "paper",
            y0 = unique(df$high), y1 = unique(df$high),
            line = list(color = "#d95f0e", dash = "dash")
          ),
          # veryhigh line
          list(
            type = "line", 
            x0 = 0, x1 = 1, xref = "paper",
            y0 = unique(df$veryhigh), y1 = unique(df$veryhigh),
            line = list(color = "#993404", dash = "dash")
          )
        ),
        legend = list(orientation = "h",
                      xanchor = "center", x = 0.5),
        xaxis = list(
          title = FALSE
        ),
        yaxis = list(
          title = "Percent of ED Visits",
          tickformat = ".1%"
        )
      )
  } else {
    resp_plot <- resp_plot %>%
      layout(
        shapes = list(
          # epidemic line
          list(
            type = "line", 
            x0 = 0, x1 = 1, xref = "paper",
            y0 = unique(df$epidemic), y1 = unique(df$epidemic),
            line = list(color = "#fec44f", dash = "dash")
          ),
          # medium line
          list(
            type = "line", 
            x0 = 0, x1 = 1, xref = "paper",
            y0 = unique(df$medium), y1 = unique(df$medium),
            line = list(color = "#fe9929", dash = "dash")
          ),
          # high line
          list(
            type = "line", 
            x0 = 0, x1 = 1, xref = "paper",
            y0 = unique(df$high), y1 = unique(df$high),
            line = list(color = "#d95f0e", dash = "dash")
          ),
          # veryhigh line
          list(
            type = "line", 
            x0 = 0, x1 = 1, xref = "paper",
            y0 = unique(df$veryhigh), y1 = unique(df$veryhigh),
            line = list(color = "#993404", dash = "dash")
          )
        ),
        legend = list(orientation = "h",
                      xanchor = "center", x = 0.5),
        xaxis = list(
          title = FALSE
        ),
        yaxis = list(
          title = "Percent of ED Visits",
          tickformat = ".1%"
        )
      )
  }
     
  
  return(resp_plot)
  
}

plot_resp_data_no_legend <- function(df, name) {
  
  resp_plot <- plot_ly(data = df, x = ~WeekEnd) %>%
    # add_trace(y = ~percent, type = "bar", name = "Any of COVID, Flu, or RSV",
    #           color = I("grey80")) %>%
    add_trace(y = ~percent, type = "scatter", mode = "line", name = name,
              line = list(color = "#000000"), showlegend = FALSE) %>%
    add_trace(y = ~COVID, type = "scatter", mode = "line", name = "COVID",
              line = list(color = "#C70371"), showlegend = FALSE) %>%
    add_trace(y = ~Influenza, type = "scatter", mode = "line", name = "Flu",
              line = list(color = "#FFC000"), showlegend = FALSE) %>%
    add_trace(y = ~RSV, type = "scatter", mode = "line", name = "RSV",
              line = list(color = "#2399BB"), showlegend = FALSE) %>%
    layout(
      shapes = list(
        # epidemic line
        list(
          type = "line", 
          x0 = 0, x1 = 1, xref = "paper",
          y0 = unique(df$epidemic), y1 = unique(df$epidemic),
          line = list(color = "#fec44f", dash = "dash")
        ),
        # medium line
        list(
          type = "line", 
          x0 = 0, x1 = 1, xref = "paper",
          y0 = unique(df$medium), y1 = unique(df$medium),
          line = list(color = "#fe9929", dash = "dash")
        ),
        # high line
        list(
          type = "line", 
          x0 = 0, x1 = 1, xref = "paper",
          y0 = unique(df$high), y1 = unique(df$high),
          line = list(color = "#d95f0e", dash = "dash")
        ),
        # veryhigh line
        list(
          type = "line", 
          x0 = 0, x1 = 1, xref = "paper",
          y0 = unique(df$veryhigh), y1 = unique(df$veryhigh),
          line = list(color = "#993404", dash = "dash")
        )
      ),
      showlegend = FALSE,
      xaxis = list(
        title = FALSE
      ),
      yaxis = list(
        title = "Percent of ED Visits",
        tickformat = ".1%"
      )
    )
  
  return(resp_plot)
  
}

plot_method_comparison <- function(mem_df) {
  
  mem <- plot_ly(mem_df) %>%
    add_trace(x = ~WeekEnd, y = .1, legend.group = ~level,
              color = ~level, colors = c("grey80", "#fec44f", "#fe9929", "#d95f0e", "#993404"),
              type = "bar") %>%
    layout(
      yaxis = list(
        showticklabels = FALSE
      ),
      legend = list(orientation = "h",
                    xanchor = "center", x = 0.5,
                    font = list(size = 6)),
      xaxis = list(
        title = FALSE
      )
    )
  
  return(mem)
  
}

plot_method_comparison_no_legend <- function(mem_df) {
  
  mem <- plot_ly(mem_df) %>%
    add_trace(x = ~WeekEnd, y = .1, legend.group = ~level, showlegend = FALSE,
              color = ~level, colors = c("grey80", "#fec44f", "#fe9929", "#d95f0e", "#993404"),
              type = "bar") %>%
    layout(
      yaxis = list(
        showticklabels = FALSE
      ),
      legend = list(orientation = "h",
                    xanchor = "center", x = 0.5,
                    font = list(size = 6)),
      xaxis = list(
        title = FALSE
      )
    )
  
  return(mem)
  
}


geo <- "&geography=wa_spokane"

geo_name <- "Spokane Regional Health District"

pacman_installed <- "pacman" %in% rownames(installed.packages())
if (pacman_installed == FALSE) {
  install.packages("pacman")
}

packages_to_load <- c(
  "tidyverse",
  "Rnssp",
  "janitor",
  "lubridate",
  "MMWRweek",
  "ggthemes",
  "plotly",
  "mem",
  "flexdashboard",
  "rmarkdown",
  "DT"
)

pacman::p_load(packages_to_load, update = FALSE, character.only = TRUE)



source("Scripts/UserCredentials.R")
source("Scripts/PullData.R")
# source("COVIDprep.R")
load("Data/covid_thresholds.RData")
source("Scripts/MEMfunctions.R")
source("Scripts/GEOprep.R")

render("Geo-Evaluation.Rmd",
       output_file = paste0(str_replace_all(geo_name," ","-"),"-ED-Thresholds.html"))



# Enter the ESSENCE API syntax for the geographies of interest
# Example: "&geography=wa_spokane"
geo <- ""

# Enter the name of the region/geography of interest
# Example: "Spokane Regional Health District" 
geo_name <- ""

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
source("COVIDprep.R")
source("Scripts/MEMfunctions.R")
source("Scripts/GEOprep.R")

render("Geo-Evaluation.Rmd",
       output_file = paste0(str_replace_all(geo_name," ","-"),"-ED-Thresholds.html"))


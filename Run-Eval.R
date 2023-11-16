#################################

# Enter the ESSENCE datasource you want to base your analysis on
# Options: 
#   "facility_site" - facility location, full details for an entire site
#   "facility_region" - facility location, full details for a region within a site
#   "patient_site" - patient location, full details for an entire site
#   "patient_region" - patient location, full details for a region within a site
#   "hhs_national" - facility location, limited details national
#   "hhs_region" - facility location, limited details by HHS region
datasource <- "patient_site"

# Enter the ESSENCE API syntax for the geographies of interest
# Make sure that this matches the datasource type (see examples below)
# facility_site or patient_site example: "&site=934"
# facility_region or patient_region example: "&geography=wa_spokane"
# HHS_region example: "&geography=region%20x"
# HHS_national: ""
geo_url <- "&site=934"

# Enter the name of the region/geography of interest
# Example: "Washington State" 
geo_name <- "Washington State"

#################################

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
  "DT",
  "gt"
)

pacman::p_load(packages_to_load, update = FALSE, character.only = TRUE)

source("Scripts/UserCredentials.R")
source("Scripts/PullData.R")
source("COVIDprep.R")
source("Scripts/MEMfunctions.R")
source("Scripts/GEOprep.R")

render("Geo-Evaluation.Rmd",
       output_file = paste0(str_replace_all(geo_name," ","-"),"-ED-Thresholds.html"))


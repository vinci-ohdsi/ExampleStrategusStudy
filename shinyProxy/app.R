################################################################################
# INSTRUCTIONS: The code below assumes you uploaded results to a PostgreSQL 
# or SQLite database per the UploadResults.R script.This script will launch a 
# Shiny results viewer to analyze results from the study.
#
# See the Working with results section
# of the UsingThisTemplate.md for more details.
# 
# More information about working with results produced by running Glp1Dili 
# is found at:
# https://ohdsi.github.io/Glp1Dili/articles/WorkingWithResults.html
# ##############################################################################

library(ShinyAppBuilder)
library(OhdsiShinyModules)

shinyConfig <- initializeModuleConfig() |>
  addModuleConfig(
    createDefaultAboutConfig()
  )  |>
  addModuleConfig(
    createDefaultDatasourcesConfig()
  )  |>
  addModuleConfig(
    createDefaultCohortGeneratorConfig()
  ) |>
  addModuleConfig(
    createDefaultCohortDiagnosticsConfig()
  ) |>
  addModuleConfig(
    createDefaultCharacterizationConfig()
  ) |>
  addModuleConfig(
    createDefaultPredictionConfig()
  ) |>
  addModuleConfig(
    createDefaultEstimationConfig()
  ) 

cli::cli_h1("Starting shiny server")
serverStr <- paste0(Sys.getenv("shinydbServer"), "/", Sys.getenv("shinydbDatabase"))
cli::cli_alert_info("Connecting to {serverStr}")
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = serverStr,
  port = Sys.getenv("shinydbPort"),
  user = "shinyproxy",
  password = Sys.getenv("shinydbPw")
)

cli::cli_h2("Loading schema")
ShinyAppBuilder::createShinyApp(
   config = shinyConfig,
   connectionDetails = connectionDetails,
   resultDatabaseSettings = createDefaultResultDatabaseSettings(schema = "strategus_tutorial"),
   title = "Population-level Estimation Tutorial with Strategus"
)

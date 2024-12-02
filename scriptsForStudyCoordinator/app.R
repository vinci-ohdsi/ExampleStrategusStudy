################################################################################
# INSTRUCTIONS: The code below assumes you uploaded results to a PostgreSQL 
# or SQLite database per the UploadResults.R script.This script will launch a 
# Shiny results viewer to analyze results from the study.
#
# Make sure you have set the connection details to your results database in
# scriptsForStudyCoordinator/SetConnectionDetails.R.
# ##############################################################################

library(ShinyAppBuilder)
library(OhdsiShinyModules)

source("scriptsForStudyCoordinator/SetConnectionDetails.R")

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

# now create the shiny app based on the config file and view the results
# based on the connection 
ShinyAppBuilder::createShinyApp(
  config = shinyConfig, 
  connectionDetails = resultsConnectionDetails,
  resultDatabaseSettings = createDefaultResultDatabaseSettings(schema = resultsDatabaseSchema)
)

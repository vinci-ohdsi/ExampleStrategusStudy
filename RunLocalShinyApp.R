# This code creates a local SQLite results database, loads the results of one database into the 
# resuls database, and launches a Shiny app to view the results.

##=========== START OF INPUTS ==========

outputLocation <- "/Users/schuemie/Data/ExampleStrategusStudy"
databaseName <- "CCAE"
sqliteFileName <- "/Users/schuemie/Data/ExampleStrategusStudy/results.sqlite"

##=========== END OF INPUTS ==========

##################################
# DO NOT MODIFY BELOW THIS POINT
##################################
library(ShinyAppBuilder)
library(OhdsiShinyModules)

strategusOutputFolder <- file.path(outputLocation, databaseName, "strategusOutput")

resultsDatabaseSchema <- "main"
unlink(sqliteFileName) # Deletes database file if it already exists!
resultsConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "sqlite",
  server = sqliteFileName
)

# Create results schema and upload results ---------------------------------------------------------
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/studyAnalysisSpecification.json"
)
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = strategusOutputFolder
)
Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)
Strategus::uploadResults(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)

# Launch Shiny app ---------------------------------------------------------------------------------
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
ShinyAppBuilder::createShinyApp(
  config = shinyConfig, 
  connectionDetails = resultsConnectionDetails,
  resultDatabaseSettings = createDefaultResultDatabaseSettings(schema = resultsDatabaseSchema)
)

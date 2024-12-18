# -------------------------------------------------------
#                     PLEASE READ
# -------------------------------------------------------
#
# You must call "renv::restore()" and follow the prompts
# to install all of the necessary R libraries to run this
# project. This is a one-time operation that you must do
# before running any code.
#
# !!! PLEASE RESTART R AFTER RUNNING renv::restore() !!!
#
# -------------------------------------------------------
#renv::restore()

# ENVIRONMENT SETTINGS NEEDED FOR RUNNING STUDY ------------
Sys.setenv("_JAVA_OPTIONS"="-Xmx4g") # Sets the Java maximum heap space to 4GB
Sys.setenv("VROOM_THREADS"=1) # Sets the number of threads to 1 to avoid deadlocks on file system

##=========== START OF INPUTS ==========
options(andromedaTempFolder = "e:/andromedaTemp") # Where temp Andromeda files will be written
options(sqlRenderTempEmulationSchema = "scratch.scratch_mschuemi") # For database platforms that don't support temp tables
cdmDatabaseSchema <- "merative_ccae.cdm_merative_ccae_v3046" # The database / schema where the data in CDM format live
workDatabaseSchema <- "scratch.scratch_mschuemi" # A database /schema where study tables can be written
cohortTableName <- "example_strategus_study_ccae" # Where the cohorts will be written
outputLocation <- "e:/exampleStrategusStudy" # Where the intermediate and output files will be written
databaseName <- "CCAE" # Only used as a folder name for results from the study
minCellCount <- 5 # Minimum cell count for inclusion in output tables

# Create the connection details for your CDM
# More details on how to do this are found here:
# https://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "spark",
  connectionString = keyring::key_get("databricksConnectionString"),
  user = "token",
  password = keyring::key_get("databricksToken")
)

# You can use this snippet to test your connection
#conn <- DatabaseConnector::connect(connectionDetails)
#DatabaseConnector::disconnect(conn)

##=========== END OF INPUTS ==========

##################################
# DO NOT MODIFY BELOW THIS POINT
##################################

analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/studyAnalysisSpecification.json"
)

executionSettings <- Strategus::createCdmExecutionSettings(
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, databaseName, "strategusWork"),
  resultsFolder = file.path(outputLocation, databaseName, "strategusOutput"),
  minCellCount = minCellCount
)

if (!dir.exists(file.path(outputLocation, databaseName))) {
  dir.create(file.path(outputLocation, databaseName), recursive = T)
}
ParallelLogger::saveSettingsToJson(
  object = executionSettings,
  fileName = file.path(outputLocation, databaseName, "executionSettings.json")
)

## VA SPECIFIC CODE START ---------
library(Strategus)

CohortGeneratorModule$set(
  "public", "execute", 
  function(connectionDetails, analysisSpecifications, executionSettings) {
    super$.validateCdmExecutionSettings(executionSettings)
    super$execute(connectionDetails, analysisSpecifications, executionSettings)
    
    jobContext <- private$jobContext
    cohortDefinitionSet <- super$.createCohortDefinitionSetFromJobContext()
    
    message("Running VA-specific refactoring")
    if (TRUE) {
      for (i in 1:nrow(cohortDefinitionSet)) {
        newSql <- VaTools::translateToCustomVaSqlText(cohortDefinitionSet$sql[i], NULL)         
        cohortDefinitionSet$sql[i] <- newSql
      }
    }    
    
    negativeControlOutcomeSettings <- private$.createNegativeControlOutcomeSettingsFromJobContext()
    resultsFolder <- jobContext$moduleExecutionSettings$resultsSubFolder
    if (!dir.exists(resultsFolder)) {
      dir.create(resultsFolder, recursive = TRUE)
    }
    
    CohortGenerator::runCohortGeneration(
      connectionDetails = connectionDetails,
      cdmDatabaseSchema = jobContext$moduleExecutionSettings$cdmDatabaseSchema,
      cohortDatabaseSchema = jobContext$moduleExecutionSettings$workDatabaseSchema,
      cohortTableNames = jobContext$moduleExecutionSettings$cohortTableNames,
      cohortDefinitionSet = cohortDefinitionSet,
      negativeControlOutcomeCohortSet = negativeControlOutcomeSettings$cohortSet,
      occurrenceType = negativeControlOutcomeSettings$occurrenceType,
      detectOnDescendants = negativeControlOutcomeSettings$detectOnDescendants,
      outputFolder = resultsFolder,
      databaseId = jobContext$moduleExecutionSettings$cdmDatabaseMetaData$databaseId,
      minCellCount = jobContext$moduleExecutionSettings$minCellCount,
      incremental = jobContext$moduleExecutionSettings$incremental,
      incrementalFolder = jobContext$moduleExecutionSettings$workSubFolder
    )
    
    private$.message(paste("Results available at:", resultsFolder))
  },
  overwrite = TRUE
)

# # Stand-alone execution the CG Module             
# cgModule <- CohortGeneratorModule$new()
# cgModule$execute(
#   connectionDetails = connectionDetails,
#   analysisSpecifications = analysisSpecifications,
#   executionSettings = executionSettings
# )
# 
# # Remove CG module from the analysis specification
# analysisSpecifications$moduleSpecifications <- analysisSpecifications$moduleSpecifications[2:5]

# Note that given the redefinition of `CohortGeneratorModule` there is no need to
# separate out its execution as is done above.

## VA SPECIFIC CODE END ---------

Strategus::execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  connectionDetails = connectionDetails
)

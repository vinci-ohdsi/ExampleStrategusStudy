################################################################################
# INSTRUCTIONS: The code below assumes you have used CreateResultsDataModel.R to
# create the results data model in a Postgres or SQLite database. This script 
# will loop over all the zip files created by the ShareResults.R script.
#
# Make sure you have set the connection details to your results database in
# scriptsForStudyCoordinator/SetConnectionDetails.R.
# ##############################################################################

source("scriptsForStudyCoordinator/SetConnectionDetails.R")

resultsFiles <- list.files(path = "/Users/schuemie/Data/ExampleStrategusStudy", pattern = ".zip", full.names = T, recursive = F)

analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/studyAnalysisSpecification.json"
)

# Setup logging ----------------------------------------------------------------
ParallelLogger::clearLoggers()
ParallelLogger::addDefaultFileLogger(
  fileName = "upload-log.txt",
  name = "RESULTS_FILE_LOGGER"
)
ParallelLogger::addDefaultErrorReportLogger(
  fileName = "upload-errorReport.txt",
  name = "RESULTS_ERROR_LOGGER"
)

# Upload Results ---------------------------------------------------------------
for (resultsFile in resultsFiles) {
  tempFolder <- tempfile("StrategusResults")
  dir.create(tempFolder)
  unzip(resultsFile, exdir = tempFolder)
  resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
    resultsDatabaseSchema = resultsDatabaseSchema,
    resultsFolder = tempFolder,
  )
  
  Strategus::uploadResults(
    analysisSpecifications = analysisSpecifications,
    resultsDataModelSettings = resultsDataModelSettings,
    resultsConnectionDetails = resultsConnectionDetails
  )
}

# Unregister loggers -----------------------------------------------------------
ParallelLogger::unregisterLogger("RESULTS_FILE_LOGGER")
ParallelLogger::unregisterLogger("RESULTS_ERROR_LOGGER")

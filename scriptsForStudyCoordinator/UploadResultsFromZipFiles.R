################################################################################
# INSTRUCTIONS: The code below assumes you have used CreateResultsDataModel.R to
# create the results data model in a Postgres or SQLite database. This script 
# will loop over all of the directories found under the "results" folder and 
# upload the results. 
#
# This script also contains some commented out code for 
# setting read-only permissions for a user account on the results schema. 
# This is used when setting up a read-only user for use with a Shiny results 
# viewer. Additionally, there is commented out code that will allow you to run
# ANALYZE on each results table to ensure the database is performant.
# 
# See the Working with results section
# of the UsingThisTemplate.md for more details.
# 
# More information about working with results produced by running Strategus 
# is found at:
# https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html
# ##############################################################################

# Settings ---------------------------------------------------------------------
source("scriptsForStudyCoordinator/SetConnectionDetails.R")

resultsFiles <- list.files(path = "/Users/schuemie/Data/ExampleStrategusStudy", pattern = ".zip", full.names = T, recursive = F)


# Don't make changes below this line -------------------------------------------
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

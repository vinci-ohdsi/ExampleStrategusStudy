################################################################################
# INSTRUCTIONS: The code below assumes you either have access to a PostgreSQL
# database and permissions to create tables in an existing schema specified by 
# the resultsDatabaseSchema parameter, or that you want to use a local SQLite
# database.
# 
# More information about working with results produced by running Strategus 
# is found at:
# https://ohdsi.github.io/Strategus/articles/WorkingWithResults.html
# ##############################################################################

# Settings ---------------------------------------------------------------------
source("scriptsForStudyCoordinator/SetConnectionDetails.R")

# Need at least one results folder to know what table structure to create. 
# resultsFolder should at least contain a 'strategusOutput' subfolder:
resultsFolder <- "/Users/schuemie/Data/ExampleStrategusStudy"#list.dirs(path = "/Users/schuemie/Data/ExampleStrategusStudy", full.names = T, recursive = F)[1]


# Don't make changes below this line -------------------------------------------
analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/studyAnalysisSpecification.json"
)
resultsDataModelSettings <- Strategus::createResultsDataModelSettings(
  resultsDatabaseSchema = resultsDatabaseSchema,
  resultsFolder = file.path(resultsFolder, "strategusOutput")
)
Strategus::createResultDataModel(
  analysisSpecifications = analysisSpecifications,
  resultsDataModelSettings = resultsDataModelSettings,
  resultsConnectionDetails = resultsConnectionDetails
)

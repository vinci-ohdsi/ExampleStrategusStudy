################################################################################
# INSTRUCTIONS: This script assumes you have cohorts you would like to use in an
# ATLAS instance. It also allows loading concepts to exclude and negative 
# control concepts from ATLAS. You will need to update the baseUrl to match
# the settings for your environment.
# ##############################################################################

# remotes::install_github("OHDSI/ROhdsiWebApi")
library(dplyr)
# baseUrl <- "https://atlas-demo.ohdsi.org/WebAPI"
baseUrl <- Sys.getenv("baseUrl")
# Use this if your WebAPI instance has security enabled
ROhdsiWebApi::authorizeWebApi(
  baseUrl = baseUrl,
  authMethod = "windows"
)

# Download and save the cohort definitions ---------------------------------------------------------
cohortDefinitionSet <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = c(
    19137, # GLP-1
    19021, # DPP-4
    19022, # Type 2 diabetes
    19023, # Acute myocardial infarction inpatient setting
    19024, # Acute myocardial infarction any setting
    19059  # Diarrhea
  ),
  generateStats = TRUE
)
readr::write_csv(cohortDefinitionSet, "inst/Cohorts.csv")


# Download and save the covariates to exclude ------------------------------------------------------
covariatesToExcludeConceptSet <- ROhdsiWebApi::getConceptSetDefinition(
  conceptSetId = 436,
  baseUrl = baseUrl
) %>%
  ROhdsiWebApi::resolveConceptSet(
    baseUrl = baseUrl
  ) %>%
  ROhdsiWebApi::getConcepts(
    baseUrl = baseUrl
  ) 

CohortGenerator::writeCsv(
  x = covariatesToExcludeConceptSet,
  file = "inst/excludedCovariateConcepts.csv",
  warnOnFileNameCaseMismatch = F
)


# Download and save the negative control outcomes --------------------------------------------------
negativeControlOutcomeCohortSet <- ROhdsiWebApi::getConceptSetDefinition(
  conceptSetId = 9025,
  baseUrl = baseUrl
) %>%
  ROhdsiWebApi::resolveConceptSet(
    baseUrl = baseUrl
  ) %>%
  ROhdsiWebApi::getConcepts(
    baseUrl = baseUrl
  ) %>%
  rename(outcomeConceptId = "conceptId",
         cohortName = "conceptName") %>%
  mutate(cohortId = row_number() + 10000) %>%
  select(cohortId, cohortName, outcomeConceptId)

CohortGenerator::writeCsv(
  x = negativeControlOutcomeCohortSet,
  file = "inst/negativeControlOutcomes.csv",
  warnOnFileNameCaseMismatch = F
)

# Example Strategus study

This is a full example of a Strategus study using all modules, including cohort diagnostics, characterization, estimation, and prediction.

# To design your own study

If you want to modify this R project for your own study, You'll need to modify and run the scripts in the [scriptsForStudyDesigner](scriptsForStudyDesigner) folder.

Part of the study design are assets that are best created in ATLAS and downloaded to this package, as demonstrated in the [DownloadAssets.R](scriptsForStudyDesigner/DownloadAssets.R) script. These assets are:

-   The various cohort definitions, for the target, comparator, (optional) indication, and outcome cohorts.
-   A concept set to create negative control outcome cohorts. Note that you should **not include descendants** in this concept set.
-   A concept set listing concepts to exclude from the propensity model (and balance computation). This should include the concepts for the target and comparator drug, and any closely related concepts such as injection procedures for injectables. It is best not to include descendants for this concept either, since these will be automatically included.

The [CreateStrategusAnalysisSpecifications.R](scriptsForStudyDesigner/CreateStrategusAnalysisSpecifications.R) script can be used to create the analysis specifications, and is divided into two sections:

1.  Above the line are settings that likely need to be changed for every study. These include the target, comparator and outcome cohorts, time-at-risk settings, etc.
2.  Below the line are settings that probably should not be changed. These contain recommended settings for the various modules.

## Exposure cohorts

The exposure cohorts will be re-used for the various analyses. For the cohort method, the target and comparator cohort will automatically be restricted to first use only, and only to those exposures after entering the indication cohort (if provided). This means the exposure cohorts provided by the user need not, and in fact should not be restricted to first use only and the indication cohort. This way, the same exposure cohorts can also for example be used by the self-controlled case series analysis.

In other words, the provided exposure cohorts should be very simple, including all exposures (not just the first) to the treatment, and not have any exclusion criteria such as requiring the indication prior or some washout period. These will all be applied where appropriate by the analysis code.

# Executing the study at a site

To execute the study at a site, you can use the scripts in the root folder:

-   [ExecuteAnalyses.R](ExecuteAnalyses.R) should first be modified with the correct database connection details etc., after which it can be run to execute the study.
-   [RunLocalShinyApp.R](RunLocalShinyApp.R) can then be used to view the generated results in a local Shiny app. (Optional)
-   [ShareResults.R](ShareResults.R) can then be modified and executed to send the results to an OHDSI SFTP server. Note that the results do not contain patient-identifiable information.

# Combining the results at the study coordinating center

The study lead can use the scripts provided in the [scriptsForStudyCoordinator](scriptsForStudyCoordinator) folder to synthesize the results and load them in a Postgres database:

-   [SetConnectionDetails.R](scriptsForStudyCoordinator/SetConnectionDetails.R) must be modified to set the connection details and schema for the results database. (Can be either a Postgres server or a local SQLite file.)
-   [DownloadZipFiles.R](scriptsForStudyCoordinator/DownloadZipFiles.R) can be used to download the results from the various data sites.
-   [CreateResultsDataModel.R](scriptsForStudyCoordinator/CreateResultsDataModel.R) will create the results data model on the database server.
-   [UploadResultsFromZipFiles.R](scriptsForStudyCoordinator/UploadResultsFromZipFiles.R) will upload the results from the downloaded zip files.
-   [EvidenceSynthesis.R](scriptsForStudyCoordinator/EvidenceSynthesis.R) can be used to perform the meta-analysis across databases.
-   [GrantPermissionsOnTables.R](scriptsForStudyCoordinator/GrantPermissionsOnTables.R) can optionally be run to set the right permissions on the results tables.
-   [app.R](scriptsForStudyCoordinator/app.R) can launch the Shiny app.

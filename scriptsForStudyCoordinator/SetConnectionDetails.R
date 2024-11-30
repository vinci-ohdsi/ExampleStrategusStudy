# Specify how to connect to the results database server. Used in other scripts.
# You can choose to use a local SQLite database or a (remote) Postgres server. Uncomment the option
# you wish to use

# Local SQLite database:

# resultsDatabaseSchema <- "main"
# resultsConnectionDetails <- DatabaseConnector::createConnectionDetails(
#   dbms = "sqlite",
#   server = "E:/exampleStrategusStudy/Results.sqlite"
# )


# Remote Postgres server:

resultsDatabaseSchema <- "strategus_tutorial"
resultsConnectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = Sys.getenv("OHDSI_RESULTS_DATABASE_SERVER"),
  user = Sys.getenv("OHDSI_RESULTS_DATABASE_USER"),
  password = Sys.getenv("OHDSI_RESULTS_DATABASE_PASSWORD")
)


# Optional code to test the connection -------------------------------------------------------------
# conn <- DatabaseConnector::connect(resultsConnectionDetails)
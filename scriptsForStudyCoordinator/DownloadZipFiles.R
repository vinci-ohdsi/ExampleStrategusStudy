##=========== START OF INPUTS ==========
downloadFolder <- "/Users/schuemie/Data/ExampleStrategusStudy" # Where the zip files will be written
# For downloading the results:
keyFileName <- "[location where you are storing: e.g. ~/keys/study-coordinator-covid19.dat]"
userName <- "[user name provided by the study coordinator: eg: study-coordinator-covid19]"

##=========== END OF INPUTS ==========

##################################
# DO NOT MODIFY BELOW THIS POINT
##################################

connection <- OhdsiSharing::sftpConnect(keyFileName, userName)
OhdsiSharing::sftpCd(connection, "your-study")
files <- OhdsiSharing::sftpLs()$fileName
OhdsiSharing::sftpGetFiles(connection, files, downloadFolder)
OhdsiSharing::sftpDisconnect(connection)

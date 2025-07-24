#  Copyright (c) 2025. Sandeep Chintabathina

# Code to pull Respiratory Illness related visits and hospitalizations using Essence API in R
# Code will also upload data to a sharepoint location

# Code to connect to Essence through Rnssp package
# Author: Sandeep Chintabathina
# 07/24/2025

# Install the package first time
#devtools::install_github("cdcgov/Rnssp")

library(Rnssp)

library(openxlsx)

# Setting the path to the source file location
setwd(this.path::here())

# Creating an ESSENCE user profile
# Uncomment when you run this code for the first time and save profile to a rda file to be used for subsequent logins
#myProfile <- create_profile()

# save profile object to file for future use
#save(myProfile, file="myProfile.rda") # saveRDS(myProfile, "myProfile.rds")
# Load profile object
load("myProfile.rda") 

# Informational
str(myProfile)

# get today's date in the format ddMonyy for e.g. 17Jul24
today<- format(Sys.Date(),'%d%b%y')
print(today)

diff_in_days <- as.numeric(difftime(as.Date('22Jul24',format='%d%b%y'),as.Date('12Apr22',format='%d%b%y'),units="days"))
print(diff_in_days)
 
start_date <- format(Sys.Date()-diff_in_days,'%d%b%y')
print(start_date)

# Total Admits by Age from Respiratory Virus Dashboard Hawaii
# This will be pulled using a tablebuilder API

url<- "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?percentParam=noPercent&medicalGroupingSystem=essencesyndromes&dateconfig=15&userId=6736&ageGroup2=00-17&ageGroup2=18-25&ageGroup2=26-54&ageGroup2=55-64&ageGroup2=65-74&ageGroup2=75-1000&geographySystem=state&geography=hi&datasource=va_er&timeResolution=weekly&aqtTarget=TableBuilder&detector=nodetectordetector&fieldIDs=timeResolution&fieldIDs=ageGroup2&fieldLabels=Week&fieldLabels=Age%20Group%202&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393890&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=ageGroup2"

url <- str_replace(url,'22Jul24',today)
url <- str_replace(url,'12Apr22',start_date)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
colnames(api_data_tb_csv)[1] <- "Week"
class(api_data_tb_csv)
glimpse(api_data_tb_csv)
#write.csv(api_data_tb_csv,'total_admitted_by_age.csv',row.names=FALSE)

write.xlsx(api_data_tb_csv,'Total admitted by age.xlsx',rowNames=FALSE,sheetName='Data Table')

###################################################################################################
# Total admitted by Facility from Respiratory Virus Dashboard Hawaii
# This will be pulled using a tablebuilder API

url<- "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?percentParam=noPercent&medicalGroupingSystem=essencesyndromes&dateconfig=15&userId=6736&geographySystem=state&geography=hi&datasource=va_er&timeResolution=weekly&erFacility=34195&erFacility=34931&erFacility=35506&erFacility=34846&erFacility=33880&erFacility=33881&erFacility=34553&erFacility=34845&erFacility=34702&erFacility=34701&erFacility=34844&erFacility=33907&erFacility=34826&erFacility=34847&aqtTarget=TableBuilder&detector=nodetectordetector&fieldIDs=timeResolution&fieldIDs=erFacility&fieldLabels=Week&fieldLabels=Facility&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393891&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=erFacility"

url<- str_replace(url,'22Jul24',today)
url <- str_replace(url,'12Apr22',start_date)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
colnames(api_data_tb_csv)[1] <- "Week"
glimpse(api_data_tb_csv)
#write.csv(api_data_tb_csv,'total_admitted_by_facility.csv',row.names=FALSE)

write.xlsx(api_data_tb_csv,'Total admitted by facility.xlsx',rowNames=FALSE,sheetName='Data Table')

###################################################################################################
# ILI count by facility from Respiratory Virus Dashboard Hawaii

url <- "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?percentParam=noPercent&medicalGroupingSystem=essencesyndromes&dateconfig=15&userId=6736&geographySystem=state&ccddCategory=ili%20ccdd%20v1&geography=hi&datasource=va_er&timeResolution=weekly&erFacility=34195&erFacility=34931&erFacility=35506&erFacility=34846&erFacility=33880&erFacility=33881&erFacility=34553&erFacility=34845&erFacility=34702&erFacility=34701&erFacility=34844&erFacility=33907&erFacility=34826&erFacility=34847&aqtTarget=TableBuilder&detector=nodetectordetector&fieldIDs=timeResolution&fieldIDs=erFacility&fieldLabels=Week&fieldLabels=Facility&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393892&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=erFacility"

url<- str_replace(url,'22Jul24',today)
url <- str_replace(url,'12Apr22',start_date)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
colnames(api_data_tb_csv)[1] <- "Week"
glimpse(api_data_tb_csv)
#write.csv(api_data_tb_csv,'ILI_count_by_facility.csv',row.names=FALSE)

write.xlsx(api_data_tb_csv,'ILI count by facility.xlsx',rowNames=FALSE,sheetName='Data Table')

###################################################################################################
# ILI count by age from Respiratory Virus Dashboard Hawaii

url <- "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?percentParam=noPercent&medicalGroupingSystem=essencesyndromes&dateconfig=15&userId=6736&ageGroup2=00-17&ageGroup2=18-25&ageGroup2=26-54&ageGroup2=55-64&ageGroup2=65-74&ageGroup2=75-1000&geographySystem=state&ccddCategory=ili%20ccdd%20v1&geography=hi&datasource=va_er&timeResolution=weekly&aqtTarget=TableBuilder&detector=nodetectordetector&fieldIDs=timeResolution&fieldIDs=ageGroup2&fieldLabels=Week&fieldLabels=Age%20Group%202&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393893&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=ageGroup2"

url<- str_replace(url,'22Jul24',today)
url <- str_replace(url,'12Apr22',start_date)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
colnames(api_data_tb_csv)[1] <- "Week"
glimpse(api_data_tb_csv)
#write.csv(api_data_tb_csv,'ILI_count_by_age.csv',row.names=FALSE)

write.xlsx(api_data_tb_csv,'ILI count by age.xlsx',rowNames=FALSE,sheetName='Data Table')

###################################################################################################
# Total volume of ED visits from State Respiratory Virus Dashboard

url <- "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393894&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url<- str_replace(url,'22Jul24',today)
url <- str_replace(url,'12Apr22',start_date)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
colnames(api_data_tb_csv) <- c("Date","Has Been Admitted No","Has Been Admitted Yes")
glimpse(api_data_tb_csv)
#write.csv(api_data_tb_csv,'total_volume_of_ED_visits.csv',row.names=FALSE)

write.xlsx(api_data_tb_csv,'Total emergency department visits and hospitalizations.xlsx',rowNames=FALSE,sheetName='Data Table')

###################################################################################################
# Broad acute respiratory from State Respiratory Virus Dashboard

url <- "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&ccddCategory=cdc%20broad%20acute%20respiratory%20dd%20v1&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393895&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url<- str_replace(url,'22Jul24',today)
url <- str_replace(url,'12Apr22',start_date)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
colnames(api_data_tb_csv) <- c("Date","Has Been Admitted No","Has Been Admitted Yes")
glimpse(api_data_tb_csv)
#write.csv(api_data_tb_csv,'broad_acute_respiratory.csv',row.names=FALSE)

write.xlsx(api_data_tb_csv,'CDC Acute broad respiratory illness emergency department visits and hospitalizations.xlsx',rowNames=FALSE,sheetName='Data Table')

###################################################################################################
# COVID from State Respiratory Virus Dashboard

url <- "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&ccddCategory=cdc%20coronavirus-dd%20v1&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393896&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url<- str_replace(url,'22Jul24',today)
url <- str_replace(url,'12Apr22',start_date)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
colnames(api_data_tb_csv) <- c("Date","Has Been Admitted No","Has Been Admitted Yes")
glimpse(api_data_tb_csv)
#write.csv(api_data_tb_csv,'COVID.csv',row.names=FALSE)

write.xlsx(api_data_tb_csv,'Covid emergency department visits and hospitalizations.xlsx',rowNames=FALSE,sheetName='Data Table')


###################################################################################################
# Influenza from State Respiratory Virus Dashboard

url <- "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&ccddCategory=cdc%20influenza%20dd%20v1&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393898&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url<- str_replace(url,'22Jul24',today)
url <- str_replace(url,'12Apr22',start_date)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
colnames(api_data_tb_csv) <- c("Date","Has Been Admitted No","Has Been Admitted Yes")
glimpse(api_data_tb_csv)
#write.csv(api_data_tb_csv,'Influenza.csv',row.names=FALSE)

write.xlsx(api_data_tb_csv,'Influenza emergency department visits and hospitalizations.xlsx',rowNames=FALSE,sheetName='Data Table')

###################################################################################################
# RSV from State Respiratory Virus Dashboard

url <- "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&ccddCategory=cdc%20respiratory%20syncytial%20virus%20dd%20v1&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393897&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url<- str_replace(url,'22Jul24',today)
url <- str_replace(url,'12Apr22',start_date)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
colnames(api_data_tb_csv) <- c("Date","Has Been Admitted No","Has Been Admitted Yes")
glimpse(api_data_tb_csv)
#write.csv(api_data_tb_csv,'RSV.csv',row.names=FALSE)

write.xlsx(api_data_tb_csv,'RSV emergency department visits and hospitalizations.xlsx',rowNames=FALSE,sheetName='Data Table')

# End of 9 reports


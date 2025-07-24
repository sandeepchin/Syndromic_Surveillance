#  Copyright (c) 2025. Sandeep Chintabathina
# 10/28/2024

# Automating Maui Wildfire suicide attempts and ideation reports and providing more breakdowns
library(Rnssp)
library(openxlsx)
library(MMWRweek)
library(lubridate)
library(tidyverse)

#install.packages('MMWRweek')

# Setting the path to the source file location
setwd(this.path::here())

# Creating an ESSENCE user profile
# Uncomment when you run this code for the first time and save profile to a rda file to be used for subsequent logins
#myProfile <- create_profile()

# save profile object to file for future use
#save(myProfile, file="myProfile.rda") # saveRDS(myProfile, "myProfile.rds")
# Load profile object
load("myProfile.rda") 

# get today's date in the format ddMonyy for e.g. 17Jul24
today<- format(Sys.Date(),'%d%b%y')
print(today)

# Get data from Essence

url<-"https://essence.syndromicsurveillance.org/nssp_essence/api/dataDetails/csv?datasource=va_er&startDate=25Jun2023&medicalGroupingSystem=essencesyndromes&userId=4118&dateconfig=4&endDate=2Nov2024&percentParam=noPercent&erFacility=35506&aqtTarget=DataDetails&geographySystem=region&detector=nodetectordetector&timeResolution=weekly&ccddCategoryFreeText=%5ECDC%20Suicidal%20Ideation%20v1%5E,OR,%5ECDC%20Suicide%20Attempt%20v1%5E,OR,%5ECDC%20Suicide%20Attempt%20v2%5E"

# Get MMWR week for today's date
mmwrweek <- MMWRweek(Sys.Date())
#print(mmwrweek$MMWRyear)
# Get the date of the last day for that week
lastdate <- MMWRweek2Date(mmwrweek$MMWRyear,mmwrweek$MMWRweek,7)
print(lastdate)
url <- change_dates(url,end_date = lastdate)
# Data Pull from ESSENCE
api_data_tb_csv <- get_api_data(url, fromCSV = TRUE)
glimpse(api_data_tb_csv)
#print(colnames(attempt_cases))

#----------------------------------------------
attempt_cases <- api_data_tb_csv %>% filter(grepl('Attempt',CCDDCategory_flat,ignore.case=TRUE))
#print(attempt_cases)
write.xlsx(attempt_cases,'suicide_attempts.xlsx',rowNames=FALSE)

# Non-attempt cases
non_attempt_cases <- api_data_tb_csv %>% filter(!grepl('Attempt',CCDDCategory_flat,ignore.case=TRUE))
write.xlsx(non_attempt_cases,'suicide_ideations.xlsx',rowNames=FALSE)

#-------------------------------------------------
# Dividing attempt cases by sex
attempt_cases_male <- attempt_cases %>% filter(grepl('m',Sex,ignore.case=TRUE))
attempt_cases_female <- attempt_cases %>% filter(grepl('f',Sex,ignore.case=TRUE))

write.xlsx(attempt_cases_male,'suicide_attempts_male.xlsx',rowNames=FALSE)
write.xlsx(attempt_cases_female,'suicide_attempts_female.xlsx',rowNames=FALSE)

#-----------------------------------------------------
# Dividing non-attempt cases by sex
non_attempt_cases_male <- non_attempt_cases %>% filter(grepl('m',Sex,ignore.case=TRUE))
non_attempt_cases_female <- non_attempt_cases %>% filter(grepl('f',Sex,ignore.case=TRUE))

write.xlsx(non_attempt_cases_male,'suicide_ideations_male.xlsx',rowNames=FALSE)
write.xlsx(non_attempt_cases_female,'suicide_ideations_female.xlsx',rowNames=FALSE)

#-----------------------------------------------------
# Attempts by age - youth (<18) and >=18

attempts_youth <- attempt_cases[attempt_cases$'Age'<18,]
write.xlsx(attempts_youth,'suicide_attempts_youth.xlsx',rowNames=FALSE)

attempts_adult <- attempt_cases[attempt_cases$'Age'>=18,]
write.xlsx(attempts_adult,'suicide_attempts_adult.xlsx',rowNames=FALSE)

# Ideation by age - age<18 and >=18
ideations_youth <- non_attempt_cases[non_attempt_cases$'Age'<18,]
write.xlsx(ideations_youth,'suicide_ideations_youth.xlsx',rowNames=FALSE)

ideations_adult <- non_attempt_cases[non_attempt_cases$'Age'>=18,]
write.xlsx(ideations_adult,'suicide_ideations_adult.xlsx',rowNames=FALSE)

#--------------------------------------------------------------------
# To get weekly counts by sex
print(colnames(attempt_cases))
print(attempt_cases$Date)
attempt_cases$Date<- MMWRweek(mdy(attempt_cases$Date))
attempt_cases$Date <- MMWRweek2Date(attempt_cases$Date$MMWRyear,attempt_cases$Date$MMWRweek,7)

attempt_cases <- attempt_cases[order(attempt_cases$Date),]
print(attempt_cases$Date)

attempt_cases_grouped <- attempt_cases %>% group_by(Date,Sex)

attempt_cases_grouped<-attempt_cases_grouped %>% summarise(n = n())
  
print(attempt_cases_grouped,n=67)
  
  
  

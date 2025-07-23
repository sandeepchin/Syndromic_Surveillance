
#  Copyright (c) 2025. Sandeep Chintabathina

# Code to get patient class in prod data

library(DBI)
library(odbc)

datamart <- dbConnect(odbc::odbc(),dsn= "BioSense_Platform")

# Query to get the facility name and patient class code reported 
table1 <- dbGetQuery(datamart, paste0("
                    select b.Facility_Name,max(a.C_Biosense_Facility_ID) as Biosense_Facility_ID,max(a.Feed_name) as Feed_Name, a.Patient_Class_Code 
                    from HI_PR_Processed a left join HI_MFT b on a.C_Biosense_Facility_ID=b.C_Biosense_Facility_ID
                    where Arrived_Date >= '2025-06-19'
                    group by b.Facility_Name,a.Patient_Class_Code
                    "))


#table
write.csv(table1, file = "R_code/rpt/patient_class_20250619_20250623.csv",row.names=FALSE)


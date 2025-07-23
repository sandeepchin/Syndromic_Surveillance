#  Copyright (c) 2025. Sandeep Chintabathina

# Code to connect to processed and raw data from the backend database

library(DBI)
library(odbc)

datamart <- dbConnect(odbc::odbc(),dsn= "BioSense_Platform")

table1 <- dbGetQuery(datamart, paste0("
                    select * from HI_ST_Processed
                    where Arrived_Date = '2025-07-15'
                    "))
table2 <- dbGetQuery(datamart, paste0("
                    select * from HI_ST_Raw
                    where Arrived_Date = '2025-07-15'
                    "))
#table
write.csv(table1, file = "processed_20250715.csv",row.names=FALSE)
write.csv(table2, file = "raw_20250715.csv",row.names=FALSE)

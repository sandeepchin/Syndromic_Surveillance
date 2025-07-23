
#  Copyright (c) 2025. Sandeep Chintabathina

# R code to get pregnancy status percentages based on gender and age 12-55

library(DBI)
library(odbc)

# Setting the path to the source file location
setwd("~/R_code")

# this.path could not be installed
#setwd(this.path::here())

datamart <- dbConnect(odbc::odbc(),dsn= "BioSense_Platform")

table1 <- dbGetQuery(datamart, paste0("

        select 	max(b.Facility_Name) as Facility_Name,
            a.Visit_ID as Visit_ID,
            a.First_Patient_ID as Patient_MRN,
            /* Convert first 20 chars from hst datetime object into the yyyy-mm-dd hh:mi:ss format (numbered 20) */
            convert(varchar(20),max(a.C_Visit_Date_Time),20) as visit_date_time,
            /*string_agg(a.C_Visit_Date,',') as Visit_Date_list,*/
            max(a.Administrative_Sex) as Admin_Sex,
            max(a.Age_Reported) as Age,
            max(a.Age_Units_Reported) as Age_Units,
            max(a.Pregnancy_Status_Code) as Pregnancy_Status_Code,
            max(a.Pregnancy_Status_Description) as Pregnancy_Status_Description,
            string_agg(Message_Control_Id,',') as message_control_id_list
        from
            HI_ST_Processed a left join HI_MFT b on a.C_Biosense_Facility_ID=b.C_Biosense_Facility_ID
            where a.C_Visit_Date >= '2025-07-08' /*and a.Arrived_Date <= '2024-09-23'*/
              and a.Feed_Name like 'HI_HHSC'
              and a.Administrative_Sex='F'
              and a.Age_Reported >=12 and a.Age_Reported <=55
              and Age_Units_Reported in ('year')
            group by 
            a.Visit_ID,
            a.First_Patient_ID
            /*having count(a.Pregnancy_Status_Code)=0
            and count(a.Pregnancy_Status_Description)=0*/
            order by a.First_Patient_ID
"))

# Set na='' to replace NA values with blank
write.csv(table1, file = "rpt/pregnancy_status.csv",row.names=FALSE,na='')



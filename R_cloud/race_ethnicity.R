
#  Copyright (c) 2025. Sandeep Chintabathina

# Code to get race and ethnicity data for every visit and patient ID pairs.
# Using the HI_PR_Processed table to indicate that we are looking at production data and not staging data.

library(DBI)
library(odbc)

datamart <- dbConnect(odbc::odbc(),dsn= "BioSense_Platform")

table1 <- dbGetQuery(datamart, paste0(" /* SQL CODE */
    
           select 	max(b.Facility_Name) as Facility_Name,
          		a.Visit_ID as Visit_ID,
          		a.First_Patient_ID as Patient_MRN,
          		/* Convert first 20 chars from hst datetime object into the yyyy-mm-dd hh:mi:ss format (numbered 20) */
          		convert(varchar(20),max(a.C_Visit_Date_Time),20) as visit_date_time,
          		max(a.Race_Code) as Patient_Race_Code,
          		max(a.Race_Description) as Patient_Race_Description,
          		max(a.Ethnicity_Code) as Patient_Ethnicity_Code,
          		max(a.Ethnicity_Description) as Patient_Ethnicity_Description,
          		string_agg(Message_Control_Id,';') as message_control_id_list /*Lists all message ids received for this visit*/ 
          	from
          		HI_PR_Processed a left join HI_MFT b on a.C_Biosense_Facility_ID=b.C_Biosense_Facility_ID
          	where a.C_Visit_Date >= '2025-07-11' /* and a.C_Visit_Date <= '2025-07-25' */  /* Optional - end date*/
          	and a.Feed_Name like 'HI_Queens'
          	group by 
          		a.Visit_ID,
          		a.First_Patient_ID
          	order by a.First_Patient_ID
"))


# Set na='' to replace NA values with blank
write.csv(table1, file = "R_code/rpt/race_ethnicity.csv",row.names=FALSE,na='')

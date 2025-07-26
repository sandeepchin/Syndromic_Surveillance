
#  Copyright (c) 2025. Sandeep Chintabathina

# Code to get discharge disposition values, death date time and death indicator values
# Discharge disposition values of 20, 40, 41, and 42 are related to death.
# These three elements must be in agreement. 
# That is if discharge disposition is 20, then death date time should be in provided.
# If death date time is given, then death indicator must be Y

library(DBI)
library(odbc)

datamart <- dbConnect(odbc::odbc(),dsn= "BioSense_Platform")

table1 <- dbGetQuery(datamart, paste0(" /* SQL CODE */

    select 	max(b.Facility_Name) as Facility_Name,  /* Aggregation from non-grouped elements */
		a.Visit_ID as Visit_ID,
		a.First_Patient_ID as Patient_MRN,
		convert(varchar(20),max(a.C_Visit_Date_Time),20) as visit_date_time,  /*Formatted visit time in HST */
		max(a.Discharge_Disposition) as Discharge_Disposition,
		convert(varchar(20),max(a.Death_Date_Time),20) as Death_Date_Time,   /*Formatted death time in HST*/
		max(a.Patient_Death_Indicator) as Death_Indicator
		
	from
		HI_ST_Processed a left join HI_MFT b on a.C_Biosense_Facility_ID=b.C_Biosense_Facility_ID
	where a.C_Visit_Date >= '2025-07-11' /*and a.C_Visit_Date <= '2025-07-31'*/  /* optional end date*/
	and a.Feed_Name like 'HI_Kuakini'
	group by
		a.Visit_ID,
		a.First_Patient_ID
	/*having count(a.Death_Date_Time)=0*/   /*optional - to filter ones with no death date time*/
	/*order by CAST(a.First_Patient_ID as int)*/
	order by a.First_Patient_ID
"))


# Set na='' to replace NA values with blank
write.csv(table1, file = "R_code/rpt/death_date_time_indicator.csv",row.names=FALSE,na='')

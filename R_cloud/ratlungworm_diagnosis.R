#  Copyright (c) 2025. Sandeep Chintabathina

# Code to search for Diagnosis code B832 which is the primary diagnosis code for rat lungworm disease.

library(DBI)
library(odbc)

datamart <- dbConnect(odbc::odbc(),dsn= "BioSense_Platform")

table1 <- dbGetQuery(datamart, paste0("

select 	max(b.Facility_Name) as Facility_Name,
		a.Visit_ID as Visit_ID,
		a.First_Patient_ID as Patient_MRN,
		/* Convert first 20 chars from hst datetime object into the yyyy-mm-dd hh:mi:ss format (numbered 20) */
		convert(varchar(20),max(C_Visit_Date_Time),20) as Visit_Date_Time,
		
		max(a.Diagnosis_Code) as Diagnosis_Code,
		max(a.Diagnosis_Description) as Diagnosis_Description,
		max(a.Chief_Complaint_Text) as Chief_Complaint_Text,
		max(a.C_Chief_Complaint) as Calculated_Chief_Complaint,
		max(Admit_Reason_Description) as Admit_Reason_Description
		
	from
		HI_PR_Processed a left join HI_MFT b on a.C_Biosense_Facility_ID=b.C_Biosense_Facility_ID
	where  a.C_Visit_Date >= '2023-01-01' 
    and a.Diagnosis_Code like '%B832%' 
	group by 
		a.Visit_ID,
		a.First_Patient_ID
	order by a.First_Patient_ID
"))


# Set na='' to replace NA values with blank
write.csv(table1, file = "R_code/rpt/ratlungworm_diagnosis_2023_20250718.csv",row.names=FALSE,na='')


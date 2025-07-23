
#  Copyright (c) 2025. Sandeep Chintabathina

# Code to get procedure code related elements

library(DBI)
library(odbc)

datamart <- dbConnect(odbc::odbc(),dsn= "BioSense_Platform")

table1 <- dbGetQuery(datamart, paste0("

    select 	max(b.Facility_Name) as Facility_Name,
    		a.Visit_ID as Visit_ID,
    		a.First_Patient_ID as Patient_MRN,
    		/* Convert first 20 chars from hst datetime object into the yyyy-mm-dd hh:mi:ss format (numbered 20) */
    		convert(varchar(20),max(C_Visit_Date_Time),20) as Visit_Date_Time,
    		max(a.Procedure_Code) as Procedure_Code,
    		max(a.Procedure_Description) as Procedure_Description,
    		max(a.Procedure_Date_Time) as Procedure_Date_Time,
    		string_agg(Message_Control_Id,',') as message_control_id_list
    	from
    		HI_ST_Processed a left join HI_MFT b on a.C_Biosense_Facility_ID=b.C_Biosense_Facility_ID
    	where a.C_Visit_Date >= '2025-07-05' /*and a.Arrived_Date <= '2024-07-20'*/
    	and a.Feed_Name like 'HI_HHSC'
    	group by 
    		a.Visit_ID,
    		a.First_Patient_ID
    order by a.First_Patient_ID
"))


# Set na='' to replace NA values with blank
write.csv(table1, file = "R_code/rpt/procedure_code.csv",row.names=FALSE,na='')

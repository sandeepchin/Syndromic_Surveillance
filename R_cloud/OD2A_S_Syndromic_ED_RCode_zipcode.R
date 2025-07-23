##################################################
#  ******		      *****			  *******		*********#
#  *** ***	   	 *** *** 	   ********		*********#
#  ***   ***	 	***   ***	  ***   			***      #
#  ***   ***		***   ***	  ***		    	***      #
#  ***   ***		***   ***	  ***			    ***      #
#  ***   ***		***   ***	  ********		******	 #
#  ***   ***		***   ***	  *********		******   #
#  ***   ***		***   ***	  		  ***		***      #
#  ***   ***		***   ***			    *** 	***	     #
#  ***   ***		***   ***			    ***		***      #
#  *** ***		   *** ***	   ********		*********#
#  ******		      *****		  ********		*********#
##################################################

##Syndromic Surveillance Data Submission R Code

# Program History: OD2A_S_Syndromic_ED_Rcode.R
# Created by: Herschel Smith IV
# Updated by: Savannah Nooks
# Program updated with zipcodes: OD2A_S_Syndromic_ED_Rcode_zipcode.R
# Updated by: Sandeep Chintabathina
# Date updated: 07/01/2025

##To be used within RStudio/POSIT Workbench via ESSENCE
##Purpose: Pull suspected overdoses, demographic (age/sex/race/ethnicity) & county ED data from Essence syndrome surveillance

##Instructions:
#0. Place Template in correct location (same save as this program).
#1.Ensure all necessary packages are installed and loaded.
#2. Run "Profile" script and input credentials.
#3. Update parameters:
      #startdate
      #enddate
      #Site ID
      #State
#4. Update file locations (data, output template, FIPS lookup table).
#5. Run full code.
#6. Review output file and manually input metadata responses that are not automatically filled by the program (questions 1-3 and 9-10).

########################################################################################
#Necessary Packages

#install.packages("tidyverse")
#install.packages("lubridate")
#install.packages("httr")
#install.packages("MMWRweek")
#install.packages("ggthemes")
#install.packages("padr")
#install.packages("janitor")
#install.packages("stringr")
#install.packages("openxlsx")
#install.packages("Rnssp")

library(tidyverse)
library(MMWRweek)
library(ggthemes)
library(padr)
library(janitor)
library(openxlsx)
library(Rnssp)

#RUN CODE TO PROMPT PROFILE INPUT

#myProfile <- Credentials$new(
#  username = askme("Enter your username: "), #DO NOT EDIT, just run, this generates prompt box where you will enter your username
#  password = askme("Enter your password: ") #DO NOT EDIT, just run, this generates prompt box where you will enter your password
#)

#Saves above profile to "Files":
#save(myProfile, file="~/myProfile.Rda")

##Can be reloaded via:
load("~/myProfile.Rda")

##################################
########## Parameters: ###########
##################################

#Update all dates within the API URLs by changing the date here.
#Use the same format: 2-digit day, 3-character month name, & 4-digit year
startdate <- "01Jun2025" #EDIT ME
enddate <- "30Jun2025" #EDIT ME

#USE Site ID List below to identify the site relevant to jurisdiction.
#ONLY REPLACE NUMERIC
site <- "&site=886" #EDIT ME      (Ex: Arizona = "&site=860")

#Update with jurisdiction abbreviation.
state <- "HI" #EDIT ME             (Ex: Arizona = "AZ")

#SITE ID LIST
#site ids
#858	Alabama                 #860  Arizona
#859	Arkansas                #879	 Colorado-North Central Region (CO_NCR)
#880	Connecticut             #881	 District of Columbia
#882	Delaware                #884	 Florida
#885	Georgia                 #890	 Illinois
#894	Kansas                  #895	 Kentucky
#896  Louisiana               #902	 Maine
#901	Maryland                #905	 Mississippi
#906	Missouri                #907	 Montana
#910  Nebraska
#912	New Jersey              #913	 New Mexico
#914	Nevada                  #915	 New York City & #916	New York
#908	North Carolina          #917	 Ohio
#919	Oregon                  #920	 Pennsylvania
#922	Rhode Island            #923	 South Carolina
#925	Tennessee               #930	 Utah
#931	Virginia                #934	 Washington
#937  West Virginia           #936	 Wisconsin

################################################
######### END PARAMETERS #######################
################################################

#Ensure location of Template file is the same is this program.
getwd()

#NO EDITS NEEDED BEYOND THIS POINT

#load blank Template workbook for R script to add Jurisdiction data, County data and Metadata
temp <-
  openxlsx::loadWorkbook("~/R_code/OD2A_S_Monthly_SyS_Template_zip_code.xlsx") #MOST UP-TO-DATE TEMPLATE with zip code tab added

###########################################################################################
###########################################################################################

#Pulls the 3-letter month and 2-digit year, then puts them together (e.g. May21) to be used in our csv filepath
#Pulls 2 components out of startdate given (month & year) & puts them into a vector

#START
parse <-
  stringr::str_match(startdate, "[0-9]{1,2}([A-Z|a-z]{3})[0-9]{2}([0-9]{2})")[, c(2, 3)]
#Combines the 2 components into one element (ex., Dec22)
filedate <- trimws(paste(parse, collapse = ""))

#END
parse <-
  stringr::str_match(enddate, "[0-9]{1,2}([A-Z|a-z]{3})[0-9]{2}([0-9]{2})")[, c(2, 3)]
#Combines the 2 components into one element (ex., Dec22)
fileenddate <- trimws(paste(parse, collapse = ""))


###########################################################################################
###########################################################################################

#Site by Month, Sex, NCHS Age Group, Race, Ethnicity and Drug Overdose Categories
#Data source in ESSENCE is facility location full details

agesexracepull <- function(essenceAPIURL) {
  #Replace enddate, startdate & site in API URL with the dates we want data.
  essenceAPIURL <-
    str_replace(essenceAPIURL, "31Mar2023", enddate) #replaces enddate
  essenceAPIURL <-
    str_replace(essenceAPIURL, "1Dec2022", startdate) #replaces startdate
  essenceAPIURL <-
    str_replace(essenceAPIURL, "&site=879", site) #replaces site filter
  
  
  #FUNCTION FOR RNSSP PULL METHOD
  
  api_data <- myProfile$get_api_data(essenceAPIURL)
  
  result_ASR <- api_data %>%
    dplyr::select(
      site,
      year_month = timeResolution,
      sex,
      ageNCHS,
      Race = crace,
      Ethnicity = cethnicity,
      ccddCategory,
      numerator,
      Total_ED_visits = denominator
    ) %>%
    pivot_wider(names_from = ccddCategory, values_from = numerator) %>%
    relocate(Total_ED_visits, .after = last_col())
  
  return(result_ASR)
}

#New with race ethnicity, ccddcategories Cocaine, Benzo, Fentanyl, Methamphetamine.

#Do not change this URL, parameters and function above will update dates, site, etc. Pulling JSON URL and pivoted wider in function.
asr_result_all <-
  agesexracepull(
    "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder?datasource=va_hosp&startDate=1Dec2022&medicalGroupingSystem=essencesyndromes&userId=3049&endDate=31Mar2023&percentParam=ccddCategory&site=879&aqtTarget=TableBuilder&ccddCategory=cdc%20all%20drug%20overdose%20v3%20parsed&ccddCategory=cdc%20heroin%20overdose%20v5%20parsed&ccddCategory=cdc%20opioid%20overdose%20v4%20parsed&ccddCategory=cdc%20methamphetamine%20overdose%20v1%20parsed&ccddCategory=cdc%20stimulant%20overdose%20v4%20parsed&ccddCategory=cdc%20fentanyl%20overdose%20v2%20parsed&ccddCategory=cdc%20cocaine%20overdose%20v2%20parsed&ccddCategory=cdc%20benzodiazepine%20overdose%20v2%20parsed&geographySystem=hospital&detector=nodetectordetector&timeResolution=monthly&hasBeenE=1&rowFields=site&rowFields=timeResolution&rowFields=sex&rowFields=ageNCHS&rowFields=crace&rowFields=cethnicity&columnField=ccddCategory"
  ) 
#UPDATED with METH v1 Parsed (COMPLETE)
#MUST UPDATE ALL DRUG to v3 Parsed (COMPLETE ~SN)
#UPDATED HEROIN to v5 Parsed (COMPLETE)
#UPDATED OPIOID TO v4 Parsed (COMPLETE)
#MUST UPDATE STIMULANT to v4 Parsed (COMPLETE ~SN)
#UPDATED BENZO to v2 Parsed (COMPLETE)
#MUST UPDATE COCAINE to v2 Parsed (COMPLETE ~SN)
#UPDATE FENTANYL to v2 Parsed (COMPLETE)
#json URL
########################################
#Code to change jurisdiction to state abbreviation
# What is state?
# state.name gives a list of all states
# match(A,B) gives an index when A matches B; for e.g. match("Hawaii",state.name)=11
# state.abb[index] gives the abbrev for the state
asr_result_all$site <- state.abb[match(asr_result_all$site,state.name)]

########################################
#Code to clean age variable observations
# If unknown replace with missing
asr_result_all$ageNCHS[asr_result_all$ageNCHS == "Unknown"] <-
  "Missing"


########################################
########################################
#Code to clean sex variable observations

resultM_F <- asr_result_all %>% filter(sex %in% c("Male", "Female"))

#Combine not reported & unknown sex into 1 category of "missing"
resultmissing <- asr_result_all %>%
  filter(sex %in% c("Not Reported", "Unknown")) %>%
  group_by(site, year_month, ageNCHS, Race, Ethnicity) %>% summarise_at(
    c(
      "CDC All Drug Overdose v3 Parsed",
      "CDC Benzodiazepine Overdose v2 Parsed",
      "CDC Cocaine Overdose v2 Parsed",
      "CDC Fentanyl Overdose v2 Parsed",
      "CDC Heroin Overdose v5 Parsed",
      "CDC Opioid Overdose v4 Parsed",
      "CDC Methamphetamine Overdose v1 Parsed",
      "CDC Stimulant Overdose v4 Parsed",
      "Total_ED_visits"
    ), #ALL WILL NEED UPDATE FOR NEWEST SYNDROME VERSIONS!!! (COMPLETE ~SN)
    sum
  ) %>% mutate(sex = "Missing")


#bind back together
result_sex <- bind_rows(resultM_F, resultmissing)

#removing objects. Cleaning environment
rm(resultmissing, resultM_F)

######################################
######################################

#Code to clean race variable observations

result_races <-
  result_sex %>% filter(
    Race %in% c(
      "American Indian or Alaska Native",
      "Asian",
      "Black or African American",
      "Multiracial",
      "Native Hawaiian or Other Pacific Islander",
      "Other Race",
      "White"
    )
  )

#Combine not reported, not categorized, refused, unknown race into 1 category of "missing"
resultmissing <- result_sex %>%
  filter(Race %in% c(
    "Not Categorized",
    "Not Reported or Null",
    "Refused to answer",
    "Unknown"
  )) %>%
  group_by(site, year_month, sex, ageNCHS, Ethnicity) %>% summarise_at(
    c(
      "CDC All Drug Overdose v3 Parsed",
      "CDC Benzodiazepine Overdose v2 Parsed",
      "CDC Cocaine Overdose v2 Parsed",
      "CDC Fentanyl Overdose v2 Parsed",
      "CDC Heroin Overdose v5 Parsed",
      "CDC Opioid Overdose v4 Parsed",
      "CDC Methamphetamine Overdose v1 Parsed",
      "CDC Stimulant Overdose v4 Parsed",
      "Total_ED_visits"
    ),#ALL WILL NEED UPDATE FOR NEWEST SYNDROME VERSIONS!!! (COMPLETE ~SN)
    sum
  ) %>% mutate(Race = "Unknown or Missing")


result_ageSexrace <- bind_rows(result_races, resultmissing)
#removing objects. Cleaning environment
rm(resultmissing, result_races)

######################################
######################################

#Code to clean ethnicity variable observations

result_ethnicity <-
  result_ageSexrace %>% filter(Ethnicity %in% c("Hispanic or Latino", "Not Hispanic or Latino"))

#Combine not reported, not categorized, refused, unknown ethnicity into 1 category of "missing"
resultmissing <- result_ageSexrace %>%
  filter(
    Ethnicity %in% c(
      "Not Categorized",
      "Not Reported or Null",
      "Refused to answer",
      "Unknown"
    )
  ) %>%
  group_by(site, year_month, sex, ageNCHS, Race) %>% summarise_at(
    c(
      "CDC All Drug Overdose v3 Parsed",
      "CDC Benzodiazepine Overdose v2 Parsed",
      "CDC Cocaine Overdose v2 Parsed",
      "CDC Fentanyl Overdose v2 Parsed",
      "CDC Heroin Overdose v5 Parsed",
      "CDC Opioid Overdose v4 Parsed",
      "CDC Methamphetamine Overdose v1 Parsed",
      "CDC Stimulant Overdose v4 Parsed",
      "Total_ED_visits"
    ),#ALL WILL NEED UPDATE FOR NEWEST SYNDROME VERSIONS!!! (COMPLETE ~SN)
    sum
  ) %>% mutate(Ethnicity = "Unknown or Missing")


#bind
result_ageSexrace <- bind_rows(result_ethnicity, resultmissing)

#removing objects. Cleaning environment
rm(resultmissing, result_ethnicity)

#separate date variables
result_ageSexrace <-
  result_ageSexrace %>% separate(year_month, c("Year", "Month"))

######################################
######################################
######################################
######################################

#Add the totals outputs by demos.

#########################

sex_totals <- result_ageSexrace %>%
  group_by(site, Year, Month, sex) %>%
  dplyr::summarise(across(
    c(
      "CDC All Drug Overdose v3 Parsed",
      "CDC Benzodiazepine Overdose v2 Parsed",
      "CDC Cocaine Overdose v2 Parsed",
      "CDC Fentanyl Overdose v2 Parsed",
      "CDC Heroin Overdose v5 Parsed",
      "CDC Opioid Overdose v4 Parsed",
      "CDC Methamphetamine Overdose v1 Parsed",
      "CDC Stimulant Overdose v4 Parsed",
      "Total_ED_visits"
    ),#ALL WILL NEED UPDATE FOR NEWEST SYNDROME VERSIONS!!! (COMPLETE ~SN)
    sum
  )) %>%
  mutate(ageNCHS = "Total",
         Race = "Total",
         Ethnicity = "Total")

age_totals <- result_ageSexrace %>%
  group_by(site, Year, Month, ageNCHS) %>%
  dplyr::summarise(across(
    c(
      "CDC All Drug Overdose v3 Parsed",
      "CDC Benzodiazepine Overdose v2 Parsed",
      "CDC Cocaine Overdose v2 Parsed",
      "CDC Fentanyl Overdose v2 Parsed",
      "CDC Heroin Overdose v5 Parsed",
      "CDC Opioid Overdose v4 Parsed",
      "CDC Methamphetamine Overdose v1 Parsed",
      "CDC Stimulant Overdose v4 Parsed",
      "Total_ED_visits"
    ),#ALL WILL NEED UPDATE FOR NEWEST SYNDROME VERSIONS!!! (COMPLETE ~SN)
    sum
  )) %>%
  mutate(sex = "Total",
         Race = "Total",
         Ethnicity = "Total")

reth_totals <- result_ageSexrace %>%
  group_by(site, Year, Month, Race, Ethnicity) %>%
  dplyr::summarise(across(
    c(
      "CDC All Drug Overdose v3 Parsed",
      "CDC Benzodiazepine Overdose v2 Parsed",
      "CDC Cocaine Overdose v2 Parsed",
      "CDC Fentanyl Overdose v2 Parsed",
      "CDC Heroin Overdose v5 Parsed",
      "CDC Opioid Overdose v4 Parsed",
      "CDC Methamphetamine Overdose v1 Parsed",
      "CDC Stimulant Overdose v4 Parsed",
      "Total_ED_visits"
    ),#ALL WILL NEED UPDATE FOR NEWEST SYNDROME VERSIONS!!! (COMPLETE ~SN)
    sum
  )) %>%
  mutate(ageNCHS = "Total",
         sex = "Total",)

#BIND BACK TO result_ageSexrace
result_ageSexrace <-
  bind_rows(sex_totals, age_totals, reth_totals, result_ageSexrace)

#Line it all up
result_final_jurisdiction <- result_ageSexrace %>%
  dplyr::select(
    Jurisdiction = site,
    Year,
    Month,
    Sex = sex,
    Age_Group = ageNCHS,
    Race,
    Ethnicity,
    'Suspected_drug_OD_n' = 'CDC All Drug Overdose v3 Parsed',
    'Suspected_opioid_OD_n' = 'CDC Opioid Overdose v4 Parsed',
    'Suspected_heroin_OD_n' = 'CDC Heroin Overdose v5 Parsed',
    'Suspected_Fentanyl_OD_n' = 'CDC Fentanyl Overdose v2 Parsed',
    'Suspected_stimulant_OD_n' = 'CDC Stimulant Overdose v4 Parsed',
    'Suspected_Cocaine_OD_n' = 'CDC Cocaine Overdose v2 Parsed',
    'Suspected_Methamphetamine_OD_n'= "CDC Methamphetamine Overdose v1 Parsed",
    'Suspected_Benzo_OD_n' = 'CDC Benzodiazepine Overdose v2 Parsed', #ALL WILL NEED UPDATE FOR NEWEST SYNDROME VERSIONS!!! (COMPLETE ~SN)
    'Total_ED_visits'
  ) %>%
  mutate(
    Month = month.name[as.numeric(Month)]
  ) %>%
  #mutate(Suspected_Methamphetamine_OD_n = 0,
  #       .after = Suspected_Cocaine_OD_n) %>% #METH PLACEHOLDER COLUMN
  mutate_at(
    c(
      'Suspected_drug_OD_n',
      'Suspected_opioid_OD_n',
      'Suspected_heroin_OD_n',
      'Suspected_Fentanyl_OD_n',
      'Suspected_stimulant_OD_n',
      'Suspected_Cocaine_OD_n',
      'Suspected_Methamphetamine_OD_n',
      'Suspected_Benzo_OD_n',
      'Total_ED_visits'
    ),
    ~ na_if(., 0)  # Apply na_if() to the columns. If any value is 0, it is replaced by NA
  )


#End Jurisdiction Tab


###########################################################################################
###########################################################################################
#County Tab Script
###########################################################################################
###########################################################################################

#Site by County (Patient Location FIPS approximation in ESSENCE) of Residence and Drug Overdose Categories
#Data source in ESSENCE is facility location full details

####FUNCTION FOR PULLING STATE'S COUNTY DATA.

countypull <- function(site, state) {
  #Creates url for FIPS related to specific state from Rnssp FIPS listings
  ex_tab <- county_sf %>% #US Counties Shapefile in Rnssp
    as.data.frame() %>%
    dplyr::select(
      state_fips = STATEFP,
      county_fips = GEOID,
      county_name = NAME
    ) %>%
    left_join(state_sf, by = c("state_fips" = "STATEFP")) %>%
    as.data.frame() %>%
    dplyr::select(
      state_abbr = STUSPS,
      state_name = NAME,
      state_fips,
      county_fips,
      county_name
    )
  #fips data for ESSENCE urls
  fips_for_url <- ex_tab %>%
    filter(state_abbr == state) %>%
    pull(county_fips) %>%
    paste0(., collapse = "&fips=")
  
  print(fips_for_url)
  
  #build the state_url, then throw it in the function (json url)
  prefix <-
    "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder?endDate=" #then enddate.
  #enddate passed in function, defined at top of code
  
  #Will need to add METH TO THIS URL!!!!!!!!!!!! (COMPLETE)
  middle <-
    "&ccddCategory=cdc%20all%20drug%20overdose%20v3%20parsed&ccddCategory=cdc%20heroin%20overdose%20v5%20parsed&ccddCategory=cdc%20opioid%20overdose%20v4%20parsed&ccddCategory=cdc%20methamphetamine%20overdose%20v1%20parsed&ccddCategory=cdc%20stimulant%20overdose%20v4%20parsed&ccddCategory=cdc%20fentanyl%20overdose%20v2%20parsed&ccddCategory=cdc%20cocaine%20overdose%20v2%20parsed&ccddCategory=cdc%20benzodiazepine%20overdose%20v2%20parsed&percentParam=ccddCategory&geographySystem=hospital&datasource=va_hosp&detector=nodetectordetector&startDate="
  #time resolution indicated in url
  countylead <- "&timeResolution=monthly"
  #end of county url informing other query options (i.e., "Has Been Emergency", "Medical Grouping", etc.)
  countyend <-
    "&hasBeenE=1&medicalGroupingSystem=essencesyndromes&userId=455"
  #suffix for Table Builder fields
  suffix <-
    "&aqtTarget=TableBuilder&rowFields=site&rowFields=fips&rowFields=timeResolution&columnField=ccddCategory"
  #Putting it all together
  state_url <-
    paste0(
      prefix,
      enddate ,
      "&fips=",
      fips_for_url,
      middle,
      startdate,
      countylead,
      countyend,
      site,
      suffix
    )
  
  print(state_url)
  
  #RNSSP FUNCTION
  api_response <- myProfile$get_api_data(state_url)
  
  state_result <- api_response %>%
    dplyr::select(
      Jurisdiction = site,
      year_month = timeResolution,
      County_name = fips,
      State_County_FIPS = `fips raw`,
      ccddCategory,
      numerator,
      Total_ED_visits = denominator
    ) %>%
    pivot_wider(names_from = ccddCategory, values_from = numerator)  %>%
    separate(year_month, c("Year", "Month")) %>%
    dplyr::select(
      Jurisdiction,
      County_name,
      State_County_FIPS,
      Year,
      Month,
      Suspected_drug_OD_n = 'CDC All Drug Overdose v3 Parsed',
      Suspected_opioid_OD_n = 'CDC Opioid Overdose v4 Parsed',
      Suspected_heroin_OD_n = 'CDC Heroin Overdose v5 Parsed',
      Suspected_Fentanyl_OD_n = 'CDC Fentanyl Overdose v2 Parsed',
      Suspected_stimulant_OD_n = 'CDC Stimulant Overdose v4 Parsed',
      Suspected_Cocaine_OD_n = 'CDC Cocaine Overdose v2 Parsed',
      Suspected_Methamphetamine_OD_n ='CDC Methamphetamine Overdose v1 Parsed',
      Suspected_Benzo_OD_n = 'CDC Benzodiazepine Overdose v2 Parsed',
      Total_ED_visits #ALL WILL NEED UPDATE FOR NEWEST SYNDROME VERSIONS!!!
    )
  
  return(state_result)
}

#Execute New Function above
result_site_county <- countypull(site = site, state = state) %>%
  mutate(
    Month = month.name[as.numeric(Month)]
  ) %>%
  mutate(County_name = substring(County_name, "6")) %>%
  #mutate(Suspected_Methamphetamine_OD_n = 0,
  #       .after = Suspected_Cocaine_OD_n) %>% #METH PLACEHOLDER COLUMN
  mutate_at(
    c(
      'Suspected_drug_OD_n',
      'Suspected_opioid_OD_n',
      'Suspected_heroin_OD_n',
      'Suspected_Fentanyl_OD_n',
      'Suspected_stimulant_OD_n',
      'Suspected_Cocaine_OD_n',
      'Suspected_Methamphetamine_OD_n',
      'Suspected_Benzo_OD_n',
      'Total_ED_visits'
    ),
    ~ na_if(., 0)
  )
########################################
#Code to change jurisdiction to state abbreviation
result_site_county$Jurisdiction <- state.abb[match(result_site_county$Jurisdiction,state.name)]

###############
#END County Tab
###############

###########################################################################
# NEW: ZIP CODE script
###########################################################################
# Read Hawaii Zip and County mapping file
zip_county_df <- read.csv("zip_county_mapping.csv")
# drop City column
zip_county_df <- subset(zip_county_df,select=-City)
# Rename column
names(zip_county_df)[names(zip_county_df) == 'Zip.Code'] <- 'Zip_Code'
# Remove duplicate rows
zip_county_df<-zip_county_df[!duplicated(zip_county_df), ]

#print(colnames(zip_county_df))
#print(nrow(zip_county_df))
#print(zip_county_df$Zip_Code)

#Put all the zip codes together with &geography= connector. For e.g. &geography=96817 
zips_for_url <- zip_county_df %>%
  pull(Zip_Code) %>%
  paste0(., collapse = "&geography=")

#print(zips_for_url)

#build the state_url, then throw it in the function (json url)
prefix <-
  "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder?endDate=" #then enddate.
#enddate passed in function, defined at top of code

#Altered datasource from va_hosp to va_er
middle <-
  "&ccddCategory=cdc%20all%20drug%20overdose%20v3%20parsed&ccddCategory=cdc%20heroin%20overdose%20v5%20parsed&ccddCategory=cdc%20opioid%20overdose%20v4%20parsed&ccddCategory=cdc%20methamphetamine%20overdose%20v1%20parsed&ccddCategory=cdc%20stimulant%20overdose%20v4%20parsed&ccddCategory=cdc%20fentanyl%20overdose%20v2%20parsed&ccddCategory=cdc%20cocaine%20overdose%20v2%20parsed&ccddCategory=cdc%20benzodiazepine%20overdose%20v2%20parsed&percentParam=ccddCategory&datasource=va_er&detector=nodetectordetector&startDate="

#time resolution indicated in url
countylead <- "&timeResolution=monthly"
#end of county url informing other query options (i.e., "Has Been Emergency", "Medical Grouping", etc.)
countyend <-
  "&hasBeenE=1&medicalGroupingSystem=essencesyndromes&userId=455"
#suffix for Table Builder fields
# Adding geographySystem variable and geographyzipcodelist row fields
suffix <-
  "&aqtTarget=TableBuilder&geographySystem=zipcodelist&rowFields=geographyzipcodelist&rowFields=timeResolution&columnField=ccddCategory"
#Putting it all together
state_url <-
  paste0(
    prefix,
    enddate ,
    "&geography=",
    zips_for_url,
    middle,
    startdate,
    countylead,
    countyend,
    site,
    suffix
  )

#print(state_url)

#RNSSP FUNCTION
api_response <- myProfile$get_api_data(state_url)

#print(colnames(api_response))

#print(api_response$geographyzipcodelist)

state_result <- api_response %>%
  dplyr::select(
    #Jurisdiction = site,
    year_month = timeResolution,
    #County_name = fips,
    #State_County_FIPS = `fips raw`,
    Zip_Code = geographyzipcodelist,
    ccddCategory,
    #count,
    numerator,
    Total_ED_visits = denominator
  ) %>%
  pivot_wider(names_from = ccddCategory, values_from = numerator)  %>%
  separate(year_month, c("Year", "Month")) %>%
  dplyr::select(
    # Jurisdiction,
    # County_name,
    # State_County_FIPS,
    Year,
    Month,
    Zip_Code,
    #count,
    Suspected_drug_OD_n = 'CDC All Drug Overdose v3 Parsed',
    Suspected_opioid_OD_n = 'CDC Opioid Overdose v4 Parsed',
    Suspected_heroin_OD_n = 'CDC Heroin Overdose v5 Parsed',
    Suspected_Fentanyl_OD_n = 'CDC Fentanyl Overdose v2 Parsed',
    Suspected_stimulant_OD_n = 'CDC Stimulant Overdose v4 Parsed',
    Suspected_Cocaine_OD_n = 'CDC Cocaine Overdose v2 Parsed',
    Suspected_Methamphetamine_OD_n ='CDC Methamphetamine Overdose v1 Parsed',
    Suspected_Benzo_OD_n = 'CDC Benzodiazepine Overdose v2 Parsed',
    Total_ED_visits #ALL WILL NEED UPDATE FOR NEWEST SYNDROME VERSIONS!!!
  )

#print(colnames(state_result))
#print(state_result)

# Convert numeric month to name
# Replace 0s with NA
result_site_zip <- state_result %>%
  mutate(
    Month = month.name[as.numeric(Month)]
  ) %>%
  #mutate(County_name = substring(County_name, "6")) %>%
  #mutate(Suspected_Methamphetamine_OD_n = 0,
  #       .after = Suspected_Cocaine_OD_n) %>% #METH PLACEHOLDER COLUMN
  mutate_at(
    c(
      'Suspected_drug_OD_n',
      'Suspected_opioid_OD_n',
      'Suspected_heroin_OD_n',
      'Suspected_Fentanyl_OD_n',
      'Suspected_stimulant_OD_n',
      'Suspected_Cocaine_OD_n',
      'Suspected_Methamphetamine_OD_n',
      'Suspected_Benzo_OD_n',
      'Total_ED_visits'
    ),
    ~ na_if(.,0)
  )

#print(result_site_zip)

# merge with zip_county_df to get the county name
result_zip_county <- merge(x = result_site_zip, y = zip_county_df, by = "Zip_Code", all.x = TRUE)

# Rename county column
names(result_zip_county)[names(result_zip_county) == 'County'] <- 'County_name'

# Add State_County_FIPS column
result_zip_county$State_County_FIPS[result_zip_county$County_name=='Hawaii County'] <- "15001"
result_zip_county$State_County_FIPS[result_zip_county$County_name=='Honolulu County'] <- "15003"
result_zip_county$State_County_FIPS[result_zip_county$County_name=='Kalawao County'] <- "15005"
result_zip_county$State_County_FIPS[result_zip_county$County_name=='Kauai County'] <- "15007"
result_zip_county$State_County_FIPS[result_zip_county$County_name=='Maui County'] <- "15009"

#Add Jurisdiction column
result_zip_county$Jurisdiction <- state

# Rearranging columns
result_zip_county <- result_zip_county[,c('Jurisdiction','County_name','State_County_FIPS','Zip_Code','Year','Month','Suspected_drug_OD_n','Suspected_opioid_OD_n','Suspected_heroin_OD_n', 'Suspected_Fentanyl_OD_n', 'Suspected_stimulant_OD_n', 'Suspected_Cocaine_OD_n','Suspected_Methamphetamine_OD_n','Suspected_Benzo_OD_n','Total_ED_visits')]


#print(result_zip_county)
############################################################################################
# END of NEW ZIP CODE script
############################################################################################
# Metadata Script
##############

#METADATA FUNCTION

metadata_pull <- function(essenceAPIURL) {
  #Replace enddate, startdate & site in API URL with the dates we want data.
  essenceAPIURL <-
    str_replace(essenceAPIURL, "31Mar2023", enddate) #replaces enddate
  essenceAPIURL <-
    str_replace(essenceAPIURL, "1Dec2022", startdate) #replaces startdate
  essenceAPIURL <-
    str_replace(essenceAPIURL, "&site=879", site) #replaces site filter
  
  #FUNCTION FOR RNSSP PULL METHOD
  
  api_meta_data <- myProfile$get_api_data(essenceAPIURL)
  metadata <- api_meta_data$dataDetails
  
  return(metadata)
}

#Do not change this URL, parameters and function above will update dates, site, etc. Pulling JSON URL
metadata <-
  metadata_pull(
    "https://essence.syndromicsurveillance.org/nssp_essence/api/dataDetails?datasource=va_hosp&startDate=1Dec2022&medicalGroupingSystem=essencesyndromes&userId=3049&endDate=31Mar2023&percentParam=noPercent&site=879&aqtTarget=DataDetails&geographySystem=hospital&hasBeenE=1&detector=nodetectordetector&timeResolution=monthly"
  )

result_metadata <- metadata %>%
  dplyr::select(
    ChiefComplaintOrig,
    ChiefComplaintParsed,
    DischargeDiagnosis,
    DDParsed,
    HospitalName
  ) %>%
  mutate(
    word_count = sapply(strsplit(ChiefComplaintParsed, " "), length),
    dx_code_count = sapply(strsplit(DischargeDiagnosis, ".;"), length)
  )

#facility_count <- length(unique(metadata$HospitalName))

#Metadata questions:

#4. Report the percent of all ED visits in this data submission missing chief complaint data. (Enter a percentage such as "10%")

meta_no_cc = round((sum(result_metadata$word_count == 0) / nrow(result_metadata)) *
                     100, 0)

meta_no_cc <- paste0(meta_no_cc, "%")

print(meta_no_cc)

writeData(temp,
          "Metadata_MonthlyED",
          meta_no_cc,
          startRow = 21,
          startCol = 2)


#5. Report the median number of words from chief complaint data. (Enter a number such as "5")

meta_median_cc = (median(result_metadata$word_count))
print(meta_median_cc)

writeData(
  temp,
  "Metadata_MonthlyED",
  meta_median_cc,
  startRow = 25,
  startCol = 2
)


#6. Report the percent of all ED visits in this data submission that have no discharge diagnosis codes (e.g., ICD-10-CM) entered for a single ED visit in this data submission? (Enter a percentage such as "15%")

meta_no_dx = round((
  sum(result_metadata$dx_code_count == 0) / nrow(result_metadata)
) * 100, 0)

meta_no_dx <- paste0(meta_no_dx, "%")
  
print(meta_no_dx)

writeData(temp,
          "Metadata_MonthlyED",
          meta_no_dx,
          startRow = 29,
          startCol = 2)

#7. What was the maximum number of discharge diagnosis codes (e.g., ICD-10-CM) entered for a single ED visit in this data submssion? (Enter a number such as "10")

meta_max_dx = (max(result_metadata$dx_code_count))
print(meta_max_dx)

writeData(temp,
          "Metadata_MonthlyED",
          meta_max_dx,
          startRow = 33,
          startCol = 2)

#8. What was the mean number of discharge diagnosis codes (e.g., ICD-10-CM) that were entered for all ED visits in this data submission? (Enter a number such as "8")

meta_mean_dx = round(mean(result_metadata$dx_code_count), 0)
print(meta_mean_dx)

writeData(temp,
          "Metadata_MonthlyED",
          meta_mean_dx,
          startRow = 37,
          startCol = 2)


##############
#End metadata script
##############


##############
#Output Script
##############
#Jurisdiction tab
writeData(
  temp,
  "Jurisdiction_Rpt_MonthlyED",
  result_final_jurisdiction,
  startRow = 3,
  startCol = 1,
  colNames = TRUE
)

#County tab
writeData(
  temp,
  "County_Rpt_MonthlyED",
  result_site_county,
  startRow = 2,
  startCol = 1,
  colNames = TRUE
)

#Zip code tab
writeData(
  temp,
  "Zip_Code_Rpt_MonthlyED",
  result_zip_county,
  startRow = 2,
  startCol = 1,
  colNames = TRUE
)

#Identify workbook by state and save in Output folder
target.dir <- paste0(getwd(), "Output/")#labels output folder
dir.create(target.dir) #Creates folder for outputs
if (dir.exists(target.dir)) {
  unlink(paste0(target.dir, "*"))
}

openxlsx::saveWorkbook(
  temp,
  file = paste0(
    target.dir,
    state,
    "_OD2A_Data Submission_Monthly_ED_SyS_",
    startdate,
    "-",
    enddate,
    ".xlsx"
  ),
  overwrite = T
)

#DOWNLOAD THE WORKBOOK FROM YOUR NEW OUTPUT FOLDER!

#DONT FORGET TO INPUT METADATA FIGURES !!!!!!!!!!!!!
#DONT FORGET TO INPUT METADATA FIGURES !!!!!!!!!!!!!
#DONT FORGET TO INPUT METADATA FIGURES !!!!!!!!!!!!!
#DONT FORGET TO INPUT METADATA FIGURES !!!!!!!!!!!!!
#DONT FORGET TO INPUT METADATA FIGURES !!!!!!!!!!!!!


################################

#END FULL CODE

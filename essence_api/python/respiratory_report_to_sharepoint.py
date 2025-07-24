#  Copyright (c) 2025. Sandeep Chintabathina

# Code to pull Respiratory Illness related visits and hospitalizations using Essence API in Python
# Code will also upload data to a sharepoint location

# When running for the first time or when password changes, you will need to run set_keyring first. 
# Otherwise no password or old password will be passed to this file.

# Install required libaries in whatever system this code is run
# pip install Office365-REST-Python-Client
# pip install pynssp

# Update set_keyring.py with latest doh password
# Update essence_credentials.py with latest Essence password


# Sharpoint access libraries
from office365.runtime.auth.user_credential import UserCredential
from office365.sharepoint.client_context import ClientContext
import keyring
import io

# pynssp and other libraries
from pynssp import *
from datetime import date, timedelta
import pandas as pd
from essence_credentials import get_profile
import openpyxl


def direct_upload_to_sharepoint_as_df(df, filename, target_url, CTX):
    writer_obj = io.BytesIO()
    df.to_excel(writer_obj, index=False,sheet_name='Data Table')
    writer_obj.seek(0)
    target_folder = CTX.web.get_folder_by_server_relative_url(target_url)
    #print('Target folder',target_folder)
    target_file = target_folder.upload_file(filename, writer_obj)
    CTX.execute_query()
    print(filename, "has been uploaded to url:", target_file.serverRelativeUrl)


# To access the sharepoint
username = "s.chintabathina@doh.hawaii.gov"
password = keyring.get_password('DOH',username)

# ONLY THE SITE URL no sub folders 
# ANY OTHER SUB FOLDER should be listed in target url
site_url = "https://hawaiioimt.sharepoint.com/teams/DOHDataVisualizationHub/"

CTX = ClientContext(site_url).with_credentials(UserCredential(username, password))

print(CTX)

# Uses stored username, password in get_profile function - This is for Essence
myProfile = get_profile()

## Update Start and End dates in NSSP-ESSENCE API URL
# Get difference in dates between 22Jul24 and 12Apr22 (initially used dates)
d0 = date(2022, 4, 12)
d1 = date(2024, 7, 22)
delta = d1 - d0
print('Num of days:',delta.days)

startDate = date.today() - timedelta(days=delta.days)
endDate = date.today()

# Total Admits by Age from Respiratory Virus Dashboard Hawaii
# This will be pulled using a tablebuilder API
url= "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?percentParam=noPercent&medicalGroupingSystem=essencesyndromes&dateconfig=15&userId=6736&ageGroup2=00-17&ageGroup2=18-25&ageGroup2=26-54&ageGroup2=55-64&ageGroup2=65-74&ageGroup2=75-1000&geographySystem=state&geography=hi&datasource=va_er&timeResolution=weekly&aqtTarget=TableBuilder&detector=nodetectordetector&fieldIDs=timeResolution&fieldIDs=ageGroup2&fieldLabels=Week&fieldLabels=Age%20Group%202&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393890&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=ageGroup2"


url = change_dates(url, start_date = startDate, end_date = endDate)

## Pull table Data from NSSP-ESSENCE
api_data = get_api_data(url, profile=myProfile,fromCSV=True)

## Inspect data object structure
print(api_data.columns)
# Rename timeResolution column to Week
api_data = api_data.rename(columns={'timeResolution':'Week'})
print(api_data.columns)
for col in api_data.columns:
    if col!='Week':
        api_data[col] = api_data[col].astype(int)

## Extract table of interest
#api_data = pd.json_normalize(api_data["regionSyndromeAlerts"][0])

## Get a glimpse of the pulled dataset
print(api_data.head())

direct_upload_to_sharepoint_as_df(api_data, 'Total admitted by age.xlsx', 'DW/Resp Illness Dashboard/Syndromic/Hospitalization Data', CTX)

#####################################################################################################
# Total admitted by Facility from Respiratory Virus Dashboard Hawaii
# This will be pulled using a tablebuilder API
url= "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?percentParam=noPercent&medicalGroupingSystem=essencesyndromes&dateconfig=15&userId=6736&geographySystem=state&geography=hi&datasource=va_er&timeResolution=weekly&erFacility=34195&erFacility=34931&erFacility=35506&erFacility=34846&erFacility=33880&erFacility=33881&erFacility=34553&erFacility=34845&erFacility=34702&erFacility=34701&erFacility=34844&erFacility=33907&erFacility=34826&erFacility=34847&aqtTarget=TableBuilder&detector=nodetectordetector&fieldIDs=timeResolution&fieldIDs=erFacility&fieldLabels=Week&fieldLabels=Facility&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393891&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=erFacility"

url = change_dates(url, start_date = startDate, end_date = endDate)

api_data = get_api_data(url, profile=myProfile,fromCSV=True)
# Rename timeResolution column to Week
api_data = api_data.rename(columns={'timeResolution':'Week'})

for col in api_data.columns:
    if col!='Week':
        api_data[col] = api_data[col].astype(int)

direct_upload_to_sharepoint_as_df(api_data,'Total admitted by facility.xlsx','DW/Resp Illness Dashboard/Syndromic/Hospitalization Data', CTX)

###################################################################################################
# ILI count by facility from Respiratory Virus Dashboard Hawaii
url = "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?percentParam=noPercent&medicalGroupingSystem=essencesyndromes&dateconfig=15&userId=6736&geographySystem=state&ccddCategory=ili%20ccdd%20v1&geography=hi&datasource=va_er&timeResolution=weekly&erFacility=34195&erFacility=34931&erFacility=35506&erFacility=34846&erFacility=33880&erFacility=33881&erFacility=34553&erFacility=34845&erFacility=34702&erFacility=34701&erFacility=34844&erFacility=33907&erFacility=34826&erFacility=34847&aqtTarget=TableBuilder&detector=nodetectordetector&fieldIDs=timeResolution&fieldIDs=erFacility&fieldLabels=Week&fieldLabels=Facility&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393892&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=erFacility"

url = change_dates(url, start_date = startDate, end_date = endDate)

api_data = get_api_data(url, profile=myProfile,fromCSV=True)
# Rename timeResolution column to Week
api_data = api_data.rename(columns={'timeResolution':'Week'})

for col in api_data.columns:
    if col!='Week':
        api_data[col] = api_data[col].astype(int)

direct_upload_to_sharepoint_as_df(api_data,'ILI count by facility.xlsx','DW/Resp Illness Dashboard/Syndromic/Hospitalization Data', CTX)

###################################################################################################
# ILI count by age from Respiratory Virus Dashboard Hawaii

url = "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?percentParam=noPercent&medicalGroupingSystem=essencesyndromes&dateconfig=15&userId=6736&ageGroup2=00-17&ageGroup2=18-25&ageGroup2=26-54&ageGroup2=55-64&ageGroup2=65-74&ageGroup2=75-1000&geographySystem=state&ccddCategory=ili%20ccdd%20v1&geography=hi&datasource=va_er&timeResolution=weekly&aqtTarget=TableBuilder&detector=nodetectordetector&fieldIDs=timeResolution&fieldIDs=ageGroup2&fieldLabels=Week&fieldLabels=Age%20Group%202&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393893&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=ageGroup2"

url = change_dates(url, start_date = startDate, end_date = endDate)

api_data = get_api_data(url, profile=myProfile,fromCSV=True)

print(api_data.columns)
# Rename timeResolution column to Date and others
api_data = api_data.rename(columns={'timeResolution':'Week'})


for col in api_data.columns:
    if col!='Week':
        api_data[col] = api_data[col].astype(int)

direct_upload_to_sharepoint_as_df(api_data,'ILI count by age.xlsx','DW/Resp Illness Dashboard/Syndromic/Hospitalization Data', CTX)

###################################################################################################
# Total volume of ED visits from State Respiratory Virus Dashboard

url = "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393894&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url = change_dates(url, start_date = startDate, end_date = endDate)

api_data = get_api_data(url, profile=myProfile,fromCSV=True)
# Rename timeResolution column to Week
api_data = api_data.rename(columns={'timeResolution':'Date','No':'Has Been Admitted No','Yes':'Has Been Admitted Yes'})

for col in api_data.columns:
    if col!='Date':
        api_data[col] = api_data[col].astype(int)

## Write to all sub folders except Hospitalization Data
direct_upload_to_sharepoint_as_df(api_data,'Total emergency department visits and hospitalizations.xlsx','DW/Resp Illness Dashboard/Syndromic/Covid', CTX)
direct_upload_to_sharepoint_as_df(api_data,'Total emergency department visits and hospitalizations.xlsx','DW/Resp Illness Dashboard/Syndromic/RSV', CTX)
direct_upload_to_sharepoint_as_df(api_data,'Total emergency department visits and hospitalizations.xlsx','DW/Resp Illness Dashboard/Syndromic/Influenza', CTX)
direct_upload_to_sharepoint_as_df(api_data,'Total emergency department visits and hospitalizations.xlsx','DW/Resp Illness Dashboard/Syndromic/CDC Respiratory Combined', CTX)

###################################################################################################
# Broad acute respiratory from State Respiratory Virus Dashboard

url = "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&ccddCategory=cdc%20broad%20acute%20respiratory%20dd%20v1&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393895&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url = change_dates(url, start_date = startDate, end_date = endDate)

api_data = get_api_data(url, profile=myProfile,fromCSV=True)
# Rename timeResolution column to Week
api_data = api_data.rename(columns={'timeResolution':'Date','No':'Has Been Admitted No','Yes':'Has Been Admitted Yes'})

for col in api_data.columns:
    if col!='Date':
        api_data[col] = api_data[col].astype(int)
        
direct_upload_to_sharepoint_as_df(api_data,'CDC Acute broad respiratory illness emergency department visits and hospitalizations.xlsx','DW/Resp Illness Dashboard/Syndromic/CDC Respiratory Combined', CTX)

###################################################################################################
# COVID from State Respiratory Virus Dashboard

url = "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&ccddCategory=cdc%20coronavirus-dd%20v1&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393896&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url = change_dates(url, start_date = startDate, end_date = endDate)

api_data = get_api_data(url, profile=myProfile,fromCSV=True)
# Rename timeResolution column to Week
api_data = api_data.rename(columns={'timeResolution':'Date','No':'Has Been Admitted No','Yes':'Has Been Admitted Yes'})

for col in api_data.columns:
    if col!='Date':
        api_data[col] = api_data[col].astype(int)
        
direct_upload_to_sharepoint_as_df(api_data,'Covid emergency department visits and hospitalizations.xlsx','DW/Resp Illness Dashboard/Syndromic/Covid', CTX)

###################################################################################################
# Influenza from State Respiratory Virus Dashboard

url = "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&ccddCategory=cdc%20influenza%20dd%20v1&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393898&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url = change_dates(url, start_date = startDate, end_date = endDate)

api_data = get_api_data(url, profile=myProfile,fromCSV=True)
# Rename timeResolution column to Week
api_data = api_data.rename(columns={'timeResolution':'Date','No':'Has Been Admitted No','Yes':'Has Been Admitted Yes'})

for col in api_data.columns:
    if col!='Date':
        api_data[col] = api_data[col].astype(int)
        
direct_upload_to_sharepoint_as_df(api_data,'Influenza emergency department visits and hospitalizations.xlsx','DW/Resp Illness Dashboard/Syndromic/Influenza', CTX)

###################################################################################################
# RSV from State Respiratory Virus Dashboard

url = "https://essence.syndromicsurveillance.org/nssp_essence/api/tableBuilder/csv?geographySystem=state&percentParam=noPercent&ccddCategory=cdc%20respiratory%20syncytial%20virus%20dd%20v1&geography=hi&datasource=va_er&medicalGroupingSystem=essencesyndromes&timeResolution=daily&aqtTarget=TableBuilder&userId=6736&detector=probrepswitch&fieldIDs=timeResolution&fieldIDs=hasBeenAdmitted&fieldLabels=Date&fieldLabels=Has%20Been%20Admitted&displayTotals=false&displayTotals=false&displayZeroCountRows=true&rawValues=false&graphWidth=607&portletId=393897&dateconfig=15&startDate=12Apr22&endDate=22Jul24&rowFields=timeResolution&columnField=hasBeenAdmitted"

url = change_dates(url, start_date = startDate, end_date = endDate)

api_data = get_api_data(url, profile=myProfile,fromCSV=True)
# Rename timeResolution column to Week
api_data = api_data.rename(columns={'timeResolution':'Date','No':'Has Been Admitted No','Yes':'Has Been Admitted Yes'})

for col in api_data.columns:
    if col!='Date':
        api_data[col] = api_data[col].astype(int)
        
direct_upload_to_sharepoint_as_df(api_data,'RSV emergency department visits and hospitalizations.xlsx','DW/Resp Illness Dashboard/Syndromic/RSV', CTX)

# End of 9 reports
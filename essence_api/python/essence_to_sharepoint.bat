@echo off
Rem   Copyright (c) 2025. Sandeep Chintabathina
Rem  Batch script to run Python code that pulls Essence data and uploads data to Sharepoint
cd ..
cd ..
cd Users/s.chintabathina
Rem Folder with spaces need double quotes
cd "OneDrive - State of Hawaii"
python -u Desktop/NSSP/essence_api/python/respiratory_report_to_sharepoint.py

Rem pause

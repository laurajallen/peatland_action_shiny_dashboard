## This tab is just to bring in the data and packages needed for your app to run 
## can include dat aprep, but to keep things loading faster I did mos of that beforehand and loaded the prepared data

 rm(list=ls())
## Packages ----
library(shiny)
library(sp)
library(leaflet)
 library(plotly)

# plan of design

# Parts to app:
# 1. Map of sites, with pop up info for each project, with name, grant, HA and cost.
# 2. Financial year dropdown to filter data in map and summary
# 3. Annual summary: - summary of total figures for the filtered financial year - no. projects, hectares cost
##  - Hectares restored	
  # - Hectares feasibility study
  # - Money spent restoration	
  # - Money spent feasibility	
  # - Money spent other projects	
  # - Total projects spent 	
  # - No of projects


# 4. Trends: drop down for which type of data - No of projects, funding , hectares
# 5. Plot of trends based on the data type filter
# 6. Title
# 7. Text summary of project

## Read in data ----
 sites <- readRDS("data/sites.rds") ## list of sites from site summary spreadsheet (includes grid refs, names hectares etc.) Loading data as RDS is faster.
 totals <- readRDS("data/totals.rds") ## calculated total values for each year (number of projects, hectares funding etc)
 


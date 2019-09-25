# Preparing data to go into shiny app

## Laura Allen
## 06 September  2019 



## Packages ----
library(maptools) # read shp
library(rnrfa) # convert gridrefs
library(sp) ## not sure what this was for - something with spatial conversions
library(tidyverse) ## data wrangling


## Basic data prep for cleaning the intital dataset (site summaries) to be used---- 
## This only needs to be done once for the data you want to use
## Read in data ----

#site data
sites <- read.csv("C:/Data/Shiny_map/Peatland Action site summary data 160819.csv") ## read in site summary data
str(sites)
sites <- sites[1:401,1:14] ## get rid of empty rows and columns


## fix grid refs ----
## This may need to be customised for future datasets
sites$Grid.reference <- as.character(sites$Grid.reference) # convert to character format

sites <- sites %>% 
  filter(!(Grid.reference %in% c("n/a", "na", "#N/A", "", " ")| ## get rid of any rows that don't have grid refs
             is.na(Grid.reference))) %>% 
  droplevels() ## clears out levels in R memory

## tidy up the grid references
sites$Grid.reference <- gsub(" ","",sites$Grid.reference) ## gsub - replaces a pattern: what I want to find, what I want to find, where I want to do this
sites$Grid.reference <- gsub("/",",",sites$Grid.reference)
sites$Grid.reference <- gsub(".","",sites$Grid.reference,fixed=TRUE)
sites$Grid.reference <- gsub(";",",",sites$Grid.reference)

grs <- separate_rows(sites,Grid.reference,convert = TRUE) ## searate the multiple grid refs into separate rows, with all the complete column info from the other columns
head(grs) ## general check over
str(grs$Grid.reference)
tail(grs)
head(grs)


grs <- grs[-(which(nchar(grs$Grid.reference) %in% c(5,7,9,11))),] ## got rid of any odd number grid references (errors in data entry)
grs <- droplevels(grs)
grs <- grs[-505,] ## remove blank

#convert grid refs to coordinates WGS84
x <- osg_parse(grs$Grid.reference, CoordSystem = c("WGS84"))
grs$x = x[[1]]
grs$y = x[[2]]

#plot map of sites to check data ----
scotland <- readRDS("C://Data/datasciencetime/gadm36_GBR_0_sp.rds")
## background map of scotland

## plot map - using RDS boundary
#png("C:/Data/Shiny_map/scotlandmapRDS_PAsites.png",width = 110, height = 140, units = "mm",res=800) ## save as a png image (run this line and dev.off if you want to write  the image to a file)
par(mar=c(1,1,1,1))
plot(scotland,xlim=c(-8.5,0.5),ylim=c(56.3,59.3)) ## plot the background map
points(x=grs$x,y=grs$y, col = "blue", pch=19,lwd=0.2,cex=0.2) ## add the points and adjust their size and colour
title("Peatland Action restoration sites 2012-2019", cex.main=1) ## add the title
#dev.off()

## tidy up formats----
head(grs) ## when you check the data, each variable has the same favors written in different ways, so I have standardsised and corrected them - again, may need to be customised for other datasets
str(grs)
levels(grs$Project.type)
levels(grs$Project.type)[c(3,4,5,6)] <- "Feasibility"
levels(grs$Project.type)[c(1,2,5,7)] <- "Other"
levels(grs$Project.type)[c(3,5)] <- "Monitoring"

levels(grs$Project.status)
levels(grs$Project.status)[c(1,2)] <- ""
levels(grs$Project.status)[c(3,4)] <- "Deferred"
levels(grs$Project.status)[c(7,8)] <- "Part slipped"

levels(grs$Financial.year)
levels(grs$Financial.year)[4] <- "2012-13"

levels(grs$Hydrology.monitoring)
levels(grs$Hydrology.monitoring)[c(2,3)] <- "No"
levels(grs$Hydrology.monitoring)[c(3,4,5)] <- "Yes"

levels(grs$Peat.depth.data)
levels(grs$Peat.depth.data)[c(3,4,5)] <- "Yes"

levels(grs$Peat.condition.data)
levels(grs$Peat.condition.data)[c(2,3,4,5)] <- "No"
levels(grs$Peat.condition.data)[c(3,4,5,6)] <- "Yes"

names(grs)[14] <- "Vegetation.data"
levels(grs$Vegetation.data)
levels(grs$Vegetation.data)[c(3,4)] <- "No"
levels(grs$Vegetation.data)[c(4,5,6,7,8)] <- "Yes"
levels(grs$Vegetation.data)[2] <- "" ## 'maybe' not a very informative level, so removed!

grs$Hectares.restoration <- as.numeric(as.character(grs$Hectares.restoration))
grs$Funding.offered <- gsub(",","",grs$Funding.offered)
grs$Funding.offered <- as.numeric(as.character(grs$Funding.offered))
head(grs)

levels(grs$Local.authority)
levels(grs$Local.authority)[7] <- "Dumfries and Galloway Council"
levels(grs$Local.authority)[20] <- "Scotland-wide"

sites_filt <- grs %>% 
  filter((Project.type %in% c("Feasibility", "Restoration"))) %>% 
  filter(!(Project.status %in% c("Failed", "Refused","Withdrawn"))) %>% 
  droplevels() ## filter data to only include restoration and feasibility studies, and to exclude any withdrawn, refused or failed projects

#write.csv(sites_filt,"C:/Data/Shiny_map/site_summary_clean.csv") ## write my cleaned up, filtered data with coordinates to a new file


##########################################
## Data prep for using the app ----

#site coords
sites <- read.csv("C:/Data/Shiny_map/site_summary_clean.csv") ## read in the new clean data
head(sites)
sites <- sites[-which(sites$Hectares.restoration>15000),] # remove ridiculously high restoration area as very likely to be an error

saveRDS(sites, "data/sites.rds") ## save as an rds file for use in the app


## Create dataset for total sums by year

rest <- sites %>% filter((Project.type == "Restoration")) ## filter restorationa nd feasibility studies
feas <- sites %>% filter((Project.type == "Feasibility")) 

Hrest <-  tapply(rest$Hectares.restoration,rest$Financial.year,sum,na.rm=T) ## sum up the hectares for each year (by restoration or feasibility)
Hfeas <-  tapply(feas$Hectares.restoration,feas$Financial.year,sum,na.rm=T)
Frest	<-  tapply(rest$Funding.offered,rest$Financial.year,sum,na.rm=T) ## sum up the funding for each year (feas, rest and in total)
Ffeas	<-  tapply(feas$Funding.offered,feas$Financial.year,sum,na.rm=T) 
Ftotal <- tapply(sites$Funding.offered,sites$Financial.year,sum,na.rm=T) 
Nproj <-  tapply(sites$Grant.reference,sites$Financial.year,length) ## count how many projects there were in each year (all types)


## bind all the columns calculated above into one table
totals <- cbind("Hectares_restoration"=Hrest,"Hectares_feasibility" = Hfeas, "Funding_restoration" = Frest, "Funding_feasibility" = Ffeas, "Total_funding" = Ftotal, "Number_of_projects" = Nproj)

Year <- row.names(totals) ## create a variable for year 
Financial_year <- c(NA,2012,2013,2014,2015,2016,2017,2018,2019) ## also have a version of year written as a number (some plotting functions won't read '2012-13' as a numeric pattern for plotting)
totals <- cbind(totals,Year,Financial_year) ## combine into the table
totals <- as.data.frame(totals) ## make it a dataframe (format works better)
totals <- totals[-1,] ## remove NA row ## get rid of the extra row where the year was 'NA'

str(totals) ## now you have the total values for each year of the main variables of interest
## just convert the data intot he appropriate types (so they are read as numbers not text)
totals$Hectares_restoration <- as.numeric(as.character(totals$Hectares_restoration)) 
totals$Hectares_feasibility <- as.numeric(as.character(totals$Hectares_feasibility))
totals$Funding_feasibility <- as.numeric(as.character(totals$Funding_feasibility))
totals$Funding_restoration <- as.numeric(as.character(totals$Funding_restoration))
totals$Total_funding <- as.numeric(as.character(totals$Total_funding))
totals$Number_of_projects <- as.numeric(as.character(totals$Number_of_projects))
totals$Financial_year <- as.numeric(as.character(totals$Financial_year))

totals <- totals %>% gather("variable", "value", -c(Year, Financial_year)) %>%  ## convert to a 'long' format as it is easier for shiny to select data based on the row entries rather than the column names
  mutate(variable = gsub("_", " ", variable),
         rest_feas = case_when(variable %in% c("Hectares restoration", "Funding restoration") ~ "Restoration", ## create a column for the 'totals' dataset saying if it is a restoration or feasibility project  (so they can be plotted as separate lines)
                               variable %in% c("Hectares feasibility", "Funding feasibility") ~ "Feasibility",
                               variable %in% c("Number of projects", "Total funding") ~ "All"), ## if rest and feas combined, call it 'all'
         data_type = case_when(variable %in% c("Hectares restoration", "Hectares feasibility") ~ "Area in hectares", ## create a column for selecting type of data to plot (area, money of number of projects)
                               variable %in% c("Funding restoration", "Funding feasibility") ~ "Money spent",
                               variable %in% c("Number of projects") ~ "Number of projects",
                               variable == "Total funding" ~ "Total funding")) %>% 
  select(-variable)

saveRDS(totals, "data/totals.rds") ## save the Totals dataset to be read into the shiny app.

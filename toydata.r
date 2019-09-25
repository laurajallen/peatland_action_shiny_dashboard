library(maptools) # read shp
library(rnrfa) # convert gridrefs
library(sp) ## not sure what this was for - something with spatial conversions
library(tidyverse) ## data wrangling


## Basic data prep for cleaning the intital dataset (site summaries) to be used---- 
## This only needs to be done once for the data you want to use
## Read in data ----

#site data

sites <- read.csv("C:/Data/Shiny_map/site_summary_clean.csv") ## read in the new clean data
head(sites)
sites <- sites[-which(sites$Hectares.restoration>15000),] # remove ridiculously high restoration area as very likely to be an error
str(sites)
summary(sites)

randomnames <- c(NULL)
for(s in 1:length(sites[,1])){
    names <- sample(LETTERS,8)
    name <- str_c(names, sep = "",collapse="")
    randomnames <- c(randomnames,name)
  }
sites$Project.name <- randomnames ## replace real names with random ones

randomstatus <- c(NULL)
for(s in 1:length(sites[,1])){
  names <- sample(c("complete","in progress","other"),1)
  name <- str_c(names, sep = "",collapse="")
  randomstatus <- c(randomstatus,name)
}
sites$Project.status <- randomstatus ## replace real names with random ones

randomyn <- c(NULL)
for(s in 1:length(sites[,1])){
  names <- sample(c("yes","no"),1)
  name <- str_c(names, sep = "",collapse="")
  randomyn <- c(randomyn,name)
}
sites$Hydrology.monitoring <- randomyn ## replace real names with random ones
sites$Peat.condition.data <- randomyn
sites$Peat.depth.data <- randomyn
sites$Vegetation.data <- randomyn

randomyear <- c(NULL)
for(s in 1:length(sites[,1])){
  names <- sample(c("2012-13","2013-14","2014-15","2015-16","2017-18","2018-19"),1)
  name <- str_c(names, sep = "",collapse="")
  randomyear <- c(randomyear,name)
}
sites$Financial.year<- randomyear ## replace real names with random ones

randomLA <- c(NULL)
for(s in 1:length(sites[,1])){
  names <- sample(LETTERS[1:15],1)
  name <- str_c(names, sep = "",collapse="")
  randomLA <- c(randomLA,name)
}
sites$Local.authority<- randomLA ## replace real names with random ones



randomids <- c(NULL)
for(s in 1:length(sites[,1])){
  nums <- sample(c(1:9),6)
  id <- str_c(nums, sep = "",collapse="")
  randomids <- c(randomids,id)
}
sites$Grant.reference <- randomids ## replace real grant codes with random ones

randomHAs <- c(NULL)
for(s in 1:length(sites[,1])){
  nums <- runif(1,min=0,max=2500)
  randomHAs <- c(randomHAs,nums)
}
sites$Hectares.restoration <- randomHAs ## replace real hectares with random ones

randomfunds <- c(NULL)
for(s in 1:length(sites[,1])){
  nums <- runif(1,min=0,max=500000)
  randomHAs <- c(randomfunds,nums)
}
sites$Funding.offered <- randomfunds ## replace real hectares with random ones

head(sites)
saveRDS(sites, "data/sites.rds") ## save an example dataset with fake numbers so the app is usable but doesn't contain any real info

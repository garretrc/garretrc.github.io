####Comparing CSV reading functions by Runtime####
#Dataset: December 2009 Yellow Cabs
#Info: 2.5GB set, 14 million rows
#Source: NYC Taxi/Limo Commission
#Link: https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2009-12.csv

####Preparation####
#First download the data by clicking on the link
#Then set your working directory to the needed folder

#you will need to change this directory!
setwd("C:/Users/garretrc/Downloads")

#Next we want to grab the libraries we will use
install.packages("data.table")
install.packages("readr")

library(data.table)
library(readr)

####Reading in the data####
#trying with read.csv
#SKIP THIS IF YOUR COMPUTER HAS <4GB OF RAM (or if you don't know what a RAM is)
#might not work, gonna be slooooow
cabs = read.csv("yellow_tripdata_2009-12.csv")

#Note this query runs fast though!
cabs[1000000, ]
rm(cabs)

#The fread function from data.table works just like read.csv
#(and in fact it can automatically read other data types as well!)
#fread is usually faster, but sometimes not
#setting fill=T makes things simpler in case the CSV formatting is off
#but using fill=T can result in junk columns like in this case V18 and V19 are NA's
cabs = fread("yellow_tripdata_2009-12.csv", fill = T)

#that ran super quickly! so does this query
cabs[1000000, ]

#don't want too much data floating around, so we'll remove this from our memory
rm(cabs)

#the read_csv function from readr/tidyverse also works like read.csv
#Historically, read_csv has been slower than fread
#In recent times, read_csv has gotten faster and faster so there's no clear winner now
#read_csv usually works with no extra options but sometimes has junk rows
cabs = read_csv("yellow_tripdata_2009-12.csv")

#There is a chance this query runs slowly though
cabs[1000000, ]
rm(cabs)

#Now we can see how fast these run
#note this loop is gonna take a long time to calculate all 3 runtimes
for (i in 1:1) {
  read.csv_runtime = system.time({
    cabs = read.csv("yellow_tripdata_2009-12.csv")
  })
  rm(cabs)
  
  fread_runtime = system.time({
    cabs = fread("yellow_tripdata_2009-12.csv", fill = T)
  })
  rm(cabs)
  
  read_csv_runtime = system.time({
    cabs = read_csv("yellow_tripdata_2009-12.csv")
  })
  rm(cabs)
}

#all of these times are in seconds
read.csv_runtime[3]
fread_runtime[3]
read_csv_runtime[3]
#fread was way way quicker than read.csv
#read_csv was way quicker than fread this time
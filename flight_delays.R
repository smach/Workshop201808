
# This is a data set that anyone who travels might want to do some exploring and wrangling with -- airline and airport flight on-time information. I downloaded data for New York State and New Jersey for the most recently available month, which was April.

# Data source: https://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236

# Step 1 is importing the data. There are a lot of ways to import external data into R, using base R or special packages. There's the readxl package for spreadsheets; readr or data.tables or read.csv for CSV files ... but if you don't want to remember all those, the easiest thing is to use the rio package. rio stands for R import/output. There's one import() function and one export() function, and then rio handles everything behind the scenes.

# The data file is 2018_04_NYNJ_ONTIME and it's in the data subdirectory. Let's load it into a variable called ontime.

ontime <- rio::import("data/2018_04_NYNJ_ONTIME.csv")

# This creates a type of R object known as a data frame. It's a row-by-column 2-dimensional object that's a little like a spreadsheet. One key difference is, every column has to be the same data type. First column can be characters and second column can be numbers, but a numerical column has to be ALL NUMBERS. If even one value in a number column is a character string, the whole column ends up as characters. This is good to keep in mind if you're working with less-than-pristine data.

# Back to the data.

# What does this data set look like? There are many ways to investigate. For an Excel-like look at it, click on the variable name in the top right panel.

# You can sort by a column by clicking on it.

# Basic R command for looking at a data object's structure:

str(ontime)

# You can see we've got 88,253 observations, or rows, with 49 variables, or columns. str() shows the type of data in each column: character, integer, logical, etc. It also shows the first few values.

# Separately, though, it's always worth looking at the first few lines of a data set with head()

head(ontime)

# And the last few lines , to make sure there's no trailing junk at the bottom of the file - or some kind of summary data.

tail(ontime)

# With so many columns, dplyr's glimpse function can be a good way to take a peek at the data

dplyr::glimpse(ontime)

# What questions might you have about this data set?


# Some ways of looking at the data, including very basic statistical analysis:


summary(ontime)
Hmisc::describe(ontime)
skimr::skim(ontime)

# Do you want to see all the column names of ontime? Use the names() function.

names(ontime)

# To see just the 1st name:

names(ontime)[1]

# To see the first 5 names:

names(ontime)[1:5]

# To change the 26th name from TAXI_IN to Taxi_in_Time:

names(ontime)[26] <- "Taxi_in_Time"

# Check if that worked

names(ontime)

# Note that R is CASE-SENSITIVE. TAXI_IN is not the same as Taxi_In

# It's kind of hard to see much with all these columns -- a good lesson in why you might want to use the select function to pick just a few columns when doing some analysis. How about we'll pick:
 
# flight date FL_DATE
# airline CARRIER
# flight number FL_NUM
# origin airport ORIGIN
# destination airport DEST
# departure time DEP_TIME
# departure delay DEP_DELAY_NEW
# arrival time ARR_TIME
# arrival delay ARR_DELAY_NEW
# cancelled CANCELLED
# cancellation code CANCELLATION_CODE
# carrier delay CARRIER_DELAY
# weather delay WEATHER_DELAY
# air system delay NAS_DELAY
# security delay SECURITY_DELAY
# late aircraft delay LATE_AIRCRAFT_DELAY

# It will be helpful here to create a variable holding all the column names we want. We can create a *vector* of all these using R's c() function. A vector is a one-dimensional kind of object -- if a data frame is sort of like a spreadsheet, a vector is a bit like a single spreadsheet column but stand-alone.

# To remember using c() to create a vector, think of it as c for combine or concatenate. 

# Because these column names are all character strings, each one needs to be enclosed in quotation marks. Kind of annoying to type out, but necessary if you want to create a new variable with just the columns you want.

my_columns <- c("FL_DATE", "CARRIER", "FL_NUM", "ORIGIN", "DEST", "DEP_TIME", "DEP_DELAY_NEW", "ARR_TIME", "ARR_DELAY_NEW", "CANCELLED", "CANCELLATION_CODE", "CARRIER_DELAY", "WEATHER_DELAY", "NAS_DELAY", "SECURITY_DELAY", "LATE_AIRCRAFT_DELAY")

# Questions?

# Let's look at that by just typing the name of the variable:

my_columns

# OK, we're all set up to select just those columns with the select function. I'm going to create a new variable mydata from the ontime data, and select the columns that are in my_columns, like this (first loading the dplyr package)

library(dplyr)

mydata <- select(ontime, my_columns)

# ontime is the data, and my_columns is the group of columns you want to select.

# I showed you how to make a separate vector with the column names, well, because that's an important R skill. But you could have also done it like this:

mydata <- select(ontime, FL_DATE, CARRIER, FL_NUM, ORIGIN, DEST, DEP_TIME, DEP_DELAY_NEW, ARR_TIME, ARR_DELAY_NEW, CANCELLED, CANCELLATION_CODE, CARRIER_DELAY, WEATHER_DELAY, NAS_DELAY, SECURITY_DELAY, LATE_AIRCRAFT_DELAY)

# In other words, you've got 

# select(mydata, mycolumn1, mycolumn2, mycolumn3) 

# and so on.

# POSSIBLE CONFUSION ALERT!

# While "regular" base R requires character strings to have quotation marks around them, a lot of "tidyverse" packages don't. That's why the format for creating a character vector is c("string1", "string2", "string3") but for selecting a column is select(mydata, mycolumn1, mycolumn2, mycolumn3)

# If we wanted to use pipes, the format would be

mydata <- ontime %>%
  select(my_columns)

# This says: Create a variable named mydata from ontime, and then just select all the columns in my_columns. 

# Pipes are most useful for multi-step work. Some people think they make code more readable even if you're just doing one thing. Personal preference here.

# Questions?

# Since we're in the NY metro area, let's only look at flights that left from  JFK, LGA, or EWR. That's using the filter function to extract just the *rows* we want, based on some criteria.

# To do one airport:

my_departures <- ontime %>%
  select(my_columns) %>%
  filter(ORIGIN == "JFK")

# That last line says "only give me rows where the ORIGIN column equals JFK." 

# NOTE THE TWO EQUALS SIGNS. == tests for equality: Is one side of the equation the same as the other? A single equal sign ASSIGNS A VALUE. This is not just an R thing; that's how most programming works. And it's really easy to make mistakes.

# To repeat:

## ORIGIN == "JFK" is asking if ORIGIN equals JFK.
## ORIGIN = "JFK" sets the value of ORIGIN to JFK.

# To say ORIGIN == "JFK" or ORIGIN == "LGA" or ORIGIN == "EWR" you can use the symbol for or: |. That's also pretty standard in many programming languages:

my_departures <- ontime %>%
  select(my_columns) %>%
  filter(ORIGIN == "JFK" | ORIGIN == "LGA" | ORIGIN == "EWR")

# Advanced shortcut: If you've got more than 2 or 3 conditions for the same column, writing out ORIGIN == again and again can get annoying. Here's another way to do that:

my_departures <- ontime %>%
  select(my_columns) %>%
  filter(ORIGIN %in% c("JFK", "LGA", "EWR"))

# Note that %in% function? It says I want all rows where ORIGIN is in one of these values.

# Now it might be fun to run skimr again 

skimr::skim(my_departures)

# Forget for a moment that it's running statistical analysis on columns that are numbers but don't really make sense to do math on, like flight numbers. Averaging flight numbers is kind of silly. We now see there's a an average departure delay of 17.41 minutes, but a median delay of 0. That tells us most flights weren't delayed but a few were delayed a lot more than 17 minutes. 75% of flights had a delay of 9 minutes or less. At least one unlucky flight was delayed for more than 1,000 minutes. Geez I'm curious now about flights delayed more than a thousand minues. I want to take a quick look at flights where departure delays are greater than 1000:

filter(my_departures, DEP_DELAY_NEW > 1000)

# Quick exploratory graphics would show the distribution of delays in more detail. Base R's hist() function will give us a full-screen graph, not just the little one that comes with skimr:

hist(my_departures$DEP_DELAY_NEW)

# What about the distribution of flights delayed more than 5 hours? Think what we want to do: filter rowns so DEP_DELAY_NEW > 300:

unlucky <- filter(my_departures, DEP_DELAY_NEW > 300)
  hist(unlucky$DEP_DELAY_NEW)

# If you'd like to change the number of bins, set breaks in the hist() function
  hist(unlucky$DEP_DELAY_NEW, breaks = 20)
  
# I'll be showing another way to visualize data that a lot of journalists like, using the ggplot2 library soon.
  
# But first, let's look at average and median departure delays BY AIRPORT. 
  
# This is where group_by and summarize come in.
  
# group_by() is pretty awesome. Once you group_by() one or more column, EVERY SUBSEQUENT OPERATION IS DONE BY GROUP. So if we group by airport, anything we calculate using summarize *is by each airport*. Check it out:
  
my_departures %>%
  group_by(ORIGIN) %>%
  summarize(
    AvgDelay = mean(DEP_DELAY_NEW),
    MedianDelay = median(DEP_DELAY_NEW)
    
  )

# Wait, what happened? NA means not available. Why is nothing available?

# It turns out that if even one value out of 37,000+ is unavailable, a lot of other things become unavailable by default in R. It makes sense, if you think more about it. If you're averaging 100 numbers and 10 are unavailable, how do you know the average? Those 10 unavailable numbers could be ANYTHING. You need to actively tell R "discard the unavailable values, they're not important." R won't assume that anything missing shouldn't be taken into account.

# You can tell R to remove the NA values with na.rm = TRUE:

my_departures %>%
  group_by(ORIGIN) %>%
  summarize(
    AvgDelay = mean(DEP_DELAY_NEW, na.rm = TRUE),
    MedianDelay = median(DEP_DELAY_NEW, na.rm = TRUE)
  )

# That's better.

# Let's do a little more exploring of this data. 

# Create a variable with just flights going to a certain city. For me, I'll look at flights heading to DEST BOS. Pick an airport of your choice. How would you do this?

# Hint: You'd like all rows where DEST equals a certain airport code.

# How would you look at average flight delay by airline CARRIER in this data?

# Hint: You'd like to group by CARRIER and then add new columns for the mean and median of DEP_DELAY_NEW.

# If a flight is cancelled, its cancellation code is 1; otherwise, the cancellation code is 0. The janitor package has a really useful function called tabyl to investigate situations like this:

janitor::tabyl(my_departures$CANCELLED)



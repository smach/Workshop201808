# August 2018 Intro to R and RStudio
# Sharon Machlis

#### Try some simple things in the console ####

21 * 3

x <- 21
y <- 3

# What's that <- symbol? It means "assign the value of what's on the right to the variable on the left."

# In most cases, you can use an = sign as well. But in certain cases, <- is needed.
# Most R users these days use <-, but if bugs the heck out of you, switch to = for this session so it doesn't distract you.

# Why do some lines start with the # pound sign? Those are comments - notes explaining the code, but not actual code to run.


x * y

#### Where am I? ####

# Find your working directory:

getwd()

# You can set your working directory with 

# setwd("/path/to/directory")

# Note the directory is in quotation marks. Most character strings need to be in R.

# About 10 or 15 minutes of basic stuff, then we'll get to some much cooler things.


# Create a variable with the names of three cities. For that, we need R's c() function. Think of it as "combine" or "concatenate." If we are doing character strings, they need to be in quotation marks.

Boroughs<- c("Manhattan", "Kings", "Queens", "Bronx", "Staten Island")

# Let's look at that by typing the name of the variable in the console

Boroughs

# What's item 1 of Boroughs?

Boroughs[1]

# What's item 3?

Boroughs[3]

# What are items 2 and 3?

Boroughs[2:3]

# OR

Boroughs[c(2,3)]

# What if I'd like to change item 2 to "Brooklyn"?

Boroughs[2] <- "Brooklyn"

Boroughs

PctIncomeRent <- c(28.4, 32.7, 33.5, 35.5, 32.8)

# These are numbers, so they don't need quotation marks

# How to combine them into a spreadsheet-like object? Create a data frame

boro_info <- data.frame(Boroughs, PctIncomeRent, stringsAsFactors = FALSE)

# Look at it:

boro_info

# Most of the time, though, you're probably not going to be typing data into R. You'll probably have data from elsewhere, which means ...

# Step 1 is importing the data. There are a lot of ways to import external data into R, using base R or special packages. There's the readxl package for spreadsheets; readr or data.tables or read.csv for CSV files ... but if you don't want to remember all those, the easiest thing is to use the rio package. rio stands for R import/output. There's one import() function and one export() function, and then rio handles everything behind the scenes.

# I've got a spreadsheet with percent income spent on rent, number of households below the poverty threshhold, number of households not below the poverty threshhold, and total number of households. It's in the data directory as "ny_county_rent_poverty.xlsx"

nypoverty <- rio::import("data/ny_county_rent_poverty.xlsx")

# This creates a type of R object known as a data frame. It's a row-by-column 2-dimensional object that's a little like a spreadsheet. One key difference is, every column has to be the same data type. First column can be characters and second column can be numbers, but a numerical column has to be ALL NUMBERS. If even one value in a number column is a character string, the whole column ends up as characters. This is good to keep in mind if you're working with less-than-pristine data.

# Back to the data.

# What does this data set look like? There are many ways to investigate. For an Excel-like look at it, click on the variable name in the top right panel.

# You can sort by a column by clicking on it.

# Basic R command for looking at a data object's structure:

str(nypoverty)

# You can see we've got 5 observations, or rows, with 8 variables, or columns. str() shows the type of data in each column: character, integer, logical, etc. It also shows the first few values.

# Separately, though, it's always worth looking at the first few lines of a data set with head()

head(nypoverty)

# That gives you the first 6 lines -- or in this case, all 5 lines. If the data set were larger, it would be worth looking at the last few lines , to make sure there's no trailing junk at the bottom of the file - or some kind of summary data.

tail(nypoverty)

# dplyr's glimpse function can be a good way to take a peek at the data

dplyr::glimpse(nypoverty)

# What questions might you have about this data set?


# Some ways of looking at the data, including very basic statistical analysis:


summary(nypoverty)
Hmisc::describe(nypoverty)
skimr::skim(nypoverty)

# Do you want to see all the column names? Use the names() function.

names(nypoverty)

# To see just the 1st name:

names(nypoverty)[1]

# To see the first 3 names:

names(nypoverty)[1:3]

# To change the 4th name from Non_Poverty_Households to Above_Poverty_Households:

names(nypoverty)[4] <- "Above_Poverty_Households"

# Check if that worked

names(nypoverty)

### There's obviously a lot more to do with data. But since you've been good sports slogging through a few basics, let's take a break and have some fun with some R Eye Candy!! 

# Open the eyecandy.R file.








#### EYE CANDY!!! ####

# Now we're going to see some of the considerably more powerful things R can do.
# This is the "eye candy" part of the session, which shows you some of R's cool capabilities so you don't finish the workshop thinking "Why would I want to learn R? I can do everything she showed me in Excel."

# Unfortunately there's not enough time to explain in detail what's going on.
# The remaining portions of this workshop will include explanations :-)


#### Getting and visualizing financial information in a few lines of code ####

# Check out stock price of one of NYC's largest employers. I'm going to load in an external "package" called quantmod into my working session here. If you've never programmed before, let me briefly explain packages. They're like add-ons or plug-ins. Out-of-the-box R, called "base R," has a lot of functionality, but it doesn't do everything. People have written thousands of additional functions for R, and put them into packages. A lot of these packages are very useful for solving specific probems or just doing cool things. quantmod is a financial analysis package. It includes some handy functions we'll be using in a minute, such as getSymbols for retrieving data and barChart for graphing data.

library(quantmod)
JPMorganChase <- getSymbols("JPM", auto.assign = FALSE)

barChart(JPMorganChase)
barChart(JPMorganChase['2018'])
barChart(JPMorganChase['2017:2018'])
barChart(JPMorganChase, theme = "white")

# dygraphs is another 

library("dygraphs") 
dygraph(JPMorganChase$JPM.Adjusted)



library(tidyquant)

sp500 <- tq_index("SP500")
dow <- tq_index("DOW")

#### Help! ####

# How to get help for a package
help(package = "tidyquant")

# How to get help for a function
?tq_index

# If you're not sure of the exact function name: ??
??tq_

# Some packages have "vignettes," which are detailed write-ups of how to use a package. We saw a link to "User guides, package vignettes and other documentation" with help(package = "tidyquant"). You can browse all the vignettes on your system with

browseVignettes()

# or browse vignettes for a specific package with

browseVignettes("tidyquant")


#### Getting and visualizing Manhattan unemployment data ####

nyc_unemployment <- getSymbols("NYNEWY1URN", src="FRED", auto.assign = FALSE) 

names(nyc_unemployment) = "rate" 

dygraph(nyc_unemployment, main="Manhattan unemployment")


#### Mapping points in a few lines of code ####

# Again, sorry I don't have time to explain in depth, just to see a bit of what else R can do

# data from https://opendata.socrata.com/Business/USA-Starbucks/e3xz-8cw7
# Warning: While this data set was posted to Socrata in 2016, the "about" file says
# it was scraped in 2012. Location info may be out of date!


starbucks <- rio::import("data/USA_Starbucks.csv")
library("leaflet") 

leaflet() %>%  
  addProviderTiles(providers$Esri.WorldStreetMap) %>% 
  setView(-74.0048036, 40.725395, zoom = 16) %>%
  addMarkers(data = starbucks, lat = ~ Latitude, lng = ~ Longitude, popup = starbucks$Name) %>%
  addPopups(lng = -74.0048036, lat = 40.725395, popup = "ProPublica")

# I said I wasn't going to explain much here, but I do want to tell you what that %>% group of symbols is. It's a "pipe" in R. It says "take the resulting value or values of whatever just happened, and "pipe" it into the next line of code.

# That first line of code created a blank leaflet map object (you'll have to trust me on this). The next line says "add Esri provider tiles to that map object so it's not just blank." The line after that says: "Take that resulting map object with the Esri tiles and center it at that particular longitude and latitude and zoom level." And so on to add markers and pop-ups.

# We'll be using pipes a lot. They're especially useful for analysis that has multiple steps.


# Find coordinates in R
library(ggmap)
library(dplyr)
geocode("155 Avenue of the Americas, New York, NY")

# Can geocode well-known places in R by name, too:
geocode("Empire State Building")

leaflet() %>%  addProviderTiles(providers$Esri.WorldStreetMap) %>% setView(-73.98566, 40.74844, zoom = 15) %>%
  addMarkers(data = starbucks, lat = ~ Latitude, lng = ~ Longitude, popup = starbucks$Name) %>%
  addPopups(lng = -73.98566, lat = 40.74844, popup = "Empire State Building")


## FYI Updated Starbucks locations which I pulled via the Yelp API for Manhattan Starbucks:

nyc_starbucks <- rio::import("data/starbucks_nyc_50.csv")

leaflet() %>%  
  addProviderTiles(providers$Esri.WorldStreetMap) %>% setView(-74.0048036, 40.725395, zoom = 15) %>%
  addMarkers(data = nyc_starbucks, popup = nyc_starbucks$Street) %>%
  addPopups(lng = -74.0048036, lat = 40.725395, popup = "ProPublica")



# Get a static Google Map of NYC: (occasional problems with "over query limit" - just try again)
get_googlemap("new york, ny", zoom = 13, maptype = "roadmap") %>% ggmap()

# More fun with static maps:

qmplot(Longitude, Latitude, data = nyc_starbucks, color = I("red"))

qmplot(Longitude, Latitude, data = nyc_starbucks, maptype = "watercolor", color = I("red"))




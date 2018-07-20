# Next we're going to use some of the skills we just learned to do simple analysis on primary results for the NY 14th Congressional District Democratic primary, where challenger Alexandria Ocasio_Cortez was a surprise winner over Joseph Crowley.

# I downloaded the Election Night results from the Queens and Bronx election boards, and merged them into one Excel spreadsheet. To keep things simple, I'm just using votes for the two main candidates, not blanks or write-ins.

# Let's use the rio package's import() function to import the PrimaryCD14.xlsx Excel spreadsheet into R.

results <- rio::import("data/PrimaryCD14.xlsx")

# What does this data set look like? As we saw with the flight-delay data, there are many ways to investigate. Remember: For an Excel-like look at it, click on the variable name in the top right panel.

# Look at the first few lines with head()

head(results)

# And the last few, to make sure there's no trailing junk at the bottom of the file - or total row!
tail(results)

# And the general structure
str(results)
# or
library(dplyr)
glimpse(results)

# Remember some of the ways to look at the data with basic statistical analysis?


summary(results)
Hmisc::describe(results)
skimr::skim(results)

# Again, there's no "right" choice here. It's up to you, which output you like best.

# One thing that's missing here is totals and vote percentages. 

#### In general, there's a way to do this in R that's super-easy, thanks to the janitor package and its adorn_totals() function. Hardest thing is remembering to use it :-)

# adorn_totals() will skip the first row assuming it's a character description. For this purpose, we also want to select out the Reported and Borough columns with select(results, -Reported, -Borough). And we want to add a total column, so adorn_totals needs a where = "col" argument.

library(janitor)
results_only <- results %>%
  select(-Reported, -Borough) %>%
  adorn_totals(where = "col")
  

# In this case, though, we lose the Borough information, which we might want. But it's good to know about!

# So let's do this manually as we did with Manhattan zip codes.

# One way to do this is dplyr's mutate.

results <- results %>%
  mutate(
    TotalVotes = ALEXANDRIA_OCASIO_CORTEZ + JOSEPH_CROWLEY
  )

# Reminders: "mutate" means "change the data frame by adding new columns. And that %>% symbol is  a pipe in R. It says "take the resulting value or values of whatever just happened, and "pipe" it into the next line of code.

# So, the code above says "I want to keep storing the results values into the results variable. Next, I want to add a TotalVotes column, which should equal the ALEXANDRIA_OCASIO_CORTEZ + JOSEPH_CROWLEY columns. 

# Note the underscore instead of hyphen in Alexandria Ocasio-Cortez's column. R has a strong preference for only having underscores or periods in column names in addition to letters and numbers -- and not starting with a number. You can get away with other characters like hyphens and spaces at times, but there can be trouble that's best not to mess with!

### Two other options for creating the column, skip if you'd like

# 1. Since we're only doing one operation here, we can also use the non-pipe version of mutate, with a syntax mydata <- mutate(mydata, newcol = whatever)

results <- mutate(results, TotalVotes = ALEXANDRIA_OCASIO_CORTEZ + JOSEPH_CROWLEY)

# 2. This is the base R way to create a new column called TotalVotes that's adding the ALEXANDRIA_OCASIO_CORTEZ and JOSEPH_CROWLEY columns. Like doing =B2 + C2 in Excel and then clicking and dragging down. But here, you can see exactly what you're doing and don't have to worry whether the click/drag was done correctly.

results$TotalVotes <- results$ALEXANDRIA_OCASIO_CORTEZ + results$JOSEPH_CROWLEY

# What's with the dollar signs? We saw that in the eye-candy portion as well. We know now that results is a "data frame" -- a 2-dimensional data format with rows and columns, similar in some ways to a spreadsheet. The dollar sign is just how R refers to a column in a data frame.

# A lot of people like the mutate() and %>% syntax because you don't have to keep repeating the name of the data frame.

# Let's take a look at total votes. Note that here we're also using the dollar sign to refer to a specific column in the results data frame

Hmisc::describe(results$TotalVotes)

# For the sake of analysis, I'm going to remove the districts with 0 and the one with 7 votes. The one with 7 could wreak havoc on percentages.

# This is a task for dplyr's filter(), which lets you choose only rows that meet a certain condition. In this case, I want rows where TotalVotes are greater than 10.

results <- filter(results, TotalVotes > 10)

# Now I'll add two more columns for the percent of votes that each candidate received:

results <- results %>%
  mutate(
    Pct_Ocasio_Cortez = (ALEXANDRIA_OCASIO_CORTEZ / TotalVotes ) * 100,
    Pct_Crowley = (JOSEPH_CROWLEY / TotalVotes ) * 100
  )

# If you want to round those to just, say, 1 decimal place instead of 5, use the round() function and then include that you want 1 for 1 decimal place.

# More info on round:
?round

results <- results %>%
  mutate(
    Pct_Ocasio_Cortez = round((ALEXANDRIA_OCASIO_CORTEZ / TotalVotes ) * 100, 1),
    Pct_Crowley = round((JOSEPH_CROWLEY / TotalVotes ) * 100, 1)
  )

#### Note: If we weren't worried about keeping the borough column, which I want for later, janitor has an adorn_percentages() function we could use on just the ALEXANDRIA_OCASIO_CORTEZ and JOSEPH_CROWLEY columns, keeping District as the first column (first column is always skipped with these janitor adorn functions):

percent_results_only <- results %>%
  select(District, ALEXANDRIA_OCASIO_CORTEZ, JOSEPH_CROWLEY) %>%
  adorn_percentages(denominator = "row")

# Finally, a simple question: Who won???

# If Pct_Ocasio_Cortez > Pct_Crowley, Ocasio_Cortez
# If Pct_Ocasio_Cortez < Pct_Crowley, Crowley
# If Pct_Ocasio_Cortez == Pct_Crowley, Tie

# There are three possibilities here, not two. Instead of using multiple ifelse statements, dplyr's case_when function is an efficient way to create a Winner column:

results$Winner <- case_when(
  results$Pct_Ocasio_Cortez > results$Pct_Crowley ~ "Ocasio-Cortez",
  results$Pct_Ocasio_Cortez < results$Pct_Crowley ~ "Crowley",
  results$Pct_Ocasio_Cortez == results$Pct_Crowley ~ "Tie"
)

#### Remember the double equals sign for is equal to!

# With only 11 rows, you can pretty much eyeball how many each won. But that won't always be the case. Either base R's table or janitor's tabyl will tally these for you:

table(results$Winner)

tabyl(results, Winner)

tabyl(results, Borough, Winner)

# Which districts did Crowley win?

filter(results, Winner == "Crowley")


# We can now do some exploratory visualizations of Ocasio-Cortez's winning percentages.

# Like most things in R, there are several different systems for creating visualizations. Base R has one. A package that's very popular with journalists is called ggplot2. I use both pretty often, so I'm going to show you both.

library(ggplot2)

# syntax:
# ggplot(mydata, aes(x = xcolname, y = ycolname)) +
# geom_type_of_chart()

ggplot(results, aes(x = District, y = Pct_Ocasio_Cortez)) +
  geom_col()

# There is a ton more you can do with ggplot! How about color the bars by Borough:
ggplot(results, aes(x = District, y = Pct_Ocasio_Cortez, fill = Borough)) +
  geom_col()

# Blue and red defaults probably aren't the best choices for a Democratic primary. There are built-in palettes with R and a ton of add-on packages. But you can also just use scale_fill_manual and set the colors yourself

ggplot(results, aes(x = District, y = Pct_Ocasio_Cortez, fill = Borough)) +
  geom_col() +
  scale_fill_manual(values = c("darkgreen", "purple"))

# How do you know what color names are available? 

colors()

# You can also use hex colors

ggplot(results, aes(x = District, y = Pct_Ocasio_Cortez, fill = Borough)) +
  geom_col() +
  scale_fill_manual(values = c("darkgreen", "#800000"))


# I realize this is a lot to remember, but you only have to code this *once* and save it, and then you can use the template again and again, just changing the data source and column names.

# Some base R visualizations:

hist(results$Pct_Ocasio_Cortez)

boxplot(results$Pct_Ocasio_Cortez)

# Reminder: In a box plot, half values are higher than the line within the box, and half lower. Top and bottom of the box are the 25% and 75% marks. The "whiskers" show non-outlier high and low values. Dots beyond the whiskers are outliers.

boxplot(results$Pct_Crowley)

#### Merge with demographic data in data/ny_assembly_district_demographics.csv

demo_data <- rio::import("data/ny_assembly_district_demographics.csv")

str(demo_data)

results_plus_demographics <- merge(results, demo_data, all.x = TRUE, all.y = FALSE, by = "District")

# Calculate the actual statistical correlation - predictive only, not causation!

# Additional caution: In a small-turnout election, voters' demographics probably don't match overall demographics. For demonstration (and predictive) purposes only :-)

# I'm interested in seeing how percent Ocasio_Cortez correlates with median household income, percent white, and percent males with a BA or Higher. I'll select just those columns:

correlation_data <- select(results_plus_demographics, Pct_Ocasio_Cortez, Median_Household_Income, Pct_White, Pct_Male_BA_or_Higher)

# As we saw previously, base R's cor() function generates a correlation matrix that shows each variable's correlation with the others. 1 means it goes in perfect sync: Every time variable x increases, variable y increases in the same proportion. -1 means it goes in perfect opposite. 0 means no relation.

# Let's take a look.

cor(correlation_data)

# use package corrplot to visualize

library(corrplot)
my_correlation_matrix <- cor(correlation_data)


# Code that I found, saved, and reuse:
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(my_correlation_matrix, method="shade", shade.col=NA, tl.col="black", tl.srt=45, col=col(200), addCoef.col="black")  

# How best to store and re-call code like this?

#### If time: let's look at RStudio code snippets ####

# Run this:

usethis::edit_rstudio_snippets()

# These are code snippets! 

# Open the file snippet.txt. Copy and paste what's in there into the file that was opened with the edit_rstudio_snippets(). Save and close. 

# Now type (without the # at the start) in your source window
# correlation_plot

# and when you see some sort of match, hit tab and look what happens





# Open the snippet folder again and look at the format of a snippet. It starts with snippet followed by the name of the snippet. All the rest of the lines are regular R code, EACH LINE INDENTED WITH A TAB. IT MUST BE A TAB. You can create variables with ${1:varname}, ${2:varname}, and so on.

# I have a video showing more about them at
# https://www.infoworld.com/video/88435/r-tip-save-time-with-rstudio-code-snippets


#### End code snippets


# Let's do a couple of exploratory scatter plots to look at the percent white vs Ocasio-Cortez results, once again using the taucharts package. 

library(taucharts)

tauchart(results_plus_demographics) %>%
  tau_point(x = "Pct_White", y = "Pct_Ocasio_Cortez") %>%
  tau_tooltip() %>%
  tau_trendline()

tauchart(results_plus_demographics) %>%
  tau_point(x = "Pct_White", y = "Pct_Ocasio_Cortez", color = "Borough") %>%
  tau_tooltip() %>%
  tau_trendline()


# But, as with the last data set, I'm struck by the Percent White vs Median Household Income

tauchart(results_plus_demographics) %>%
  tau_point(x = "Pct_White", y = "Median_Household_Income") %>%
  tau_tooltip() %>%
  tau_trendline()

tauchart(results_plus_demographics) %>%
  tau_point(x = "Pct_White", y = "Median_Household_Income", color = "Borough") %>%
  tau_tooltip() %>%
  tau_trendline()

# Is there such a strong correlation in all of New York State? My demo_data_for_correlation file has demographics for all assembly districts in New York State.

demo_data_for_correlation <- select(demo_data, Pct_White, Median_Household_Income, Pct_Male_BA_or_Higher)
my_correlation_matrix <- cor(demo_data_for_correlation)
corrplot(my_correlation_matrix, method="shade", shade.col=NA, tl.col="black", tl.srt=45, col=col(200), addCoef.col="black")  

tauchart(demo_data) %>%
  tau_point(x = "Pct_White", y = "Median_Household_Income") %>%
  tau_tooltip() %>%
  tau_trendline()


# Sorry don't have time to explain this part in a 3-hour workshop, but it's possible and easy to get a map of legislative districts with R

library(tigris)
library(tmap)

nymap <- state_legislative_districts("NY", house = "lower", class = "sf")
demo_data <- demo_data %>%
  mutate(
   NAMELSAD = stringr::str_replace(District, "AD", "Assembly District")
  )

nymap <- tamptools::append_data(nymap, demo_data)

tm_shape(nymap) +
  tm_polygons("Pct_White", id = "NAMELSAD", palette = "Greens")

tm_shape(nymap) +
  tm_polygons(c("Pct_White", "Median_Household_Income"), id = "NAMELSAD", palette = list("Greens", "Greens")) +
  tm_facets(as.layers = TRUE)


tmap_mode("view")

tmap_last()

# Labeling doesn't work because the districts are too small

tmap_mode("plot")

tm_shape(nymap) +
  tm_polygons("Pct_White", palette = "Greens") +
  tm_text("District", size = .5)



# Speaking of maps, let's map the election results! 

districtmap <- state_legislative_districts("NY", house = "lower", class = "sf") %>%
  mutate(
    District = stringr::str_replace(NAMELSAD, "Assembly District", "AD")
  )
  
map_plus_results <- inner_join(districtmap, results)

tmap_mode("view")

tm_shape(map_plus_results) +
  tm_polygons("Pct_Ocasio_Cortez", id = "District", palette = "Blues") 

# You can save this as an HTML map file. Or, 

tmap_mode("plot")

tmap_last()
results_map <- tmap_last()
tmap_save(results_map, file = "results.png")

# If you just want to look at winners, fill by the column "Winner":

tm_shape(map_plus_results) +
       tm_polygons("Winner", id = "District") 

# possibly want a better palette. How to find a palette? How to find some palettes?

# THIS IS COOL:

tmaptools::palette_explorer()

# We want categories here

tm_shape(map_plus_results) +
  tm_polygons("Winner", id = "District", palette = "Accent")

# Reminder, to make this interactive:

tmap_mode("view")
tmap_last()

# Before we go further, I want to introduce you to six main concepts in dplyr for wrangling data. If you keep them in mind, they'll really help you stop and think through a lot of the steps you need for working with data sets.

# filter - pick rows you want based on a certain criteria.
# select - pick columns you want.
# mutate - add a new calculated column
# arrange - sort by one or more columns
# summarize and group_by - calculate statistics of interest by group

# Let's try a few of these out on the nypoverty data frame.

# Which boroughs have a median gross rent equal to or higher than 30% of household income?

filter(nypoverty, Pct_Income_Rent >= 30)

# What if I just want to see the County and Pct_Income_Rent columns?

select(nypoverty, County, Pct_Income_Rent)

# We can use the %>% pipe function we saw in eye candy to combine these two steps -- filter for percent of income for rent greater than or equal to 30%, and just see the County and Pct_Income_rent columns: 

nypoverty %>%
  filter(Pct_Income_Rent > 30) %>%
  select(County, Pct_Income_Rent)

# This says "Take the nypoverty data and send it to the filter command, where I only want rows where percent income rent is greater than 30. Then, pipe THAT to the select command and only choose the County and Pct_Income_Rent columns.

# We can save the results to a variable instead of printing them out to the screen:

select_poverty_data <- nypoverty %>%
  filter(Pct_Income_Rent > 30) %>%
  select(County, Pct_Income_Rent)

# See the results

select_poverty_data

# Four or five rows doesn't make for a very compelling data set. I've got another file with similar data, but for zip codes in Manhattan.

nyzips <- rio::import("data/manhattan_zip_rent_poverty.xlsx")

# Now let's take a look.

str(nyzips)

# 60 rows with the same 8 variables

# First few lines 

head(nyzips)

# Now we need tail() to check the last few lines

tail(nyzips)

# dplyr's glimpse function gives us a peek at the data

dplyr::glimpse(nyzips)

# What questions might you have about this data set?


# Some ways of looking at the data, including very basic statistical analysis:


summary(nyzips)
Hmisc::describe(nyzips)
skimr::skim(nyzips)



# We can filter for which zip codes have median rent greater or equal to 30% of median income, but you'd just get a list of some zip codes. I'd rather 1) get a count of those above and below, and 2) visualize this to see the distribution of percent income for rent.

# To get a count, it might be useful to first add a column Rent30PctIncome and set the value to TRUE or FALSE depending on whether median rent is indeed at least 30% of income. For that, we'll need R's ifelse function, which uses the syntax ifelse(condition, value if true, value if false). 

nyzips <- nyzips %>%
  mutate(
    Rent30PctIncome = ifelse(Pct_Income_Rent >= 30, TRUE, FALSE)
  )

# There are several ways to get a quick count of the trues and falses here, you can pick the one you like best!

# dplyr package's count function, with the format count(data frame, column name)
count(nyzips, Rent30PctIncome)

# base R's table function, with the format table(vector or data frame column)
table(nyzips$Rent30PctIncome)

# janitor package's tabyl function, with the format tabyl(vector or data frame column)
janitor::tabyl(nyzips$Rent30PctIncome)

# I like tabyl, since it gives percents both including NA not availables and excluding them.

# This might be a good time to get rid of the zip  where the data isn't available. R's NA not available behaves a little differently than most values, and it's important to know. You can't just filter for Pct_Income_Rent == NA or Pct_Income_Rent == "NA". Neither will work. Instead, you need to use the function is.na() which tests whether something is NA. There are other is. functions. You can use is.numeric() to test if something is a number, is.data.frame() to see if it's a data frame, etc. 

# To test if something is NOT NA or a number etc., put a ! in front. That means "not."

# So, to screen out zip codes where the Pct_Income_Rent is unavailable, this works:

nyzips <- filter(nyzips, !is.na(Pct_Income_Rent))

# That says, set the value of nyzips to be nyzips keeping only the rows where Pct_Income_Rent is not NA.

# Two quick base R visualizations to see the distribution of Pct_Income_Rent:

hist(nyzips$Pct_Income_Rent)

# There do seem to be a couple of zip codes where people are paying less than 20% of their income for rent.

boxplot(nyzips$Pct_Income_Rent)

# How to read a box plot? The line is the median -- half values are higher, half lower. Top and bottom of the box are upper & lower quartiles -- upper is 25%, lower is 75%. The "whiskers" represent what are considered non-outlier high and low values. The default calculation for whiskers is 1.5 times the difference between the 75% level and the 25% level, known in stats speak as the "interquartile range." Dots beyond the whiskers are outliers -- those two zip codes where people are paying less than 20% of income for rent.

# Can you write a filter statement to see which ones those are? 



# There's one more problem with the data as it is. If we'd like to check for relationships between things like pverty rates and the white population, we need RATES -- PERCENTAGES -- not raw numbers.

# I'm going to create a new dataframe, nyzips2, and calculate percent poverty and percent white, and then select the columns I want. 

# Percent Poverty would be Poverty_Households / Total_Households, while percent white would be White_Population / Total_Population. This is a job for mutate!

nyzips2 <- nyzips %>%
  mutate(
    Pct_Poverty = Poverty_Households / Total_Households,
    Pct_White = White_Population / Total_Population
  ) %>%
  select(ZipCode, Pct_Income_Rent, Median_Household_Income, Pct_Poverty, Pct_White  )

# If you want it in a nice percent format to 1 decimal place, multiply the result by 100 and then use R's round function. Format for that is round(number, number of decimal places)

nyzips2 <- nyzips %>%
  mutate(
    Pct_Poverty = round((Poverty_Households / Total_Households) * 100, 1),
    Pct_White = round((White_Population / Total_Population) * 100, 1)
  ) %>%
  select(ZipCode, Pct_Income_Rent, Median_Household_Income, Pct_Poverty, Pct_White  )

# Kind of fun: You can make an interactive HTML table out of this data (or any other data frame that's not too large) with one line of code, using the DT package's datatable function:

DT::datatable(nyzips2)

# And you can add search filters for each column with

DT::datatable(nyzips2, filter = 'top')

# If you want column 3 to display with commas, you load the DT library and add a second line
library(DT)
datatable(nyzips2, filter = 'top') %>%
  formatCurrency('Median_Household_Income',currency = "", digits = 0)

# And you can save this to an HTML file!

mytable <- datatable(nyzips2, filter = 'top') %>%
  formatCurrency('Median_Household_Income',currency = "", digits = 0)

htmlwidgets::saveWidget(mytable, "mytable.html")

# Back to the data analysis.

# We can run a single function to check statistical correlations between all the numerical variables. 
# Base R's cor() function generates a correlation matrix 1 means it goes in perfect sync: Every time variable x increases, variable y increases in the same proportion. -1 means it goes in perfect opposite. 0 means no relation.

# Let's take a look.

# We need only numerical data, so let's make a new data frame with just numeric columns. The select function lets us do that without having to name all the columns we want.

correlation_data <- select_if(nyzips2, is.numeric)

# How cool is that?

# Now let's run base R's cor() function

cor(correlation_data)

# Well, that's nice, but kind of hard to see. But there's a great package called corrplot that makes this much more visual.
# Load the library
library(corrplot)

# Run the cor() function again but save it to a variable
my_correlation_matrix <- cor(correlation_data)

# And then ... 

# I found this code once and saved it because I really like the way this works. And I've saved it for multiple use. I don't remember anymore what all these options are. I could look them up, but I don't need to. I know that this is what I want.
# This is just setting the color palette 
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))

# And here's the code
corrplot(my_correlation_matrix, method="shade", shade.col=NA, tl.col="black", tl.srt=45, col=col(200), addCoef.col="black")  


# I'd like to do a couple of exploratory scatter plots to look at the percent white vs Ocasio-Cortez results. I love the taucharts package for this, because it creates a clickable graph and trendlines.

library(taucharts)

tauchart(nyzips2) %>%
  tau_point(x = "Median_Household_Income", y = "Pct_Income_Rent") %>%
  tau_tooltip() %>%
  tau_trendline()

tauchart(nyzips2) %>%
  tau_point(x = "Pct_White", y = "Median_Household_Income") %>%
  tau_tooltip() %>%
  tau_trendline()


# However, I'd be remiss if I didn't show you what is probably the most popular graphing library by far: ggplot2. 

# ggplot2 is based on a theory called the "grammar of graphics" (that's where the gg comes from). Using this "grammar" structure, you first create a simple plot foundation, and then add various attributes, or layers, to bring it to life.

# ggplot2 is the package name, but ggplot() (without the 2) is its key function.

# A ggplot() visualization starts with data (obviously) and a couple of basic "aesthetics" (shortened to aes in code). An aes might assign a data column to the X axis, another data column to the y axis, and maybe another column of data to change the color or size of items in the graph. But **that by itself won't actually display anything.** It just sets up a structural foundation for a graphic, but it doesn't say whether the viz should be a bar chart, a line chart, a scatter plot, etc. 

# Format for a first line of code for a ggplot() graphic is usually something like ggplot(mydata, aes(x=myxcolumn, y=myycolumn)). 

# A second layer with geoms (geometric objects) specifies the *type* of plot you want (line, bar, etc.). geoms are separate functions that start with geom_ such as geom_bar(), geom_boxplot(), geom_histogram(), geom_point(), and so on. 

# So, a basic viz might look something like
  
# ggplot(mydf, aes(x = myxcolumn, y = myycolumn)) +
#  geom_point()

# You need at least these two layers, ggplot() and a geom_ function, in order to display anything. And unlike with dplyr, additional lines of ggplot2 code are added with a `+` sign, not a `%>%` pipe.

# ggplot2 scatter plot:

library(ggplot2)
ggplot(data = nyzips2, aes(x = Pct_White, y = Pct_Poverty)) +
  geom_point()

# Size the dots for median household income

ggplot(data = nyzips2, aes(x = Pct_White, y = Pct_Poverty, size = Median_Household_Income)) +
  geom_point()

# bar chart of Median Household Income

ggplot(data = nyzips2, aes(x = ZipCode, y = Median_Household_Income)) +
  geom_col()

# reorder highest to lowest and a few more tweaks

library(scales)
ggplot(data = nyzips2, aes(x = reorder(ZipCode, -Median_Household_Income), y = Median_Household_Income)) +
  geom_col(fill = "dodgerblue4")  +
  theme_minimal() +
  ggtitle("Median Household Income by Manhattan Zip Code")  +
  xlab("Zip Code") +
  ylab("") +
  scale_y_continuous(label=comma)

# Not ideal, but make it JavaScript with the plotly package

zip_graph <- ggplot(data = nyzips2, aes(x = Pct_White, y = Pct_Poverty, size = Median_Household_Income, text = paste("Pct Income Rent:", Pct_Income_Rent))) +
  geom_point()

library(plotly)
ggplotly(zip_graph)


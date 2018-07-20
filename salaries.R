# August 2018 Intro to R and RStudio
# Sharon Machlis

# If there's extra time

# This data file is a CSV of New York City municipal salary data for FY 2017.
# We are going to use the rio package's "import" function to import the file into an R variable called mydata.

# What's that <- symbol? It means "assign the value of what's on the right to the variable on the left."
# In most cases, you can use an = sign as well. But in certain cases, <- is needed.
# Most R users these days use <-, but if bugs the heck out of you, switch to = for this session so it doesn't distract you.

# This file has more than half a million rows. See how quickly it imports

mydata <- rio::import("data/NYC_Citywide_Payroll_data.csv")

# Let's examine the first and last rows of this data, now in the mydata variable
head(mydata)
tail(mydata)

# R columns shouldn't really have spaces in them. The janitor package's clean_names function will take care of this for us.
mydata <- janitor::clean_names(mydata)

# Let's look at how the data is structured.
str(mydata)


# Uh oh, salary values came in as characters and not numbers, because R didn't understand that the commas in the CSV file signified currency. Fortunately, there's a function to fix this in a package called readr. It's called parse_number()

# Note: There are 2 ways to use a function in an external R package. One is the format we used with rio, which is packageName::functionName(). That just uses the specific function from that package, but doesn't load the whole package with all its other functions into your system's working memory.

# The other way is to load the whole package into memory with library(). That lets you use any of the functions without having to use the packageName:: part. Let's try that with rmiscutils.


library(readr)

# I'm going to create new columns that turn those character columns into numbers:

mydata$reg_hours <- parse_number(mydata$regular_hours)
mydata$reg_pay <- parse_number(mydata$regular_gross_paid)
mydata$ot_hrs <- parse_number(mydata$ot_hours)
mydata$total_ot <- parse_number(mydata$total_ot_paid)
mydata$other_pay <- parse_number(mydata$total_other_pay)

# Reminder: mydata is a "data frame" -- a 2-dimensional data format with rows and columns, similar in some ways to a spreadsheet. The dollar sign is how R refers to a column.

# Another way to do this, very popular with journalists - Hadley Wickham's "tidyverse" dplyr pacage.

library(dplyr)
mydata <- mydata %>%
  mutate(
    reg_hours = parse_number(regular_hours),
    reg_pay = parse_number(regular_gross_paid),
    ot_hrs = parse_number(ot_hours),
    total_ot = parse_number(total_ot_paid),
    other_pay = parse_number(total_other_pay)
  )

# "mutate" means "change the data frame by adding new columns. The code above says
# "I want to assign the mydata variable the value of the existing mydata variable, with these changes: add a salary column that applies the number_with_commas function to annual_salary, and the same with hourly." It would be the same as creating a new column in Excel and then putting a formula in one of the cells using the value of an existing cell.

# It's good practice not to destroy existing data when making changes. But now that we're sure the changes are OK, we can get rid of the old annual_salary and hourly_rate character columns by selecting them with a minus sign before them:

mydata <- select(mydata, -regular_hours, -regular_gross_paid, ot_hours, total_ot_paid, total_other_pay)

# That %>% collection of characters is a "pipe." It just means "take the result of what happened and pipe it into the next set of commands." 

# In the first code block, I had to repeat the name of the data frame, mydata, in every part of the code. In the dplyr code, after using the name of the data frame in the first line, dplyr understands that's the value for the rest, and you don't have to keep writing mydata$salary and mydata$annual_salary, etc. One of the many reasons so many of us love dplyr.



str(mydata)

# What if we want to see just police data? Let's filter the data to take a subset with all rows where the agency_name column equals POLICE DEPARTMENT. When you check "does agency_name equal POLICE DEPARTMENT?" you need double equals signs, not single. (agency_name = "POLICE DEPARTMENT" says "the value of agency_name equals POLICE DEPARTMENT." agency_name == "POLICE DEPARTMENT" tests whether agency equals POLICE DEPARTMENT. This is common in many programming languages, not just R)

police <- filter(mydata, agency_name == "POLICE DEPARTMENT")

# What about police who earn more than $150K regular salary?
police150 <- filter(police, reg_pay > 150000)

# Now let's create an interactive HTML table of that police150 data with one line of code
DT::datatable(police150)

# Want search/filter boxes for each column?
DT::datatable(police150, filter = 'top')

# Would you like to save this table as an HTML page to post on the Web somewhere? Save the table to an R variable -- in this case mytable -- and then use the htmlwidgets package's saveWidget function to save the table to a self-contained HTML page.

mytable <- DT::datatable(police150, filter = 'top')
htmlwidgets::saveWidget(mytable, "police_salaries.html")

# Some more data exploration

# How many employees are there per agency? Base R's table function is one way to see:
table(mydata$agency_name)

# That's sort of tough to deal with. janitor's tabyl returns that nice-to-deal-with data frame:

agency_count <- janitor::tabyl(mydata$agency_name)
agency_count
# Would be kind of annoying to have to run a function manually on each column. There are functions specifically designed to summarize data sets. In base R, it's summary:

summary(mydata)

# Some summary functions can take awhile with large data

skimr::skim(mydata)

# Visualizing can help see distributions. One way is a histogram
hist(mydata$ot_hrs)
hist(mydata$total_ot)
hist(mydata$reg_pay)

# Get rid of scientific notation
options(scipen = 999)
hist(mydata$reg_pay)

# Average & Median Full-Time Salaries BY DEPARTMENT: Filter for salaried employees paid per Annum, group by department, then summarize. na.rm means remove the entries that aren't available. R by default wants to make sure that you know there are missing values. The average of 6, 8, and not available could conceivably be anything, if "not available" actually exists but isn't in your data set.

by_department <- mydata %>%
  filter(pay_basis == "per Annum") %>%
  mutate(
    TotalCompensation = reg_pay + total_ot + other_pay
  ) %>%
  group_by(agency_name) %>%
  summarise(
    Average_Comp = mean(TotalCompensation, na.rm = TRUE),
    Median_Comp = median(TotalCompensation, na.rm = TRUE)
  )



# If you need to get rid of scientific notation:
options(scipen = 999)
hist(by_department$Average_Comp)

# Visualize distribution for salaried employees by department - box plots are another way to do this. Limit to a few agencies or it will be impossible to read
salaried_employees <- mydata %>%
  filter(pay_basis == "per Annum", agency_name %in% c("DEPT OF ED PEDAGOGICAL", "POLICE DEPARTMENT", "FIRE DEPARTMENT", "NYC HOUSING AUTHORITY", "DEPARTMENT OF SANITATION")) %>%
  mutate(
    TotalCompensation = reg_pay + total_ot + other_pay
  )
  

boxplot(TotalCompensation ~ agency_name, data = salaried_employees)

# How to read a box plot? The line is the median -- half values are higher, half lower. Top and bottom of the box are upper & lower quartiles -- upper is 25%, lower is 75%. The "whiskers" represent what are considered non-outlier high and low values. The default calculation for whiskers is 1.5 times the difference between the 75% level and the 25% level, known in stats speak as the "interquartile range."

# Not the easiest to read. 

library(ggplot2)

ggplot(data = salaried_employees, aes(x=agency_name, y = TotalCompensation)) +
  geom_boxplot() +
  coord_flip()

# Easy way to add JavaScript roll-over functions?

library(plotly)


ggplotly(
  
  ggplot(data = salaried_employees, aes(x=agency_name, y = TotalCompensation)) +
    geom_boxplot() +
    coord_flip() 
  
)



# highest median salaries? bar chart

barchart_data <- by_department %>%
  filter(
    agency_name %in% c("DEPT OF ED PEDAGOGICAL", "POLICE DEPARTMENT", "FIRE DEPARTMENT", "NYC HOUSING AUTHORITY", "DEPARTMENT OF SANITATION")
)

ggplot(data = barchart_data, aes(x = agency_name, y = Median_Comp)) +
  geom_col()

# Hard to read that x axis, we'll get to that

# If you wanted the bars ordered from largest to smallest
ggplot(data = barchart_data, aes(x = reorder(agency_name, -Median_Comp), y = Median_Comp)) +
  geom_col()

# Still impossible to read the x axis. Let's get to that. Not intuitive, but I save this theme() snippet for reuse.

ggplot(data = barchart_data, aes(x = reorder(agency_name, -Median_Comp), y = Median_Comp)) +
  geom_col() +
  theme(axis.text.x = element_text(angle = 90, vjust = 1.2, hjust = 1.1))
  
# Make all the bars blue (back to alphabetical order)
ggplot(data = barchart_data, aes(x = agency_name, y = Median_Comp)) +
  geom_col(fill="blue") +
  theme(axis.text.x = element_text(angle = 90, vjust = 1.2, hjust = 1.1))


# Get rid of the trademark grid background, add a title, add commas to y axis
library(scales)

ggplot(data = barchart_data, aes(x = agency_name, y = Median_Comp)) +
  geom_col(fill="blue") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, vjust = .2, hjust = 1.0)) +
  xlab("Department") +
  ylab("") +
  scale_y_continuous(label=comma) +
  ggtitle("NYC Full-Time Workers' Median Salaries")

# plotly works here as well, but I prefer the rcdimple package for bar charts:


library(rcdimple)

barchart_data %>% 
dimple(x = "agency_name", y = "Median_Comp", type = "bar") %>%
add_title("NYC Workers' Median Salaries") %>%
default_colors(c("#0072B2"))

# dimple() is the graphing function. It only does bar, line, area, or bubble charts.


# How do I keep all these packages and functions straight? I write code snippets in RStudio and then re-use them.

# More info at https://support.rstudio.com/hc/en-us/articles/204463668-Code-Snippets

# Gallery of HTML widgets: http://gallery.htmlwidgets.org/
# I play around with them and decide if I want to add any to my toolset.

# highcharter is free for non-profits but costs money for a commercial license for corporations and government agencies.

highcharter::hcboxplot(x = salaried_employees$TotalCompensation, var = salaried_employees$agency_name,
          name = "Salary", color = "#2980b9") 





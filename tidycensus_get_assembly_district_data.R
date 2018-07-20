library(tidycensus)
library(dplyr)
census_api_key("YOUR_CENSUS_API_KEY")

# x <- load_variables(2016, "acs5")
# available geographies: https://walkerke.github.io/tidycensus/articles/basic-usage.html#geography-in-tidycensus

assembly_district_data <- get_acs(geography = "state legislative district (lower chamber)", variables = c("B02001_001E", "B02001_002E", "B19013_001E", "C15002H_002E", "C15002H_006E"), state = "New York", year = 2016)



lookup_census_variables <- x$label
names(lookup_census_variables) <- stringr::str_replace_all(x$name, "E$", "")

assembly_district_ny_data <- assembly_district_data 
assembly_district_ny_data$Characteristic <- purrr::map_chr(assembly_district_ny_data$variable, ~unname(lookup_census_variables[.]))
  
assembly_district_wide <- assembly_district_ny_data %>%
  select(NAME, Characteristic, estimate) %>%
  rename(District = NAME, Estimate = estimate) %>%
  tidyr::spread(Characteristic, Estimate)

names(assembly_district_wide) <- c("NYDistrict", "Median_Household_Income", "Total_Population", "Total_Male_25_and_Over", "Male_With_BA_or_Higher", "Total_White")  

assembly_district_wide <- assembly_district_wide %>%
  select("NYDistrict", "Total_Population", "Total_White", "Median_Household_Income", "Total_Male_25_and_Over", "Male_With_BA_or_Higher") %>%
  mutate(
    Pct_White = round((Total_White / Total_Population) * 100, 1),
    Pct_Male_BA_or_Higher = round((Male_With_BA_or_Higher / Total_Male_25_and_Over) * 100, 1),
    District = stringr::str_replace_all(NYDistrict, "Assembly District (.*?) \\(2016\\), New York", "\\1"),
    District = paste("AD", District)
  )

rio::export(assembly_district_wide, file = "data/ny_assembly_district_demographics.csv")

library(tigris)

#### Rent and Poverty Info ####

pct_income_rent <- "B25071_001E"
rental_data <- get_acs(geography = "county", state = "New York", variables = pct_income_rent)

poverty_households <- "B17020_002E"
non_poverty_hoseholds <- "B17020_010E"
total_households <- "B17020_001E"
pov <- c(poverty_households, non_poverty_hoseholds, total_households)
poverty_data <- get_acs(geography = "county", state = "New York", variables = pov)

race_white <- "B02001_002E"
race_total <- "B02001_001E"

median_household_income <- "B19013_001E"

all_rent_poverty <- get_acs(geography = "county", state = "New York", variables = c(pct_income_rent, pov, race_white, race_total, median_household_income), output = "wide")

names(all_rent_poverty) <- c(
  "GEOID",
  "County",
  "Pct_Income_Rent",
  "MOE_Pct_Income_Rent",
  "Poverty_Households",
  "MOE_Poverty_Households",
  "Non_Poverty_Households",
  "MOE_Non_Poverty_Households",
  "Total_Households",
  "MOE_Total_Households",
  "White_Population",
  "MOE_White_Population",
  "Total_Population",
  "MOE_Total_Population",
  "Median_Household_Income",
  "MOE_Median_Household_Income"
)

ny_rent_poverty <- all_rent_poverty %>%
  select(County, Pct_Income_Rent, Poverty_Households, Non_Poverty_Households, Total_Households, White_Population, Total_Population, Median_Household_Income) %>%
  mutate(
    County = stringr::str_replace(County, " County\\, New York", "")
  ) %>%
  filter(County %in% c("New York", "Kings", "Queens", "Bronx", "Richmond"))
  

rio::export(ny_rent_poverty, file = "data/ny_county_rent_poverty.xlsx")

zipcode_rent_poverty <- get_acs(geography = "zcta", county = "New York", variables = c(pct_income_rent, pov, race_white, race_total, median_household_income), output = "wide")

source("manhattan_zips.R")
manhattan_rent_poverty_df <- zipcode_rent_poverty %>%
  mutate(
    ZipCode = stringr::str_replace(NAME, "ZCTA5 ", "")
  ) %>%
  filter(ZipCode %in% manhattan_zips)

names(manhattan_rent_poverty_df) <- c(
  "GEOID",
  "NAME",
  "Pct_Income_Rent",
  "MOE_Pct_Income_Rent",
  "Poverty_Households",
  "MOE_Poverty_Households",
  "Non_Poverty_Households",
  "MOE_Non_Poverty_Households",
  "Total_Households",
  "MOE_Total_Households",
  "White_Population",
  "MOE_White_Population",
  "Total_Population",
  "MOE_Total_Population",
  "Median_Household_Income",
  "MOE_Median_Household_Income",
  "ZipCode"
)

library(magrittr)
manhattan_rent_poverty_df %<>% select(ZipCode, Pct_Income_Rent, Poverty_Households, Non_Poverty_Households, Total_Households, White_Population, Total_Population, Median_Household_Income) 

rio::export(manhattan_rent_poverty_df, file = "data/manhattan_zip_rent_poverty.xlsx")

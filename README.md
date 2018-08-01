# Intro to R and RStudio
## August 2018 Workshop
### Sharon Machlis

This repo includes R scripts and data for an R hands-on workshop I'm presenting to a newsroom in New York.

For more resources on learning R, please check out my recommendations at Computerworld, [Top R language resources to improve your data skills](https://www.computerworld.com/article/2497464/business-intelligence/top-r-language-resources-to-improve-your-data-skills.html).

Here's how to install and use the files.

1. Download R from [https://cran.rstudio.com/](https://cran.rstudio.com/), choosing the binary distribution for your operating system. Install it as you would any other software program.

2. Download the free, open-source version of RStudio Desktop (not server) from the [RStudio website](https://www.rstudio.com/products/rstudio/download/). Install it as you would any other software program.

3. Open RStudio. Type the following line of code in the bottom left panel at the `>` prompt (it may just be one large panel at the left instead of a top and bottom):

```
install.packages("usethis")
```

and hit return or enter. This installs an external R library called usethis for downloading the entire workshop repository from GitHub.


4. When that finishes, type (or cut and paste) this code at the `>` prompt:

```
usethis::use_course("https://github.com/smach/Workshop201808/archive/master.zip")
```
This should download all the session files to your system, and create a new project for them within RStudio. You'll be asked if you want to proceed with the download (choose yes) and whether you want to subsequently delete the zip file after it's unzipped (you probably do).

RStudio should now open in the directory containing your new project files. If it hasn't, find the Workshop201808.Rproj file and click to open that.

5. At the `>` prompt in your lower left pane, type:

```
source("config.R")
```

and hit return or enter. That should load all the other R packages you need for the session.

We'll be using the script files in the following order:

* intro.R
* eyecandy.R
* intro2.R
* primary_analysis.R

I've got 2 additional files in there in the unlikely event there's still time left to do more.

* flight_delays.R
* salaries.R (from an earlier NICAR session that I updated with NY data instead of Chicago data)

You may want to play with those on your own time if (as I expect) we don't have time to go over them at the workshop.






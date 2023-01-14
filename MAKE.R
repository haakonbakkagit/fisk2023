## Description ----
# This is a non-standard (written in R) MAKE-file
# A MAKE-file is a file that creates every output in the repository

## Dependencies ----
# Please install the following programs and packages
# Install R and Rstudio
# If Quarto is not automatically installed, install it
# When you run the code, if you get errors that R packages are not installed, 
# install them and try again

## Working directory
# The code assumes that you run it from the root folder of the repository
stopifnot(file.exists("MAKE.R"))

### Run scripts ----

## Delete all variables between each script to make sure they are independent
rm(list=ls())
setwd("Scripts-biomass")
source("C452-data-clean.R", encoding = "UTF-8")

rm(list=ls())

rmarkdown::render("C451-data-visual.Qmd", 
                  output_file="C451-data-visual.html",
                  output_dir = "../Results-biomass/")

if (!file.exists("MAKE.R")) setwd("../")

### End ----
print("Make ran successfully!")




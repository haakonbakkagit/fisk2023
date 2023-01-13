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
stopifnot(file.exists("hi"))

## Run scripts ----
# Delete all variables between each script to make sure they are independent

rm(list=ls())


rm(list=ls())

## End ----
print("Make ran successfully!")




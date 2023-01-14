### Description ----
# In this file we anser the problems

stopifnot(file.exists("C453-model1.R"))

library(openxlsx)

### Load data ----

file1 = "../Results-biomass/C452-df1-transf.xlsx"
if(!file.exists(file1)) stop("Please run 452 first!")
df1=read.xlsx(file1, sheet=1)
file2 = "../Results-biomass/C452-df2-transf.xlsx"
df2=read.xlsx(file2, sheet=1)

### INPUT Constants
# Feel free to change these and rerun the code
harvest.cutoff.kg = 4
# - Recommended value: 4

## Question 1 ----
# total harvestable biomass (fish larger than 4kg) for these months?

## Decision: Use the correct mean instead of the rounded
## Percentage above cutoff value
perc.above.cut0 = 1 - pnorm(harvest.cutoff.kg, mean=df2$Biom.per.ind, 
                               sd = df2$Biom.sd.from.df1)

## Local functions where value is picked dynamically from local environment
local.dnorm = function(x) dnorm(x, mean, sd)
local.xdnorm = function(x) x*dnorm(x, mean, sd)

df2$perc.above.cut = NA

for (i.row in 1:nrow(df2)) {
  mean = df2$Biom.per.ind[i.row]
  sd = df2$Biom.sd.from.df1[i.row]
  ## compute the integral
  intgr = integrate(local.dnorm, lower=harvest.cutoff.kg, upper=mean+10*sd)
  stopifnot(intgr$abs.error < 0.01)
  df2$perc.above.cut[i.row] = intgr$value
}

if (F) {
  ## Test
  df2$perc.above.cut
  ## should equal
  perc.above.cut0
}



## Question 2 ----
# What is the average weight of these (harvestable) fish?






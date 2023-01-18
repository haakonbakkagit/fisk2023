### Description ----
# In this file we clean the data
# We also transform the data! (NB!!)

stopifnot(file.exists("C452-data-clean.R"))
library(openxlsx)

## Load data ----

file1 = "../Data/Data.xlsx"
stopifnot(file.exists(file1))
df1=read.xlsx(file1, sheet=1)
df2=read.xlsx(file1, sheet=2)

## Clean df1 ----

names(df1)[2]
names(df1)[2] = "Std.sigma"

## These numbers are meant to be exactly round
df1$Average.weight = round(df1$Average.weight, digits = 1)

## Clean df2 ----

names(df2)[1]
names(df2)[1] = "Month.name"

### Transform df2 ----
df2$Month.ind = 1:12
df2$Biom.per.ind = df2$Biomass/df2$Number.of.individuals

## Round the number, standard rounding rules
df2$Biom.p.i.rnd = round(df2$Biom.per.ind, digits = 1)

## Find matching stdev
## Where in df1 do we find the correct stdev?
which.row = match(x = df2$Biom.p.i.rnd, table = df1$Average.weight)
## Use that
df2$Biom.sd.from.df1 = df1$Std.sigma[which.row]

## Later: Possible improvement: Weighted average of the two nearby values


### Save data ----
folder = "../Results-biomass/"
dir.create(folder, showWarnings = FALSE)

filename="C452-df1-transf.xlsx"
write.xlsx(df1, file = paste0(folder, filename))

filename="C452-df2-transf.xlsx"
write.xlsx(df2, file = paste0(folder, filename))

### END ----

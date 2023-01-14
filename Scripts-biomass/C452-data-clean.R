### Description ----
# In this file we clean the data
# We also transform the data! (NB!!)

stopifnot(file.exists("C452-data-clean.R"))

## Load data ----

file1 = "../Data/Data.xlsx"
stopifnot(file.exists(file1))
df1=read.xlsx(file1, sheet=1)
df2=read.xlsx(file1, sheet=2)

## Clean df1 ----

names(df1)[2]
names(df1)[2] = "Std.sigma"

## Clean df2 ----

names(df2)[1]
names(df2)[1] = "Month.name"

## Transform df2 ----
df2$Month.ind = 1:12
df2$Biom.per.ind = df2$Biomass/df2$Number.of.individuals

## Save data
folder = "../Results-biomass/"
dir.create(folder, showWarnings = FALSE)

filename="C452-df1-transf.xlsx"
write.xlsx(df1, file = paste0(folder, filename))

filename="C452-df2-transf.xlsx"
write.xlsx(df2, file = paste0(folder, filename))



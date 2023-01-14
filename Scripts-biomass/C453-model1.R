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
## How many (n) discretisation bins in the simulation problem?
n.sim.disc.bins = 1000
# - Higher -> more accurate
# - Lower -> faster
## How fast do the fisg grow in the simulation?
sim.growth.factor = 1.112
# - Recommended: 11.2% -> factor is 1.112

## Question 0 and 1 ----
# total harvestable biomass (fish larger than 4kg) for these months?

## Decision: Use the correct mean instead of the rounded
## Percentage above cutoff value
perc.above.cut0 = 1 - pnorm(harvest.cutoff.kg, mean=df2$Biom.per.ind, 
                               sd = df2$Biom.sd.from.df1)

## Local functions where value is picked dynamically from local environment
local.dnorm = function(x) dnorm(x, mean, sd)
local.xdnorm = function(x) x*dnorm(x, mean, sd)

df2$perc.above.cut = NA
df2$exp.biom = NA

for (i.row in 1:nrow(df2)) {
  mean = df2$Biom.per.ind[i.row]
  sd = df2$Biom.sd.from.df1[i.row]
  ## Compute the integral to get probability of picking 1 slaughter ind
  intgr1 = integrate(local.dnorm, lower=harvest.cutoff.kg, upper=mean+10*sd)
  stopifnot(intgr1$abs.error < 0.01)
  df2$perc.above.cut[i.row] = intgr1$value
  ## Integral for expected slaughter biomass for 1 pick
  intgr2 = integrate(local.xdnorm, lower=harvest.cutoff.kg, upper=mean+10*sd)
  stopifnot(intgr2$abs.error < 1)
  df2$exp.biom[i.row] = intgr2$value
}



## Average weight of harvestable fish:
##TODO: ISSUE: This could be unstable for biomass close to cutoff!!
df2$exp.biom/df2$perc.above.cut

## Total harvestable biomass
df2$exp.biom*df2$Number.of.individuals

## Percent of biomass that will be harvested
round(df2$exp.biom*df2$Number.of.individuals/df2$Biomass, 2)*100



if (F) {
  ## Test
  df2$perc.above.cut
  ## should equal
  perc.above.cut0
}



## Question 2 ----
# Assuming you only know the biomass and number of individuals at the start of 
## the first month (from Table 2). Assume a growth rate of 11,2%. How much will 
## be harvested during the next 12 months, if we assume that all fish over 4kg 
## will be harvested at the end of each month?

## ASSUMPTION: Every individual grows with exactly 11.2%
## Unrealistic, but maybe good approximation

## TODO NOTE: This will not be consistent with df1!


## Values of initial time point
mean = df2$Biom.per.ind[1]
sd = df2$Biom.sd.from.df1[1]

## x values
sim.kg.start = seq(0, mean+5*sd, length.out=n.sim.disc.bins)
## remove 0 kg category:
sim.kg.start = sim.kg.start[-1]

## Discrete probability distribution
d.discrete = dnorm(sim.kg.start, mean, sd=sd)
d.discrete = d.discrete/sum(d.discrete)

## Individuals, not rounded
## Important to not round, otherwise approx becomes bad
individuals = d.discrete*df2$Number.of.individuals[1]

if (F) {
  ## check
  plot(sim.kg.start, d.discrete)
  plot(sim.kg.start, individuals)
}

sim.individuals = individuals

## Create a summary dataframe with results
summ = data.frame(month=1:12, 
                         individ.start=NA, 
                         biomass.start=NA, biomass.growth = NA,
                         harvest.ind=NA, harvest.biom=NA)
# check summ$individ.start[1] = df2$Number.of.individuals[1]


## Start with all fish being alive
is.alive = rep(T, length=length(sim.individuals))


## Add all the other months
for (i.m in 1:12) {
  ## i.m is the month index
  
  ## Beginning of this month
  ## is.alive are alive
  summ$individ.start[i.m] = sum(sim.individuals[is.alive])
  summ$biomass.start[i.m] = sum(sim.individuals[is.alive]*
                                  sim.kg.start[is.alive]*
                                  sim.growth.factor^i.m)
  
  
  ## Near end of this month
  ## Do growth, before harvest/slaughter
  pre.harvest.kg = sim.kg.start*sim.growth.factor^i.m
  
  
  ## Harvest
  is.this.harvest = (pre.harvest.kg > harvest.cutoff.kg) & is.alive
  num.xgrid = sum(is.this.harvest)
  
  summ$harvest.ind[i.m] = sum(sim.individuals[is.this.harvest])
  
  summ$harvest.biom[i.m] = sum(
    pre.harvest.kg[is.this.harvest]*sim.individuals[is.this.harvest])
  
  ## Beginning of next month: 
  ## After harvest
  is.alive = (pre.harvest.kg <= harvest.cutoff.kg)
  
  
  
}

summ$harvest.kg.per.ind = summ$harvest.biom/summ$harvest.ind

summ$biomass.growth = summ$biomass.start*sim.growth.factor

summ2 = summ
summ2$individ.start = round(summ2$individ.start)
summ2$biomass.start = round(summ2$biomass.start)
summ2$biomass.growth = round(summ2$biomass.growth)
summ2$harvest.ind = round(summ2$harvest.ind)
summ2$harvest.biom = round(summ2$harvest.biom)
summ2$harvest.kg.per.ind = round(summ2$harvest.kg.per.ind, 2)


summ2



### Improvements ----

#TODO: Maybe: Replace 12 with sim.max.month


### END ----


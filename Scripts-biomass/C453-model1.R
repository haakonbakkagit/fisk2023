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
sim.growth.factor = 0.112
# - Recommended: 11.2% -> 0.112

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
  stopifnot(intgr$abs.error < 0.01)
  df2$perc.above.cut[i.row] = intgr1$value
  ## Integral for expected slaughter biomass for 1 pick
  intgr2 = integrate(local.xdnorm, lower=harvest.cutoff.kg, upper=mean+10*sd)
  stopifnot(intgr$abs.error < 1)
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
kg.vals = seq(mean-5*sd, mean+5*sd, length.out=n.sim.disc.bins)

## Discrete probability distribution
d.discrete = dnorm(kg.vals, mean, sd=sd)
d.discrete = d.discrete/sum(d.discrete)

## Individuals, not rounded
## Important to not round, otherwise approx becomes bad
individuals = d.discrete*df2$Number.of.individuals[1]

if (F) {
  ## check
  plot(kg.vals, d.discrete)
  plot(kg.vals, individuals)
}

sim.individuals = individuals

## Create two full matrices, for easy summarisation later
## Represent dead individuals as 0 kg

## Simulation number of individuals at start of month 
## (after slaughter)
sim.kg.start = matrix(0, ncol=12+1, nrow=length(sim.individuals))
sim.kg.start[, 1] = kg.vals
## Simulation number of individuals near the end of month
## (just before slaughter)
sim.kg.ne = matrix(0, ncol=12, nrow=length(sim.individuals))


## Add all the other months
for (i.m in 1:12) {
  ## i.m is the month index
  
  ## Near end of this month
  ## Do growth (not slaughter)
  sim.kg.ne[, i.m] = sim.kg.start[, i.m]*sim.growth.factor
  
  ## Beginning of next month: 
  ## Do slaughter
  sim.kg.start[, i.m+1] = sim.kg.ne[,i.m]
  sim.kg.start[, i.m+1][sim.kg.start[, i.m+1]>= harvest.cutoff.kg] = 0
  ## Here, slaughtered individuals are represented as 0 kg
  
}


sim.kg.start[1:5, 1:5]
sim.kg.ne[1:5, 1:5]


### Improvements ----

#TODO: Maybe: Replace 12 with sim.max.month
#TODO: Maybe: Make code efficient, the full matrices are not needed


### END ----


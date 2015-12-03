
# Notes toward master rhizotron data read-in-and-prep-for-whatever-stats-your do:
# Should eventually include:
# 	Read in clean files
# 	Set datatypes / set factor levels / re-tidy as needed
# 	Set up any relevant contrast matrices
#	Convert volumes to some other unit?
#	Test:
#		Does diameter differ with depth/species/season? Is diameter underestimation responsible for near-surface detection problems?

# Notes from exploratory plotting:
# --detection probability seems to be ~independent of crop (see 2014 rhizo-vs-tractor comparison -- no clear separation between point clouds)

# --2010 diameters have clear bands through them! Probable sloppy tracing.



# library(dplyr)
# library(lubridate)

wzclass = read.csv("../scripts/rhizo_colClasses.csv", as.is=TRUE)
strp10 = read.csv("../data/stripped2010.csv", colClasses=wzclass$class)
strp11 = read.csv("../data/stripped2011.csv", colClasses=wzclass$class)
strp12 = read.csv("../data/stripped2012.csv", colClasses=wzclass$class)
strp13 = read.csv("../data/stripped2013.csv", colClasses=wzclass$class)
strp14 = read.csv("../data/stripped2014.csv", colClasses=wzclass$class)
levels(strp10$Species)[1] = "Soy"
levels(strp11$Species)[1] = "Maize"
levels(strp12$Species)[1] = "Maize"
levels(strp13$Species)[1] = "Soy"
levels(strp14$Species)[1] = "Maize"

strpall = rbind(strp10, strp11, strp12, strp13, strp14)
rm(list=c("wzclass", "strp10", "strp11", "strp12", "strp13", "strp14"))

#strpall$Year = year(strpall$DateTime))
# Or when lubridate's not available...
# Yes, POSIXlt years really are since 1900. Gross.
strpall$Year = as.POSIXlt(strpall$DateTime)$year + 1900

# Order species for convenient interpretataion of Helmert contrasts:
strpall$Species=reorder(strpall$Species, match(strpall$Species, c("Soy", "Maize", "Switchgrass", "Miscanthus", "Prairie")))

# unique(data.frame(model.matrix(lm(rootvol.mm3.mm2~Species, strpall, contrasts=list(Species=matrix(
# 	data=c(
# 	1,-1,0,0,0,
# 	3,3,-2,-2,-2,
# 	0,0,1,1,-2,
# 	0,-3,1,1,1 ),
# 	nrow=5, byrow=FALSE)))), strpall$Species))
#      X.Intercept. Species1 Species2 Species3 Species4 strpall.Species
# 1               1        1        3        0        0             Soy
# 1511            1        0       -2        1        1      Miscanthus
# 2947            1        0       -2        1        1     Switchgrass
# 4433            1        0       -2       -2        1         Prairie
# 6220            1       -1        3        0       -3           Maize

# NEXT: Figure out how to check if root *diameter* accounts for underdetection near surface
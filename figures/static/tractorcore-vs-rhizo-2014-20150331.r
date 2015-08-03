library(ggplot2)
library(grid)
library(plotrix) # for std.error()
source("~/R/DeLuciatoR/ggthemes.r")
source("~/R/ggplot-ticks/mirror.ticks.r")
theme_set(theme_ggEHD())

## Read in data.
# If changing sources, note the tractor core data are irregularly formatted -- I doubt any other core data will match it well enough to work without changes.
tc = read.csv("~/UI/efrhizo/rawdata/Tractor-Core-Biomass-2014.csv")
rz = read.csv("~/UI/efrhizo/data/stripped2014.csv")


## Format rhizotron data

# Throw out images form depths <=0. In 2014 this eliminates three frames with nonzero root volume, which probably are really belowground and were just victims of slop in estimating offset, but we don't have a systematic way to tell which are real and which aren't.
rz = rz[rz$Depth > 0,]

levels(rz$Species)[1] = "Corn" # was "Cornsoy"

# match image depths to coring depths
# kind of a roundabout method, but hey.
rz$Horizon = cut(rz$Depth, c(unique(tc$Upper),1e6))
levels(rz$Horizon) = sort(unique(tc$Upper))
rz$Horizon = as.numeric(as.character(rz$Horizon))

# Convert root image data from visible volume per unit image area
# to assumed grams per assumed cm^3.
# Both these assumptions are literature values and could be way off!
rz$rootest.g.cm3 = (
	rz$rootvol.mm3.mm2
	/ 0.78 # mm depth of field, Taylor et al 2014 10.1007/s11104-013-1930-7
	# * (1000 (mm3 view)/(cm3 view)) * ((1/1000) (cm3 root)/(mm3 root)) => no-op
	* 0.2) # g root / cm3, see unit-conversions.txt for some conversion factors

# Compute block mean/se of imaged root ""mass"" within each horizon
rz.blockmean = aggregate(
	formula=rootest.g.cm3 ~ Block + Species + Horizon,
	data=rz,
	FUN=function(x)mean(x, na.rm=TRUE),
	na.action=na.pass)
rz.blockse = aggregate(
	formula=rootest.g.cm3 ~ Block + Species + Horizon,
	data=rz,
	FUN=function(x)std.error(x, na.rm=TRUE),
	na.action=na.pass)
rz.avg = cbind(rz.blockmean, rz.blockse$rootest.g.cm3)
names(rz.avg) = c("Block", "Treatment", "Horizon", "RhizoMassMean", "RhizoMassSE")


## Now format core data

# Calculate volume of soil that each sample came from...
# First, how many cores?
tc$NumCores = ifelse(
	tc$Notes == "Only 2 Cores Taken",
	2,
	3)

# Now how much area per core?
# should equal 0.001134115 m^2, but I'll be stubborn and extract it from the data.
AreaPerCore = mean(c(tc$Core.Area.3.Cores[[1]]/3, tc$Core.Area.2.Cores[[1]]/2))
AreaPerCore = AreaPerCore * 10000 # m^2 to cm^2

# Last, how long were the cores from each layer?
# N.B. Soil.Length is TOTAL length, in this horizon, of all 2 or 3 cores pooled in this sample, e.g. 10 cm * 3 cores = 30 cm in 0-10 layer.
tc$Biomass.g.cm3 = tc$Total.Mass/((tc$NumCores * AreaPerCore) * tc$Soil.Length )

# Compute block mean/se of root mas per cm^2 in each horizon
tc.blockmean = aggregate(
	formula=Biomass.g.cm3 ~ Block + Treatment + Upper,
	data=tc,
	FUN=function(x)mean(x,na.rm=TRUE),
	na.action=na.pass)
tc.blockse = aggregate(
	formula=Biomass.g.cm3 ~ Block + Treatment + Upper,
	data=tc,
	FUN=function(x)std.error(x,na.rm=TRUE),
	na.action=na.pass)
tc.avg = cbind(tc.blockmean, se=tc.blockse$Biomass.g.cm3)
names(tc.avg) = c("Block", "Treatment", "Horizon", "CoreMassMean", "CoreMassSE")

both.avg = merge(tc.avg, rz.avg, all=TRUE)

# Scatterplot of block-mean core vs rhizotron estimates,
# facetting by depth.
#saved this as ~/UI/efrhizo/static/tractor-vs-rhizo.pdf for lab meeting
plot(mirror.ticks(
 	ggplot(both.avg, aes(
 		x=CoreMassMean, 
		y=RhizoMassMean,
		# ymax=RhizoMassMean+RhizoMassSE,
		# ymin=RhizoMassMean-RhizoMassSE,
 		# xmax=CoreMassMean+CoreMassSE,
 		# xmin=CoreMassMean-CoreMassSE,
 		color=Treatment))
	+geom_point()
	#+geom_errorbar()
	#+geom_errorbarh()
	+geom_smooth(aes(group=Horizon), method="lm")
	+facet_wrap(~Horizon, scales="free")
	+ylab(expression(paste("Rhizotron, g ", cm^"-3")))
	+xlab(expression(paste("Cores, g ", cm^"-3")))
	+theme(legend.position=c(0.8, 0.3))
))

# Scatterplot of block-mean core vs rhizotron estimates,
# color-coding by whether they're from the surface layer
# (= presumed underestimated by rhizotron)
# or deeper (=presumed ought to match if we do the conversion right)
plot(mirror.ticks(
	ggplot(both.avg, aes(
		x=CoreMassMean,
		y=RhizoMassMean,
		color=(Horizon==0)))
	+geom_point()
	+facet_wrap(~Treatment)
	+geom_smooth(method="lm")
	+xlab(expression(paste("Cores, g ", cm^"-3")))
	+ylab(expression(paste(
		"Rhizotron, g ", cm^"-3",
		" [@ RTD=0.2 g ", cm^"-3",  " & DOV=0.78 mm]")))
	+geom_abline(
		xintercept=0,
		slope=1)
	+scale_color_discrete(
		name="Layer",
		labels=c("all others", "0-10"))
))

# didn't save this one -- only marginally useful.
(ggplot(both.avg, aes(Horizon, y=RhizoVolMean*10000, ymax=RhizoVolMean*10000+RhizoVolSE*10000, ymin=RhizoVolMean*10000-RhizoVolSE*10000))
	+geom_errorbar()
	+geom_smooth()
	+geom_errorbar(aes(y=CoreMassMean, ymax=CoreMassMean+CoreMassSE, ymin=CoreMassMean-CoreMassSE), color="red")
	+geom_smooth(aes(y=CoreMassMean),color="red")
	+facet_grid(Treatment~Block)
	+coord_flip()
	+scale_x_reverse())
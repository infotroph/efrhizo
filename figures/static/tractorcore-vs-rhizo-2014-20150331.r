library(ggplot2)
library(grid)
library(plotrix) # for std.error()
source("~/R/DeLuciatoR/ggthemes.r")
source("~/R/ggplot-ticks/mirror.ticks.r")
theme_set(theme_ggEHD())

tc = read.csv("~/UI/efrhizo/rawdata/Tractor-Core-Biomass-2014.csv")
rz = read.csv("~/UI/efrhizo/data/stripped2014.csv")

# Throw out depths <=0. In 2014 this eliminates three frames with nonzero root volume, which probably are really belowground and were just victims of slop in estimating offset, but we don't have a systematic way to tell which are real and which aren't.
rz = rz[rz$Depth > 0,]

levels(rz$Species)[1] = "Corn" # was "Cornsoy"

# match image depths to coring depths
# kind of a roundabout method, but hey.
rz$Horizon = cut(rz$Depth, c(unique(tc$Upper),1e6))
levels(rz$Horizon) = sort(unique(tc$Upper))
rz$Horizon = as.numeric(as.character(rz$Horizon))

rz.blockmean = aggregate(
	formula=rootvol.mm3.mm2 ~ Block + Species + Horizon,
	data=rz,
	FUN=mean)
rz.blockse = aggregate(
	formula=rootvol.mm3.mm2 ~ Block + Species + Horizon,
	data=rz,
	FUN=std.error)
rz.avg = cbind(rz.blockmean, rz.blockse$rootvol.mm3.mm2)
names(rz.avg) = c("Block", "Treatment", "Horizon", "RhizoVolMean", "RhizoVolSE")

tc.blockmean = aggregate(
	formula=Belowground.Biomass..g.m2. ~ Block + Treatment + Upper,
	data=tc,
	FUN=mean)
tc.blockse = aggregate(
	formula=Belowground.Biomass..g.m2. ~ Block + Treatment + Upper,
	data=tc,
	FUN=std.error)
tc.avg = cbind(tc.blockmean, se=tc.blockse$Belowground.Biomass..g.m2.)
names(tc.avg) = c("Block", "Treatment", "Horizon", "CoreMassMean", "CoreMassSE")

both.avg = merge(tc.avg, rz.avg, all=TRUE)

#saved this as ~/UI/efrhizo/static/tractor-vs-rhizo.pdf for lab meeting
plot(mirror.ticks(
 	ggplot(both.avg, aes(
 		x=CoreMassMean, 
 		y=RhizoVolMean,
 		# ymax=RhizoVolMean+RhizoVolSE,
 		# ymin=RhizoVolMean-RhizoVolSE,
 		# xmax=CoreMassMean+CoreMassSE,
 		# xmin=CoreMassMean-CoreMassSE,
 		color=Treatment))
	+geom_point()
	#+geom_errorbar()
	#+geom_errorbarh()
	+geom_smooth(aes(group=Horizon), method="lm")
	+facet_wrap(~Horizon, scales="free")
	+ylab(expression(paste("Rhizotron, ", mm^3, " ", mm^"-2" )))
	+xlab(expression(paste("Cores, g ", m^"-2")))
	+theme(legend.position=c(0.8, 0.3))
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
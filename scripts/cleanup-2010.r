require(rhizoFuncs)

raw.2010 = read.delim("../data/2010/ef2010-allframetots.txt")
raw.2010 = make.datetimes(raw.2010)

# Delete all Loc 1 records (none show roots)
# and any misplaced frames (e.g. 9, 13)
#
# ...Okay, one loc 1 image with traced roots -- 
# T75 L001, 2010-10-14. 
# Turns out this tube is missing tape and there is actually a visible root, 
# but all other L001s have no roots (taped over). OK to delete all Loc 1 records.

raw.2010 = droplevels(raw.2010[raw.2010$Location %in% seq(5,120,5),])

# Censor all images that were too low-quality to trace
censor.2010 = read.csv("../data/2010/2010-censorframes.csv")
censor.2010$date = as.Date(censor.2010$date)
censor.2010 = censor.2010[order(censor.2010$date, censor.2010$tube, censor.2010$loc),]
raw.to.censor.2010 = (
	paste(raw.2010$Date, raw.2010$Tube, raw.2010$Location) 
	%in% paste(censor.2010$date, censor.2010$tube, censor.2010$loc))
raw.2010 = droplevels(raw.2010[!raw.to.censor.2010,])
rm(raw.to.censor.2010)

# Sort by order of tracing (required by strip.tracing.dups)
raw.2010 = raw.2010[order(raw.2010$MeasDateTime),]

# Drop duplicates: 
# silently if only one is reasonable, 
# with warning if several candidates might be correct.
noeasy.2010.by = by(raw.2010, raw.2010$Img, strip.tracing.dups)
noeasy.2010 = do.call(rbind, noeasy.2010.by)
rm(noeasy.2010.by)

# Returns many warnings about multiple calibrations.
#Current thought: 2010 calibrations are very consistent within each month, 
# and most likely error is to use calibration for a different day in same month,
# so don't worry about them. Need to check this more formally.

noeasy.2010$Month = months(noeasy.2010$Date)
noeasy.2010$Block = assign.block(noeasy.2010$Tube)
noeasy.2010$Species = assign.species(noeasy.2010$Tube)
noeasy.2010$Depth = loc.to.depth(noeasy.2010$Location)
noeasy.2010$rootvol.mm3.mm2 = with(noeasy.2010, 
 	rootvol.perarea(TotVolume.mm3, PxSizeH, PxSizeV))
# normed.2010 = normalize.soilvol(noeasy.2010)

# Which images have duplicates? (is this useful at all?)
# dupimg.2010 = tapply(raw.2010$Img, raw.2010$Img, length)
# dupimg.2010 = dupimg.2010[dupimg.2010>1]
# dupimg.2010 = data.frame(img=names(dupimg.2010), n=dupimg.2010, stringsAsFactors=FALSE)


# There were at one point two May images for (T35 L55, T33 L90, T82 L70). 
# One of each has already been deleted from the imageset, 
# but got traced once before deletion.
# T35 and T82: The second image is taken a minute or so after the others in the tube, 
# presumably because the operator was returning to a known-bad location.
# T33: L90 is lowest image saved.
# and also has length 0, so it doesn't matter which one stays anyway.
noeasy.2010 = noeasy.2010[noeasy.2010$Img != "EF2010_T035_L055_2010.05.27_134048_001_AP.jpg",]
noeasy.2010 = noeasy.2010[noeasy.2010$Img != "EF2010_T033_L090_2010.05.27_135345_001_AP.jpg",]
noeasy.2010 = noeasy.2010[noeasy.2010$Img != "EF2010_T082_L070_2010.05.27_140402_001_AP.jpg",]

#centering predictors
noeasy.2010$Date.c = noeasy.2010$Date - mean(noeasy.2010$Date)
# Others too? Depth??

# Reduced dataset: Collapse to block means
logvol.2010 = with(noeasy.2010, aggregate(rootvol.mm3.mm2, by=list(Depth=Depth,Species=Species, Block=Block, Session=Session), function(x)mean(log(x+1e-6))))
names(logvol.2010)[5] = "log.mean"
logvol.2010$log.var = with(noeasy.2010, aggregate(rootvol.mm3.mm2, by=list(Depth=Depth, Species=Species, Block=Block, Session=Session), function(x)var(log(x+1e-6)))$x)
logvol.2010$expected= exp(logvol.2010$log.mean + logvol.2010$log.var/2)
#logvol.2010.ci = mapply(
#		function(y,s)lognormboot(nboot=10000,nsim=4, ybar=y,s2=s), 
#		logvol.2010$log.mean,
#		logvol.2010$log.var)
#logvol.2010.ci = t(logvol.2010.ci)
#logvol.2010$cilo = logvol.2010.ci[,1]
#logvol.2010$cihi = logvol.2010.ci[,2]






require(rhizoFuncs)

raw.2012 = read.delim("../data/frametots2012.txt")
raw.2012 = make.datetimes(raw.2012)

# Delete all Loc 1 records (none show roots)
# and any misplaced frames (e.g. 9, 13)
raw.2012 = droplevels(raw.2012[raw.2012$Location %in% seq(5,120,5),])

# Censor all images that were too low-quality to trace
censor.2012 = read.csv("../data/2012/2012-censorframes.csv")
	# TODO: 2012-censorframes is VERY incomplete, only covers first 1.5 sessions.
censor.2012$date = as.Date(censor.2012$date)
censor.2012 = censor.2012[order(censor.2012$date, censor.2012$tube, censor.2012$loc),]
	# (sort is just for convenience when viewing manually. 
	# should be close to sorted already, and the script doesn't care.)
raw.to.censor.2012 = (
	paste(raw.2012$Date, raw.2012$Tube, raw.2012$Location) 
	%in% paste(censor.2012$date, censor.2012$tube, censor.2012$loc))
raw.2012 = droplevels(raw.2012[!raw.to.censor.2012,])
rm(raw.to.censor.2012)

# Sort by order of tracing (required by strip.tracing.dups)
raw.2012 = raw.2012[order(raw.2012$MeasDateTime),]

# Drop duplicates: 
# silently if only one is reasonable, 
# with warning if several candidates might be correct.
noeasy.2012.by = by(raw.2012, raw.2012$Img, strip.tracing.dups)
noeasy.2012 = do.call(rbind, noeasy.2012.by)
rm(noeasy.2012.by)

# many warnings about multiple calibrations.
# TODO: Revisit calibrations and fix upstream.

noeasy.2012$Month = months(noeasy.2012$Date)
noeasy.2012$Block = assign.block(noeasy.2012$Tube)
noeasy.2012$Species = assign.species(noeasy.2012$Tube)
noeasy.2012$Depth = loc.to.depth(noeasy.2012$Location)
noeasy.2012$rootvol.mm3.mm2 = with(noeasy.2012, 
	rootvol.perarea(TotVolume.mm3, PxSizeH, PxSizeV))
# normed.2012 = normalize.soilvol(noeasy.2012)

# Which images have duplicates? (is this useful at all?)
# dupimg.2012 = tapply(raw.2012$Img, raw.2012$Img, length)
# dupimg.2012 = dupimg.2012[dupimg.2012>1]
# dupimg.2012 = data.frame(img=names(dupimg.2012), n=dupimg.2012, stringsAsFactors=FALSE)

# TODO: Check here for any LOCATIONs with multiple images from the same session 
# strip.tracing.dups only gets rid of multiple records for the same image name.

#centering predictors
noeasy.2012$Date.c = noeasy.2012$Date - mean(noeasy.2012$Date)
# or: noeasy.2012$Date.scale = scale(noeasy.2012$Date)
# Others too? Depth??


# Reduced dataset: Collapse to block means
logvol.2012 = with(noeasy.2012, aggregate(rootvol.mm3.mm2, by=list(Depth=Depth,Species=Species, Block=Block, Session=Session), function(x)mean(log(x+1e-6))))
names(logvol.2012)[5] = "log.mean"
logvol.2012$log.var = with(noeasy.2012, aggregate(rootvol.mm3.mm2, by=list(Depth=Depth, Species=Species, Block=Block, Session=Session), function(x)var(log(x+1e-6)))$x)
logvol.2012$expected= exp(logvol.2012$log.mean + logvol.2012$log.var/2)
#logvol.2012.ci = mapply(
#		function(y,s)lognormboot(nboot=10000,nsim=4, ybar=y,s2=s), 
#		logvol.2012$log.mean,
#		logvol.2012$log.var)
#logvol.2012.ci = t(logvol.2012.ci)
#logvol.2012$cilo = logvol.2012.ci[,1]
#logvol.2012$cihi = logvol.2012.ci[,2]


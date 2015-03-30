# Combine measurements and image-derived estimates to of rhizotron tube offsets
# to get a best guess offset for each tube averaged across the season.
#
# Usage: Rscript estimate_offset.r measurements.csv imagenotes.csv outfile.csv
# If no measurements.csv available, call as 
# Rscript NULL imagenotes.csv outfile.csv

complete.or.NA = function(x){
# return x with NAs removed, or a single NA if everything in x is NA.
	if(all(is.na(x))){
		return(NA)
	}else{
		return(na.omit(x))
	}
}

args = commandArgs(trailingOnly=TRUE)
if(args[1] == "NULL"){ 
	meas=NULL 
}else{ 
	meas = read.csv(args[1], stringsAsFactors=FALSE) 
}
ests = read.csv(args[2], stringsAsFactors=FALSE)
outfile = args[3]

# Ignoring camera slop or operator error,
# 22 cm from top of tube to center of loc 1 
# 1.35 cm between frames
# Within each frame, distances in the estimate file are percentage from the top.
# I'll assume 1.22 cm from top to bottom of image 
# (mean of all calibrations across all years, range is 1.11-1.39).
# This means loc 1 goes from (22 - 1.22/2) = 21.39 cm to (22 + 1.35/2) = 22.61 cm from the top of the tube, Loc 2 goes from ((22+1.35) - 1.22/2) = 22.74 to ((22+1.35) + 1.22/2) = 23.96, and so on.
ests$tubetop.to.frametop = 20.04 + ests$location*1.35
ests= within(ests, {
	tubetop.to.soil = tubetop.to.frametop + (top.of.soil/100 * 1.22)
	tubetop.to.dark = tubetop.to.frametop + (bottom.of.light/100 * 1.22)
	tubetop.to.endtape = tubetop.to.frametop + (bottom.of.tape/100 * 1.22)
})

# Within each tube on a given day, we care about the *deepest* visible tape and light, and the *shallowest* visible soil, and will ignore any information from shallower (/deeper) locations.
# If we have no information from a tube, we keep it NA using complete.or.NA().
alldays = aggregate(
	formula=cbind(tubetop.to.endtape, tubetop.to.dark) ~ tube + date, 
	data=ests, 
	FUN=function(x){ max(complete.or.NA(x)) }, 
	na.action=na.pass)
alldays$tubetop.to.soil = aggregate(
	formula=tubetop.to.soil ~ tube + date, 
	data=ests, 
	FUN=function(x){ min(complete.or.NA(x)) }, 
	na.action=na.pass)$tubetop.to.soil

# On each day of the season, our best guess from images is that the tube offset is at the deepest point where we CAN see tape or light and HAVEN'T yet seen soil, i.e. the maximum of tubetop.to.dark, tubetop.to.endtape, tubetop.to.soil.
# A nuance we'll ignore for the moment: If the maximum of these is tubetop.to.soil, we have a point estimate. If it's one of the other two, we have a lower bound: The true offset is somewhere between here and the top of the next image down.

alldays$estimated = with(alldays, pmax(tubetop.to.soil, tubetop.to.endtape, tubetop.to.dark, na.rm=TRUE))

est.avg = aggregate(
	formula = estimated ~ tube,
	data=alldays,
	FUN=function(x)round(mean(complete.or.NA(x))),
	na.action=na.pass)

# combine image-based estimates with measured values if available: 
# use measured value where available, otherwise use estimate.
if(is.null(meas)){
	meas=expand.grid(tube=1:96, offset=NA)
}
meas$measured = meas$offset
meas = merge(meas, est.avg, all=T)
meas$offset = ifelse(is.na(meas$measured), meas$estimated, meas$measured)
meas$source = ifelse(is.na(meas$measured), "image", "measured")

write.csv(meas, file=outfile, quote=FALSE, row.names=FALSE)
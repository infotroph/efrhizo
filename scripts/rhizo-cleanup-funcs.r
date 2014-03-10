strip.tracing.dups = function(x){
	# Takes rhizotron data for a single image 
	# and return the most recent tracing, with a warning if it's unclear that's
	# the correct tracing to keep.
	# Sample usage: 
	# 	notracedups.2010 = by(raw.rhizo.2010, raw.thizo.2010$Tube, strip.tracing.dups)
	#	notracedups.2010 = do.call(rbind, notracedups.2010)

	stopifnot(!is.unsorted(x$MeasDateTime)) # need to rely on last row = most recent
	
	if (nrow(x) <= 1){
		# 0 rows: should have been caught upstream, but not a problem.
		# 1 row: OK, nothing to do.
		return(x)
	}
	
	if (length(unique(x$PxSizeH)) > 1 || length(unique(x$PxSizeV)) > 1 ){
		# Calibration changed! resolve by hand
		# (or, better, further upstream)
		# NOT IMPLEMENTED YET -- just warns and moves on.
		print(paste(
			x$Img[1], 
			": multiple cals. PxSizeH: ", 
			paste(x$PxSizeH, collapse=", "), 
			", PxSizeV: ", 
			paste(x$PxSizeV, collapse=", ")))
		# return(x[nrow(x),])
	}
	
	xv  = x$TotVolume.mm3
	
	if (length(unique(xv)) == 1 # All values identical...
		|| (all(xv[xv > 0] == xv[length(xv)]) # ...or all nonzeros identical
			&&  all(xv == sort(xv)))  # ...and later than all the zeros 
		){ 
			return(x[nrow(x),]) # ...Then last value is the correct one.
	}
	
	# If we got this far, there are either multiple nonzeros 
	# or zeros after a nonzero; either way, need to check manually.
	print(paste(
		x$Img[1], 
		": multiple values: ", 
		paste(xv, collapse = ", ")))
	return(x[nrow(x),])
} 

make.datetimes = function(df){
	# Only works on freshly read dataframes -- 
	# will fail if called a second time, because Date and MeasDate formats have changed!
	within(df, {
		Time = as.character(Time)							# strptime breaks on single-digit
		Time = ifelse(nchar(Time)<6, paste0(0,Time), Time) 	# hours (eg "91525"), so zero-pad.
		DateTime = as.POSIXct(paste(Date, Time), format="%Y.%m.%d %H%M%S") 
		Date = as.Date(Date, format="%Y.%m.%d")
		MeasDateTime = as.POSIXct(paste(MeasDate, MeasTime), format="%m/%d/%Y %H:%M:%S")
		MeasDate = as.Date(MeasDate, format="%m/%d/%Y")
		
	})
}

assign.species=function(tube){
	cut(
		tube,
		breaks=c(0, 24, 48, 72, 96), 
		labels=c("Cornsoy", "Miscanthus", "Switchgrass", "Prairie"))
}

assign.block = function(tube){ 
	b = rep(NA,length(tube))
	b[tube %in% c(1:8, 25:32, 49:56, 73:80)] = 0
	b[tube %in% c(9:12, 33:36, 57:60, 81:84)] = 1
	b[tube %in% c(13:16, 37:40, 61:64, 85:88)] = 2
	b[tube %in% c(17:20, 41:44, 65:68, 89:92)] = 3
	b[tube %in% c(21:24, 45:48, 69:72, 93:96)] = 4
	return(factor(b))
}

loc.to.depth = function(loc){
	round((loc*1.35)*cos((pi/180)*30))
}


rootvol.perarea = function(rootvol, pxH, pxV){
	imgarea = (754 * pxH) * (510 * pxV)
	return(rootvol / imgarea)
}

# normalize.soilvol = function(df){
# 	# Convert root volume per image into root volume per volume soil.
# 	# Assumes rhizotron camera can see 2 mm into soil for fine roots,
# 	# but full diameter of larger roots.
# 	# Approximated here by multiplying each diameter class by its bin size.
# 	# BUGBUG: These diameter classes are in mm/10, so "greater than 4.5"
	# contains everything 0.45 mm and larger! 
	# To fix, set up more appropriate size classes and reload images.

# 	within(df, {
# 		ImgArea.mm2 = (754 * PxSizeH) * (510 * PxSizeV)

# 		rootvol0to0.5 = V0to0.5 / ImgArea.mm2 * 2
# 		rootvol0.5to1 = V0.5to1 / ImgArea.mm2 * 2
# 		rootvol1to1.5 = V1to1.5 / ImgArea.mm2 * 2
# 		rootvol1.5to2 = V1.5to2 / ImgArea.mm2 * 2
# 		rootvol2to2.5 = V2to2.5 / ImgArea.mm2 * 2.5
# 		rootvol2.5to3 = V2.5to3 / ImgArea.mm2 * 3
# 		rootvol3to3.5 = V3to3.5 / ImgArea.mm2 * 3.5
# 		rootvol4.5to4 = V3.5to4 / ImgArea.mm2 * 4
# 		rootvol4to4.5 = V4to4.5 / ImgArea.mm2 * 4.5
# 		rootvolgreaterthan4.5 = Vgreaterthan4.5 / ImgArea.mm2 * 5

# 		rootvol.mm3.mm3 = (
# 			rootvol0to0.5 
# 			+ rootvol0.5to1 
# 			+ rootvol1to1.5 
# 			+ rootvol1.5to2 
# 			+ rootvol2to2.5 
# 			+ rootvol2.5to3 
# 			+ rootvol3to3.5 
# 			+ rootvol4.5to4 
# 			+ rootvol4to4.5 
# 			+ rootvolgreaterthan4.5)})
# }

lognormboot = function(
		nboot=1000, # number of bootstrap samples
		nsim=4, # size of each sample
		ybar=0, # mean(log(data))
		s2=1, # var(log(data))
		quantiles=c(0.025, 0.975),
		na.rm=na.rm){
	# compute parametric bootstrap confidence intervals 
	# on a lognormal distribution, given mean and variance of log.
	# Algorithm from http://www.amstat.org/publications/jse/v13n1/olsson.html
	
	if(is.na(ybar)|| is.na(s2)){
		return(c(NA, NA))
	}
	t2 = rep(NA,nboot)
	for (i in 1:nboot){
		z = rnorm(1)
		u2 = rchisq(1, df=nsim-1)
		t2[i] = (
			ybar 
			- (z / (sqrt(u2) / sqrt(nsim-1))) * sqrt(s2)/sqrt(nsim) 
			+ 1/2 * s2/(u2/(nsim-1)))	
	}
	return(exp(quantile(t2, probs=quantiles)))
}



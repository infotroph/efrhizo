strip.tracing.dups <-
function(x, warn=TRUE){
	# Takes rhizotron data for a single image 
	# and return the most recent tracing, with a warning if it's unclear that's
	# the correct tracing to keep.
	# Sample usage: 
	# 	notracedups.2010 = by(raw.rhizo.2010, raw.thizo.2010$Img, strip.tracing.dups)
	#	notracedups.2010 = do.call(rbind, notracedups.2010)

	stopifnot(!is.unsorted(x$MeasDateTime)) # need to rely on last row = most recent
	
	if (nrow(x) <= 1){
		# 0 rows: should have been caught upstream, but not a problem.
		# 1 row: OK, nothing to do.
		return(x)
	}
	
	if (any(x$PxSizeH != x$PxSizeH[1])|| any(x$PxSizeV != x$PxSizeV[1])){
		# Calibration changed! resolve by hand
		# (or, better, further upstream)
		# NOT IMPLEMENTED YET -- just warns and moves on.
		if(warn){
			print(paste(
				x$Img[1], 
				": multiple cals. PxSizeH: ", 
				paste(x$PxSizeH, collapse=", "), 
				", PxSizeV: ", 
				paste(x$PxSizeV, collapse=", ")))
		}
		# return(x[nrow(x),])
	}
	
	xv  = x$TotVolume.mm3
	
	if (all(xv == xv[1]) # All values identical...
		|| (all(xv[xv > 0] == xv[length(xv)]) # ...or all nonzeros identical
			&&  all(xv == sort(xv)))  # ...and later than all the zeros 
		){ 
			return(x[nrow(x),]) # ...Then last value is the correct one.
	}
	
	# If we got this far, there are either multiple nonzeros 
	# or zeros after a nonzero; either way, need to check manually.
	if(warn){
		print(paste(
			x$Img[1], 
			": multiple values: ", 
			paste(xv, collapse = ", ")))
	}
	return(x[nrow(x),])
}

# Logs hand-converted to compatible formats before loading
log524 = read.csv("../data/2010/analysis log 05-24.csv")
log722 = read.csv("../data/2010/analysis log 7-22-2010.csv")
log812 = read.csv("../data/2010/analysis log 2010-8-12.csv")
log1007 = read.csv("../data/2010/analysis log 2010-10-07.csv")

logs.2010 = rbind(log524, log722, log812, log1007)
rm(log524, log722, log812, log1007)

logs.2010$Date.imaged = as.Date(logs.2010$Date.imaged, format="%Y-%m-%d") 
logs.2010$Date.Analyzed = as.Date(logs.2010$Date.Analyzed, format="%m/%d/%y")
	# TODO: Fix date format in the CSVs so these match! 
	# This converts non-date strings (e.g. "not imaged") to NA. 
	# Good riddance.


# Compare pixel calibrations in datafile against what's claimed in the log
calib.log = split(
	logs.2010[,c("Tube.number", "Date.imaged")], 
	logs.2010$Calibration.image)

merge.pxsize = function(calsect, df){
	# 
	pxs = function(var, tube, date){
		unique(df[df$Tube == tube & df$Date == date, var])
	}
	calsect$PxSizeH = mapply(FUN=pxs, 
		var="PxSizeH", 
		tube=calsect$Tube.number, 
		date=calsect$Date.imaged)
	calsect$PxSizeV = mapply(FUN=pxs, 
		var="PxSizeV", 
		tube=calsect$Tube.number, 
		date=calsect$Date.imaged)
	if(length(unique(calsect$PxSizeH)) ==1 && length(unique(calsect$PxSizeH))){
		calsect$OK = TRUE
	}else{
		calsect$OK = FALSE
	}
	return(calsect)
}	

lapply(calib.log, merge.pxsize, noeasy.2010)


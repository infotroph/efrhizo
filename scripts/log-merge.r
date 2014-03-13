# Logs hand-converted to compatible formats before loading
logs.2010 = rbind(
	read.csv("../rawdata/analysis-log-2010-05-24.csv"),
	read.csv("../rawdata/analysis-log-2010-07-22.csv"),
	read.csv("../rawdata/analysis-log-2010-08-12.csv"),
	read.csv("../rawdata/analysis-log-2010-10-07.csv"))

logs.2010$Date.imaged = as.Date(logs.2010$Date.imaged, format="%Y-%m-%d") 
logs.2010$Date.Analyzed = as.Date(logs.2010$Date.Analyzed, format="%Y-%m-%d")
	# This converts non-date strings (e.g. "not imaged") to NA. 
	# Good riddance, they should be in the notes column instead.


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


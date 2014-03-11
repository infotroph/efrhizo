make.datetimes <-
function(df){
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

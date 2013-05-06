
oackb.fulldups = aggregate(oackb.full$Img, by=list(loc=oackb.full$Location, tube=oackb.full$Tube), length)
oackb.fulldups = oackb.fulldups[oackb.fulldups$x > 1,]


tubeview = function(frame, tube, loc){return(frame[frame$Tube %in% tube & frame$Location %in% loc ,c('Img','Tube','Location','MeasDate','MeasTime','TotLength.mm', 'TotProjArea.mm2')])}


rhizolocdiff = function(frame,tube,loc){
	targets = frame[frame$Tube %in% tube & frame$Location %in% loc,]
	matches = lapply(
		targets, 
		function(x)!all(x == x[1]))	
	return(targets[,which(unlist(matches))])
}


tg[,which(unlist(lapply(tg,function(x)!all(x == x[1]))))]

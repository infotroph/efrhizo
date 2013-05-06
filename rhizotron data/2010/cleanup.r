s22010.raw = read.delim("/Users/chrisb/UI/energy farm/rhizotron data/2010/ef2010-07-22-frametots.txt")
s22010.noeasydups = s22010.raw[!duplicated(s22010.raw[,c(1,4:95)],fromLast=TRUE),]
s22010.dups = aggregate(s22010.noeasydups$Img, by=list(loc=s22010.noeasydups$Location, tube=s22010.noeasydups$Tube), length)
			s22010.dups = s22010.dups[s22010.dups$x > 1,]


tubeview = function(frame, tube, loc=1:120){return(
	frame[ 	frame$Tube %in% tube & frame$Location %in% loc,
			c(	'Img',
				'Tube',
				'Location',
				'MeasDate',
				'MeasTime',
				'TotLength.mm', 
				'TotProjArea.mm2')])}


Check calibration changes:

tube.whatdiff = function(frame, tube, loc, exclude=NULL){
	tf = frame[
		frame$Tube %in% tube & frame$Location %in% loc, 
		!(names(frame) %in% exclude)]
		
	consts = lapply(tf, function(x) length(unique(x)) > 1)	
	tf = tf[, unlist(consts)]
	
	if(any(grep("Tot", names(tf)))){
		# If the total changed, we don't care about the breakdown.
		exclude = c(
			grep("Alive", names(tf), value=T),
			grep("Dead", names(tf), value=T),
			grep("Gone", names(tf), value=T),
			grep("to", names(tf), value=T),
			grep("greater", names(tf), value=T))
		tf = tf[,!(names(tf) %in% exclude)] }
		
	return(tf)
}

check.deepest = function(datafile, logfile){}

check.logged = function(tubeno)
	tube = tubeview(data, tubeno)
	tube = tube[which(tube$TotNumberOfTips > 0),]
	if(tube$Location[length(tube$Location)] > log$deepest){
		print(paste("Tube ", tn, ": Roots in deeper frame than reported\n"))
	}
	if(nrow(tube) != log$..frames){
		print(paste("tube ", tn, ": ", log$..frames, " frames with roots reported, ", nrow(tube), " found\n"))}



tdl = aggregate(
	s22010.noeasydups$TotProjArea.mm2, 
	by=list(loc=s22010.noeasydups$Location, tube=s22010.noeasydups$Tube), 
	paste)
tdl.dups = tdl[lapply(tdl$x, function(l){return(length(l))}) > 1,]



	
			efrhizo20100524$Species = cut(
				efrhizo20100524$Tube,
				breaks=c(0, 24, 48, 72, 96), 
				labels=c("Cornsoy", "Miscanthus", "Switchgrass", "Prairie"))
			
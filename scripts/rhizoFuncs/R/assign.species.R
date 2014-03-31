assign.species <-
function(tube){
	if(is.factor(tube)){
		tube=as.numeric(as.character(tube))
	}
	cut(
		tube,
		breaks=c(0, 24, 48, 72, 96), 
		labels=c("Cornsoy", "Miscanthus", "Switchgrass", "Prairie"))
}

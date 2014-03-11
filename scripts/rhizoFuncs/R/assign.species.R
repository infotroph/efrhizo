assign.species <-
function(tube){
	cut(
		tube,
		breaks=c(0, 24, 48, 72, 96), 
		labels=c("Cornsoy", "Miscanthus", "Switchgrass", "Prairie"))
}

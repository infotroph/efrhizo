rootvol.perarea <-
function(rootvol, pxH, pxV){
	imgarea = (754 * pxH) * (510 * pxV)
	return(rootvol / imgarea)
}

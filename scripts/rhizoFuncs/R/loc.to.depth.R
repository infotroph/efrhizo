loc.to.depth <-
function(loc, offset=22, angle=30){
	round((loc*1.35 - (offset-22)) * cos((pi/180)*angle))
}

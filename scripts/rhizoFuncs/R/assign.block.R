assign.block <-
function(tube){ 
	b = rep(NA,length(tube))
	b[tube %in% c(1:8, 25:32, 49:56, 73:80)] = 0
	b[tube %in% c(9:12, 33:36, 57:60, 81:84)] = 1
	b[tube %in% c(13:16, 37:40, 61:64, 85:88)] = 2
	b[tube %in% c(17:20, 41:44, 65:68, 89:92)] = 3
	b[tube %in% c(21:24, 45:48, 69:72, 93:96)] = 4
	return(factor(b))
}

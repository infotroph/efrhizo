lognormboot <-
function(
		nboot=1000, # number of bootstrap samples
		nsim=4, # size of each sample
		ybar=0, # mean(log(data))
		s2=1, # var(log(data))
		quantiles=c(0.025, 0.975),
		na.rm=na.rm){
	# compute parametric bootstrap confidence intervals 
	# on a lognormal distribution, given mean and variance of log.
	# Algorithm from http://www.amstat.org/publications/jse/v13n1/olsson.html
	
	if(is.na(ybar)|| is.na(s2)){
		return(c(NA, NA))
	}
	t2 = rep(NA,nboot)
	for (i in 1:nboot){
		z = rnorm(1)
		u2 = rchisq(1, df=nsim-1)
		t2[i] = (
			ybar 
			- (z / (sqrt(u2) / sqrt(nsim-1))) * sqrt(s2)/sqrt(nsim) 
			+ 1/2 * s2/(u2/(nsim-1)))	
	}
	return(exp(quantile(t2, probs=quantiles)))
}

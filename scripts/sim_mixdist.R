sim_mixdist = function(
		n_tubes=1,
		depths=1:3,
		intercept=1, 			# E[y] at depth=0 (log scale)
		b_depth=-1, 		# slope for depth (log scale)
		sig_tube=1, 			# sd for N(0) tube offsets (log scale)
		detect_loc=1,			# intercept for detection logistic. (scale... same as mu?)
		detect_scale=1, 		# slope for detection logistic. (scale?)
		sigma=1){ 			# residual (log scale)
	
	# First the expectations for depth + random tube effect:
	dat=expand.grid(tube=1:n_tubes,depth=depths)
	dat$int = intercept
	dat$b_tube = rnorm(n_tubes, mean=0, sd=sig_tube)[dat$tube]
	dat$mu = dat$int + dat$b_tube  + b_depth*log(dat$depth)

	# Now compute probability of detection failure at a given mu
	dat$p_detect = plogis(dat$mu, location=detect_loc, scale=detect_scale)

	# And now put them together to generate y values.
	dat$y = (
		rlnorm(nrow(dat), meanlog=dat$mu, sdlog=sigma) 
		* rbinom(nrow(dat), size=1, prob=dat$p_detect))
	dat$y_logi = dat$y > 0

	return(dat)
}

# Simulate some rhizotron data.
# Arguments (all units are log scale unless otherwise noted):
# tube_ids, factor or anything like it (psst. stop overthinking and just use 1:n)
# depths, numeric: *which* depths?
# sig_tube: sd for random tube offsets
# b_depth: slope with log(depth). Hopefully negative, but the math doesn't care.
# int_depth: numeric, intercept for root density
#	(at mean depth, NOT at the surface!)
# sig_resid: sd for the residual term.
# loc_detect: log root volume where half of images contain zero roots
# scale_detect: How fast does (logit) root detection increase with root volume?
# loc_surface: depth (in cm, NOT log scale) where half of roots are detected
# scale_surface: How fast does (logit) root detection increase with depth?
sim_rhizo = function(
		tube_ids,
		depths,
		sig_tube,
		b_depth,
		int_depth,
		sig_resid,
		loc_detect,
		scale_detect,
		loc_surface,
		scale_surface){

	dat=expand.grid(Tube=tube_ids, Depth=depths)
	dat$d_tube = sim_tubes(ids=dat$Tube, sigma=sig_tube)
	dat$d_depth = sim_depth_log(dat$Depth, int_depth, b_depth)
	dat$mu = dat$d_tube + dat$d_depth
	dat$d_surface = plogis(
		dat$Depth,
		location = loc_surface,
		scale = scale_surface)
	dat$mu_hat = dat$mu + log(dat$d_surface)
	dat$y = (
		rlnorm(
			n = nrow(dat),
			meanlog = dat$mu_hat,
			sdlog = sig_resid)
		* rbinom(
			n = nrow(dat),
			size = 1,
			prob = plogis(
				q=dat$mu_hat,
				location = loc_detect,
				scale = scale_detect)))
	return(dat)
}

# Random tube effect: N(0,sigma)
sim_tubes = function(ids, sigma){
	id_uq = unique(ids)
	offsets = rnorm(n=length(id_uq), mean=0, sd=sigma)
	offsets[match(ids, id_uq)]
}

# Fixed depth effect: linear decrease with log(depth)
sim_depth_log = function(depths, intercept, beta){
	intercept + beta*(log(depths) - log(mean(depths)))
}


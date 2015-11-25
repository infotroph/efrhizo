
# Simulate some rhizotron data.
# Arguments (all units are log scale):
# tube_ids, factor or anything like it (psst. stop overthinking and just use 1:n)
# depths, numeric: *which* depths?
# sig_tube: sd for random tube offsets
# b_depth: slope with log(depth). Hopefully negative, but the math doesn't care.
# int_depth: numeric, intercept for root density (= at the surface!)
# sig_resid: sd for the residual term.
sim_rhizo = function(
		tube_ids,
		depths,
		sig_tube,
		b_depth,
		int_depth,
		sig_resid){

	# Random tube effect: N(0,sigma)
	sim_tubes = function(ids, sigma){
		id_uq = unique(ids)
		offsets = rnorm(n=length(id_uq), mean=0, sd=sigma)
		return(offsets[match(ids, id_uq)])
	}

	# Fixed depth effect: linear decrease with log(depth)
	sim_depth_log = function(depths, intercept, beta){
		return(intercept + beta*log(depths))
	}

	dat=expand.grid(tube_id=tube_ids, depth=depths)
	dat$d_tube = sim_tubes(dat$tube_id, sigma=sig_tube)
	dat$d_depth = sim_depth_log(dat$depth, int_depth, b_depth)
	dat$y = with(dat, rlnorm(n=nrow(dat), meanlog=d_depth+d_tube, sdlog=sig_resid))
	return(dat)
}


set.seed(2436253)
library(rstan)
source("../../scripts/sim_mixdist.R")

# why yes, I DID write this script before I broke sim_mixdist out into a freestanding function!
# Keeping the globals because I use some in plotting calls below.
n_tubes = 20
depths = seq(1,100,6)
intercept = -3
b_depth = -0.5
sig_tube = 1
detect_loc = -5 
detect_scale = 1
sigma = 1

n_chains = 7
n_iters = 10000
n_warm = 2000
rstan_options(auto_write = TRUE)
options(mc.cores=7)
stanpars=c("a_detect", "b_detect", "intercept", "b_depth", "sig_tube", "sigma")

### Simulate some data:
# tube = sampling site, essentially a subject ID.
# depth = location within a given tube. Units are cm below surface.
# y = observed volume of roots in a given sample.
#
# Assumptions:
# E[y] is lognormally distributed and decreases ~linearly with log(depth),
# but distribution is patchy relative to the scale of sampling,
# so I observe zeros (=detection failure) in many samples.
# I assume that detection failures are more likely when the true root volume is lower,
# and that they become very unlikely above some detection threshold: 
# p(y>0|E[y]) ~ logit(detect + scale * E[y]).

dat = sim_mixdist(
	n_tubes=n_tubes,
	depths=depths,
	intercept=intercept,
	b_depth=b_depth,
	sig_tube=sig_tube,
	detect_loc=detect_loc,
	detect_scale=detect_scale,
	sigma=sigma)


# Presort data on y, so that all zeros are together.
# The model requires this so that we don't feed zeros into lognormal().
dat_sort=dat[order(dat$y),]

### Now the model.
fit_tube_depth = stan(
	data=list(
		N=nrow(dat_sort), 
		T=length(unique(dat_sort$tube)),
		tube=dat_sort$tube,
		depth=dat_sort$depth,
		y=dat_sort$y,
		y_logi=dat_sort$y_logi,
		first_pos=which(dat_sort$y > 0)[1],
		n_pos=length(which(dat_sort$y > 0))), 
	file="../mix_tube_depth.stan",
	iter=n_iters,
	warmup=n_warm,
	chains=n_chains,
	pars=stanpars)

print(fit_tube_depth)
print(paste("mean of mu:", mean(dat_sort$mu)))
print(paste("mean of depth:", mean(dat_sort$depth)))
# To evaluate output, remember that we expect: 
# 	intercept_stan = intercept_sim + b_depth * log(mean(depth))
# 	b_detect = 1 / detect_scale
# With no centering, a_detect = -detect_loc / detect_scale
# Then with centering, log odds at intercept are 
#	a_detect + b_detect * (0 - mean(mu)) 
#	= (-detect_loc / detect_scale) + (1 / detect_scale) * (-mean(mu)) 
#	= -detect_loc / detect_scale + (-mean(mu) / detect_scale) 
#	==> (-detect_loc - mean(mu)) / detect_scale
cat("
Expected values from simulation:\
a_detect ~= ", (-detect_loc + mean(dat_sort$mu))/detect_scale, "\
b_detect ~= ", 1/detect_scale, "\
intercept ~= ", intercept + b_depth * log(mean(dat_sort$depth)), "\
b_depth ~= ", b_depth, "\
sig_tube ~= ", sig_tube, "\
sigma ~= ", sigma, "\

")

# plot some results
fit_cis = data.frame(sapply(
	extract(fit_tube_depth), 
	quantile, 
	c(0.025, 0.975)))
fit_means = as.list(get_posterior_mean(fit_tube_depth)[,(n_chains+1)])

plot(log(y) ~ depth, dat_sort)
lcdepth = (log(depths)-log(mean(depths)))
lines(depths, intercept + b_depth * log(depths), col="red")
lines(depths, fit_means$intercept + fit_means$b_depth * lcdepth, col="black")
lines(
	depths, 
	pmin(
		fit_cis$intercept[[1]] + fit_cis$b_depth[[1]] * lcdepth,
		fit_cis$intercept[[1]] + fit_cis$b_depth[[2]] * lcdepth),
	col="green")
lines(
	depths, 
	pmax(
		fit_cis$intercept[[2]] + fit_cis$b_depth[[1]] * lcdepth,
		fit_cis$intercept[[2]] + fit_cis$b_depth[[2]] * lcdepth),
	col="green")


mus=seq(min(dat_sort$mu), max(dat_sort$mu), 0.1)
cmu = mus - mean(dat_sort$mu)
lo2p = function(x, int, slope){ 
	# converts regression estimates back to probability
	1/(1+exp(-(int+slope*x)))
}
plot(y_logi ~ mu, dat_sort)
lines(mus, plogis(mus, detect_loc, detect_scale), col="red")
lines(mus, lo2p(cmu, fit_means$a_detect, fit_means$b_detect), col="black")
lines(
	mus,
	pmin(
		lo2p(cmu, fit_cis$a_detect[[1]], fit_cis$b_detect[[1]]),
		lo2p(cmu, fit_cis$a_detect[[1]], fit_cis$b_detect[[2]])),
	col="green")
lines(
	mus,
	pmax(
		lo2p(cmu, fit_cis$a_detect[[2]], fit_cis$b_detect[[1]]),
		lo2p(cmu, fit_cis$a_detect[[2]], fit_cis$b_detect[[2]])),
	col="green")

sessionInfo()

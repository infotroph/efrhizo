set.seed(93235473)

library(rstan)
# library(dplyr)

rstan_options(auto_write = TRUE)
options(mc.cores = 7)
stanfile = "tube_depth.stan"

source("../scripts/simrhizo.R")
dat = sim_rhizo(
	tube_ids=1:96,
	depths=seq(1, 100, 10),
	sig_tube=2,
	b_depth=-0.1,
	int_depth=1,
	sig_resid=1)

# pseudodata for predictions
dat_pred = expand.grid(tube_id=1:10, depth=seq(1,100,10))

save(dat, dat_pred, file="stantest_simdata.Rdata")

standatfit = stan(
	file=stanfile,
	data=list(
		N=nrow(dat),
		T=length(unique(dat$tube_id)),
		tube_id=dat$tube_id,
		depth=dat$depth,
		y=dat$y,
		Np=nrow(dat_pred),
		Tp=length(unique(dat_pred$tube_id)),
		tube_id_pred=dat_pred$tube_id,
		depth_pred=dat_pred$depth),
	warmup=1000,
	iter=10000,
	thin=1,
	chains=7)
save(standatfit, file="stantest_out.Rdata")

sink("stan_test_out.txt", split=TRUE)
print(standatfit, pars=c("intercept", "b_depth", "tube_sigma", "sigma", "mu[1]", "mu_pred[1]"))
sink()


source("plot_stan.R")

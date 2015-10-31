# library(rstan)

# load("stantest_simdata.Rdata")
# load("stantest_out.Rdata")

plotpars = c("intercept", "b_depth", "tube_sigma", "sigma", "mu[1]", "mu[10]", "tube_offset[1]", "tube_offset[10]")

quantile_by = function(mat, idx, probs=c(0.025, 0.975)){
	# combine all rows from columns with the same index,
	# then compute quantiles on each combination
	t(sapply(
		unique(idx),
		function(x)quantile(mat[,idx==x], probs=probs)))
}

plot_pred = function(fit, data, pred_data){
	# Real data vs. CIs of predicted values in *new* tubes:
	# y = CI on individual new observations at this depth
	# mu = CI on mean at this depth in a new tube (this is a weird way of thinking about variation!)
	pred = extract(
		fit,
		pars = c("mu_pred", "y_pred"))
	pred_cis = data.frame(
		unique(pred_data$depth),
		quantile_by(pred$y_pred, pred_data$depth),
		quantile_by(pred$mu, pred_data$depth),
		check.names=FALSE)
	names(pred_cis) = c("depth", "y_2.5", "y_97.5", "mu_2.5", "mu_97.5")

	plot(y~depth, dat, ylim=range(pred_cis[,c("y_2.5", "y_97.5")]))
	with(pred_cis, {
		lines(y_2.5 ~ depth, col="green")
		lines(y_97.5 ~ depth, col="green")
		lines(mu_2.5 ~ depth, col="red")
		lines(mu_97.5 ~ depth, col="red")
	})
	invisible(pred_cis)
}

png("stan_test_%03d.png", height=800, width=1200, units="px")
#predictive plot
plot_pred(standatfit, dat, dat_pred)
# sample traces
print(traceplot(standatfit, pars=plotpars))
# posterior histograms
print(stan_hist(standatfit, pars=plotpars))
dev.off()

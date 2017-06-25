
# Test the Stan model:
# 1. Generate synthetic data from known parameters
# 2. Fit the model in the same way as done for experiment data
# 3. Make diagnostic plots to see how well we recover the known parameters
#
# Run this script from the project root.
# Saves plots and HMC draws to tmp/simdat/.
# Text output is written to the console. You'll probably want to pipe it to a file, e.g. $(Rscript scripts/run_simdat.R > tmp/simdat/run_log.txt).

set.seed(345683)
library(rstan)
library(dplyr)
library(bayesplot)
source("scripts/simdat.R")

sessionInfo()

runname = "simdat"
output_path = "tmp/simdat"
dir.create(output_path)

rstan_options(auto_write = TRUE)
options(mc.cores=7)
n_chains = 4
n_iters = 2000
n_warm = 500
n_predtubes = 4
pred_depths = round(seq(from=1,to=130, length.out=20))
savepars=c(
	"loc_detect",
	"scale_detect",
	"loc_surface",
	"scale_surface",
	"intercept",
	"b_depth",
	"sig_tube",
	"b_tube",
	"sigma",
	"mu", # Careful, this makes the output huge!
	"mu_obs",
	"y_pred",
	"mu_pred",
	"mu_obs_pred",
	"detect_odds_pred",
	"pred_tot",
	"crop_tot",
	"crop_tot_diff",
	"crop_int_diff",
	"crop_bdepth_diff",
	"lp__")

# Prior means/sds for model parameters
# Distributions of all priors are (currently) modeled as normals.
priors = list(
	sig_tube_prior_m=0,
	sig_tube_prior_s=3,
	sigma_prior_m=0,
	sigma_prior_s=3,
	intercept_prior_m=-6,
	intercept_prior_s=6,
	b_depth_prior_m=-1,
	b_depth_prior_s=5,
	loc_surface_prior_m=13,
	loc_surface_prior_s=10,
	scale_surface_prior_m=6,
	scale_surface_prior_s=5,
	loc_detect_prior_m=-8,
	loc_detect_prior_s=10,
	scale_detect_prior_m=0,
	scale_detect_prior_s=1
)

# Generate artificial test data.
# assumes sim_rhizo is already available in namespace.
# TODO: add to rhizoFuncs package so this is true.
# Beware of crop-to-number mapping; it differs from tube number ordering!
# 	1=maize, 2=switch, 3=mxg, 4=prairie
# Keep on being ware of this when passing numbers to sim_* below
simpars = list(
	loc_detect = -7,
	scale_detect = 5,
	`loc_surface[1]` = 20,
	`loc_surface[2]` = 25,
	`loc_surface[3]` = 15,
	`loc_surface[4]` = 20,
	`scale_surface[1]` = 10,
	`scale_surface[2]` = 12,
	`scale_surface[3]` = 8,
	`scale_surface[4]` = 5,
	`intercept[1]` = -7,
	`intercept[2]` = -5,
	`intercept[3]` = -6,
	`intercept[4]` = -6,
	`b_depth[1]` = -0.8,
	`b_depth[2]` = -1,
	`b_depth[3]` = -0.6,
	`b_depth[4]` = -0.9,
	sig_tube = 0.7,
	`sigma[1]` = 2,
	`sigma[2]` = 1.7,
	`sigma[3]` = 2,
	`sigma[4]` = 1.5)

depths = seq(5, 120, 6)
sim_maize = sim_rhizo(
	tube_ids = 1:24,
	depths = depths,
	sig_tube = simpars$sig_tube,
	b_depth = simpars$`b_depth[1]`,
	int_depth = simpars$`intercept[1]`,
	sig_resid = simpars$`sigma[1]`,
	loc_detect = simpars$loc_detect,
	scale_detect = simpars$scale_detect,
	loc_surface = simpars$`loc_surface[1]`,
	scale_surface = simpars$`scale_surface[1]`)
sim_maize$Species = "Maize-Soybean"

sim_misc = sim_rhizo(
	tube_ids = 25:48,
	depths = depths,
	sig_tube = simpars$sig_tube,
	b_depth = simpars$`b_depth[3]`,
	int_depth = simpars$`intercept[3]`,
	sig_resid = simpars$`sigma[3]`,
	loc_detect = simpars$loc_detect,
	scale_detect = simpars$scale_detect,
	loc_surface = simpars$`loc_surface[3]`,
	scale_surface = simpars$`scale_surface[3]`)
sim_misc$Species = "Miscanthus"

sim_switch = sim_rhizo(
	tube_ids = 49:72,
	depths = depths,
	sig_tube = simpars$sig_tube,
	b_depth = simpars$`b_depth[2]`,
	int_depth = simpars$`intercept[2]`,
	sig_resid = simpars$`sigma[2]`,
	loc_detect = simpars$loc_detect,
	scale_detect = simpars$scale_detect,
	loc_surface = simpars$`loc_surface[2]`,
	scale_surface = simpars$`scale_surface[2]`)
sim_switch$Species = "Switchgrass"

sim_prairie = sim_rhizo(
	tube_ids = 73:96,
	depths = depths,
	sig_tube = simpars$sig_tube,
	b_depth = simpars$`b_depth[4]`,
	int_depth = simpars$`intercept[4]`,
	sig_resid = simpars$`sigma[4]`,
	loc_detect = simpars$loc_detect,
	scale_detect = simpars$scale_detect,
	loc_surface = simpars$`loc_surface[4]`,
	scale_surface = simpars$`scale_surface[4]`)
sim_prairie$Species = "Prairie"

# The real data, for reasons I don't feel like looking up right now,
# have the species factor ordered differently than the tube number ordering.
# That's not a problem in real data (I never rely on the numeric ordering)
# but let's arrange the fake data the same way, so that e.g. "intercept[3]"
# means the same crop in simulated and real datasets.
rzdat = rbind(sim_maize, sim_switch, sim_misc, sim_prairie)
rzdat$Species = factor(
	rzdat$Species,
	levels=c("Maize-Soybean", "Switchgrass", "Miscanthus", "Prairie"))

# Stan expects tube numbers to be in 1:T. If subsetting, must remap.
tube_map = data.frame(Tube=sort(unique(rzdat$Tube)))
tube_map$Tube_alias = seq_along(tube_map$Tube)
rzdat=merge(rzdat, tube_map)
# print(dput(tube_map))

rzdat = rzdat[order(rzdat$y, decreasing=TRUE),]

print("Crop name-to-number key:")
cropkey = data.frame(
	num=1:nlevels(rzdat$Species),
	name=levels(rzdat$Species),
	first_tube=tapply(rzdat$Tube, rzdat$Species, min),
	last_tube=tapply(rzdat$Tube, rzdat$Species, max),
	first_tube_alias=tapply(rzdat$Tube_alias, rzdat$Species, min),
	last_tube_alias=tapply(rzdat$Tube_alias, rzdat$Species, max),
	n_tubes=tapply(rzdat$Tube_alias, rzdat$Species, function(x)length(unique(x))))
print(cropkey)

# Simulate data from:
# `n_predtubes` newly observed tubes,
# evenly divided between the crops in the observed data,
#	 (this is a weird approach, maybe change this!),
# at depths `pred_depths`
rz_pred = expand.grid(
	tube=1:n_predtubes,
	depth=pred_depths)
n_crop = length(unique(rzdat$Species))
rz_pred$Species = factor(
	x=(rz_pred$tube %% n_crop) + 1,
	labels=levels(rzdat$Species))
print("conditions for predicted data:")
print(rz_pred)

rz_mtd = stan(
	data=list(
		N=nrow(rzdat),
		T=length(unique(rzdat$Tube_alias)),
		C=length(unique(rzdat$Species)),
		tube=rzdat$Tube_alias,
		crop=as.numeric(rzdat$Species),
		depth=rzdat$Depth,
		y=rzdat$y,
		N_pred=nrow(rz_pred),
		T_pred=length(unique(rz_pred$tube)),
		C_pred=length(unique(rz_pred$Species)),
		tube_pred=rz_pred$tube,
		depth_pred=rz_pred$depth,
		crop_pred=as.numeric(rz_pred$Species),
		sig_tube_prior_m=priors$sig_tube_prior_m,
		sig_tube_prior_s=priors$sig_tube_prior_s,
		sigma_prior_m=priors$sigma_prior_m,
		sigma_prior_s=priors$sigma_prior_s,
		intercept_prior_m=priors$intercept_prior_m,
		intercept_prior_s=priors$intercept_prior_s,
		b_depth_prior_m=priors$b_depth_prior_m,
		b_depth_prior_s=priors$b_depth_prior_s,
		loc_surface_prior_m=priors$loc_surface_prior_m,
		loc_surface_prior_s=priors$loc_surface_prior_s,
		scale_surface_prior_m=priors$scale_surface_prior_m,
		scale_surface_prior_s=priors$scale_surface_prior_s,
		loc_detect_prior_m=priors$loc_detect_prior_m,
		loc_detect_prior_s=priors$loc_detect_prior_s,
		scale_detect_prior_m=priors$scale_detect_prior_m,
		scale_detect_prior_s=priors$scale_detect_prior_s),
	# file="stan/mctd_foursurf_decen.stan",
	file="stan/mctd_foursurf.stan",
	iter=n_iters,
	warmup=n_warm,
	chains=n_chains,
	pars=savepars,
	refresh=500,
	# control=list(adapt_delta=0.99),
	# sample_file=file.path(output_path, paste0(runname, "_samples.txt")),
	# diagnostic_file=file.path(output_path, paste0(runname, "_info.txt")),
	verbose=TRUE,
	open_progress=FALSE)

save(rz_mtd, rzdat, rz_pred, cropkey, priors, file=file.path(output_path, paste0(runname, ".Rdata")))
warnings()
stopifnot(rz_mtd@mode == 0) # 1 or 2 = error

print(rz_mtd, pars=c(
	"loc_detect", "scale_detect",
	"loc_surface", "scale_surface",
	"intercept", "b_depth",
	"sig_tube", "sigma",
	"crop_tot", "crop_tot_diff", "crop_int_diff", "crop_bdepth_diff",
	"lp__"))
print(paste("mean of depth:", mean(rzdat$Depth)))
log_nz_mean = mean(log(rzdat$y[rzdat$y > 0]))
cat("\nmean of log(nonzero root volume):", log_nz_mean, "\n")

rz_pred_mu = cbind(
	rz_pred,
	summary(rz_mtd, pars="mu_pred")$summary)

rz_pred_mu_obs = cbind(
	rz_pred,
	summary(rz_mtd, pars="mu_obs_pred")$summary)

# summarize zero and nonzero y values separately
rz_pred_y = rstan::extract(rz_mtd, pars="y_pred")$y_pred
rz_pred_y_pos = cbind(
	rz_pred,
	t(apply(
		rz_pred_y,
		MARGIN=2,
		FUN=function(x, probs){
			c(	quantile(log(x[x>0]), probs=c(0.025, 0.5, 0.975)),
				mean=mean(log(x[x>0]))) })))
rz_pred_y_det = cbind(
	rz_pred,
	p_detect=apply(
		rz_pred_y,
		MARGIN=2,
		FUN=function(x){ length(which(x>0)) / length(x) }))

rz_pred_pdet = cbind(
	rz_pred,
	summary(rz_mtd, pars="detect_odds_pred")$summary)

rzdat_pdet = aggregate(
	formula=y ~ I(round(Depth*2, -1)/2) + Species, # rounds to nearest 5 cm
	data=rzdat,
	FUN=function(x)length(which(x>0))/length(x))
names(rzdat_pdet)=c("Depth", "Species", "p_detect")

# Could just do get_posterior_mean(...)[,n_chains+1],
# but this way works even if result has fewer columns than expected
# (e.g. when some chains have sampling errors)
get_postmean_allchains = function(stanobj, ...){
	x = get_posterior_mean(stanobj, ...)
	x[,ncol(x)]
}
rzdat$mu_obs_hat = get_postmean_allchains(rz_mtd, "mu_obs")
rzdat$detect_odds_hat = get_postmean_allchains(rz_mtd, "detect_odds")
# sigma is not separately estimated for each point -- use crop-level residuals.
rzdat$sig_hat = get_postmean_allchains(rz_mtd, "sigma")[merge(rzdat, cropkey, by.x="Species", by.y="name")$num]

rmse_log = with(
	rzdat[rzdat$y > 0,],
	sqrt(mean((mu_obs_hat - log(y))^2, na.rm=TRUE)))
var_log = with(
	rzdat[rzdat$y > 0,],
	var(log(y)))

cat(
	"\nRMSE of mu_obs vs log observed (zeroes excluded): ",
	rmse_log,
	"\nRMSE/var: ",
	rmse_log/var_log,
	"\n\n"
)

png(
	file.path(output_path, paste0(runname, "_%03d.png")),
	height=1200,
	width=1800,
	units="px")
print(
	ggplot(rzdat, aes(Depth, log(y)))
	+geom_point()
	+facet_wrap(~Species)
	+geom_line(
		aes(depth, mean, color="pred_mu"),
		data=rz_pred_mu)
	+geom_line(
		aes(depth, `2.5%`, color="pred_mu"),
		data=rz_pred_mu)
	+geom_line(
		aes(depth, `97.5%`, color="pred_mu"),
		data=rz_pred_mu)
	+geom_line(
		aes(depth, mean, color="pred_mu_obs"),
		data=rz_pred_mu_obs)
	+geom_line(
		aes(depth, `2.5%`, color="pred_mu_obs"),
		data=rz_pred_mu_obs)
	+geom_line(
		aes(depth, `97.5%`, color="pred_mu_obs"),
		data=rz_pred_mu_obs)
	+geom_line(
		aes(depth, mean, color="pred_y"),
		data=rz_pred_y_pos)
	+geom_line(
		aes(depth, `2.5%`, color="pred_y"),
		data=rz_pred_y_pos)
	+geom_line(
		aes(depth, `50%`, color="pred_y median"),
		data=rz_pred_y_pos)
	+geom_line(
		aes(depth, `97.5%`, color="pred_y"),
		data=rz_pred_y_pos)
	+coord_flip()
	+scale_x_reverse()
	+theme_bw(36)
	+theme(aspect.ratio=1.2))
print(
	ggplot(rzdat_pdet, aes(Depth, p_detect))
	+geom_point()
	+geom_line(
		aes(depth, mean, color="pred_pdet"),
		data=rz_pred_pdet)
	+geom_line(
		aes(depth, `2.5%`, color="pred_pdet"),
		data=rz_pred_pdet)
	+geom_line(
		aes(depth, `97.5%`, color="pred_pdet"),
		data=rz_pred_pdet)
	+geom_line(
		aes(depth, p_detect, color="pred_y"),
		data=rz_pred_y_det)
	+facet_wrap(~Species)
	+coord_flip()
	+scale_x_reverse()
	+theme_bw(36)
	+theme(aspect.ratio=1.2))
print(
	ggplot(rzdat, aes(
		x=mu_obs_hat,
		xmin=mu_obs_hat-sig_hat*1.96,
		xmax=mu_obs_hat+sig_hat*1.96,
		y=log(y)))
	+geom_abline()
	+geom_errorbarh(color="grey")
	+geom_point()
	+geom_smooth(method="lm")
	+facet_wrap(~Species)
	+xlab(expression(Predicted~ln(~mm^3~root~mm^-2~image)))
	+ylab(expression(Observed~ln(~mm^3~root~mm^-2~image)))
	+theme_bw(36)
	+theme(aspect.ratio=1))

rzarr = extract(
	rz_mtd,
	permuted=FALSE,
	inc_warmup=FALSE,
	pars=c(
		"loc_detect",
		"scale_detect",
		"loc_surface",
		"scale_surface",
		"intercept",
		"b_depth",
		"sig_tube",
		"sigma"))
print(names(rzarr))
print(names(simpars))
print(mcmc_recover_hist(rzarr, unlist(simpars)))
rzmu = extract(
	rz_mtd,
	permuted=FALSE,
	inc_warmup=FALSE,
	pars="mu")
rzmuhat = extract(
	rz_mtd,
	permuted=FALSE,
	inc_warmup=FALSE,
	pars="mu_obs")
print(mcmc_recover_scatter(rzmu, rzdat$mu, batch=rzdat$Species)
	+theme(strip.text=NULL) # override bayesplot style to show facet labels
	+ggtitle("mu"))
print(mcmc_recover_scatter(rzmuhat, rzdat$mu_hat, batch=rzdat$Species)
	+ggtitle("mu_obs")
	+theme(strip.text=NULL))
print(mcmc_recover_scatter(rzmu, rzdat$mu, batch=rzdat$Depth)
	+theme(strip.text=NULL)
	+ggtitle("mu"))
print(mcmc_recover_scatter(rzmuhat, rzdat$mu_hat, batch=rzdat$Depth)
	+ggtitle("mu_obs")
	+theme(strip.text=NULL))

print(mcmc_recover_scatter(
	x = extract(
		rz_mtd,
		permuted= FALSE,
		inc_warmup=FALSE,
		pars="b_tube"),
	true = (rzdat
	%>% arrange(Tube_alias)
	%>% distinct(Tube_alias, d_tube))$d_tube)
	+ggtitle("b_tube"))

dev.off()

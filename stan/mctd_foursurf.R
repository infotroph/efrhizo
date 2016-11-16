set.seed(234587)
library(rstan)

sessionInfo()

# Usage: Rscript mctd.foursurf.R runname year session path/to/output/ [n_subsample]
# if n_subsample is unset, uses all samples.

args=commandArgs(trailingOnly=TRUE)
runname = args[[1]]
sub_year = as.numeric(args[[2]])
sub_session = as.numeric(args[[3]])
output_path = args[[4]]
if(length(args)==5){
	# How many rows from WITHIN year and session to subsample?
	# Will error if n_subsample > n rows where Year==sub_year & Session==sub_session
	n_subsample = as.numeric(args[[5]])
}else{
	# If unset, use all rows.
	n_subsample = NULL
}

rstan_options(auto_write = TRUE)
options(mc.cores=7)
n_chains = 5
n_iters = 5000
n_warm = 1000
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
	"sigma",
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
plotpars_mod=c(
	"loc_detect",
	"scale_detect",
	"loc_surface",
	"scale_surface",
	"intercept",
	"b_depth",
	"sig_tube",
	"sigma",
	"crop_tot",
	"crop_tot_diff",
	"crop_int_diff",
	"crop_bdepth_diff",
	"lp__")
plotpars_pred=c(
	"y_pred[1]",
	"y_pred[15]",
	"y_pred[28]",
	"mu_pred[1]",
	"mu_pred[15]",
	"mu_pred[28]",
	"mu_obs_pred[1]",
	"mu_obs_pred[15]",
	"mu_obs_pred[28]",
	"detect_odds_pred[1]",
	"detect_odds_pred[15]",
	"detect_odds_pred[28]",
	"pred_tot[1]")

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
	scale_detect_prior_s=6
)

source("scripts/stat-prep.R") # creates data frame "strpall"
strpall = strpall[strpall$Depth > 0,]

ys_rows = which(strpall$Year==sub_year & strpall$Session==sub_session)
if(is.null(n_subsample)){
	rzdat = droplevels(strpall[ys_rows,])
}else{
	ys_rows = sample(ys_rows, n_subsample)
	rzdat = droplevels(strpall[ys_rows,])
	print(paste("Subsampling these", n_subsample, "rows from strpall:"))
	print(dput(ys_rows))
}
rm(strpall)

# Stan expects tube numbers to be in 1:T. If subsetting, must remap.
tube_map = data.frame(Tube=sort(unique(rzdat$Tube)))
tube_map$Tube_alias = seq_along(tube_map$Tube)
rzdat=merge(rzdat, tube_map)
print(dput(tube_map))

rzdat = rzdat[order(rzdat$rootvol.mm3.mm2, decreasing=TRUE),]

print(paste("Using data from", sub_year, ", session", sub_session)) 
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
		y=rzdat$rootvol.mm3.mm2,
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
		scale_surface_prior_m=priors$loc_surface_prior_m,
		scale_surface_prior_s=priors$loc_surface_prior_s,
		loc_detect_prior_m=priors$loc_detect_prior_m,
		loc_detect_prior_s=priors$loc_detect_prior_s,
		scale_detect_prior_m=priors$scale_detect_prior_m,
		scale_detect_prior_s=priors$scale_detect_prior_s),
	file="stan/mctd_foursurf.stan",
	iter=n_iters,
	warmup=n_warm,
	chains=n_chains,
	pars=savepars,
	control=list(adapt_delta=0.99),
	# sample_file=file.path(output_path, paste0(runname, "_samples.txt")),
	# diagnostic_file=file.path(output_path, paste0(runname, "_info.txt")),
	verbose=TRUE,
	open_progress=FALSE)

save(rz_mtd, rzdat, rz_pred, cropkey, priors, file=file.path(output_path, paste0(runname, ".Rdata")))
warnings()
stopifnot(rz_mtd@mode == 0) # 1 or 2 = error

print(rz_mtd, pars=plotpars_mod)
print(rz_mtd, pars=plotpars_pred)
print(paste("mean of depth:", mean(rzdat$Depth)))
log_nz_mean = mean(log(rzdat$rootvol.mm3.mm2[rzdat$rootvol.mm3.mm2 > 0]))
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
	formula=rootvol.mm3.mm2 ~ I(round(Depth*2, -1)/2) + Species, # rounds to nearest 5 cm
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
	rzdat[rzdat$rootvol.mm3.mm2 > 0,],
	sqrt(mean((mu_obs_hat - log(rootvol.mm3.mm2))^2, na.rm=TRUE)))
var_log = with(
	rzdat[rzdat$rootvol.mm3.mm2 > 0,],
	var(log(rootvol.mm3.mm2)))

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
print(plot(rz_mtd, pars=plotpars_mod[!grepl("lp__", plotpars_mod)]))
print(plot(rz_mtd, pars=plotpars_pred))
print(plot(rz_mtd, pars="crop_tot", show_density=TRUE))
print(plot(rz_mtd, pars="crop_tot_diff", show_density=TRUE))
print(plot(rz_mtd, pars="crop_bdepth_diff", show_density=TRUE))
print(plot(rz_mtd, pars="crop_int_diff", show_density=TRUE))
print(plot(rz_mtd, pars=c("sig_tube", "sigma"), show_density=TRUE))
print(traceplot(rz_mtd, pars=plotpars_mod))
print(traceplot(rz_mtd, pars=plotpars_pred))
print(stan_dens(rz_mtd, pars=plotpars_mod, separate_chains=TRUE))
print(stan_dens(rz_mtd, pars=plotpars_pred, separate_chains=TRUE))
print(stan_ac(rz_mtd, pars=plotpars_mod))
print(stan_ac(rz_mtd, pars=plotpars_pred))
stan_diag(rz_mtd) # no print call needed -- it plots itself without asking us.
print(
	ggplot(rzdat, aes(Depth, log(rootvol.mm3.mm2)))
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
		y=log(rootvol.mm3.mm2)))
	+geom_abline()
	+geom_errorbarh(color="grey")
	+geom_point()
	+geom_smooth(method="lm")
	+facet_wrap(~Species)
	+xlab(expression(Predicted~ln(~mm^3~root~mm^-2~image)))
	+ylab(expression(Observed~ln(~mm^3~root~mm^-2~image)))
	+theme_bw(36)
	+theme(aspect.ratio=1))
dev.off()


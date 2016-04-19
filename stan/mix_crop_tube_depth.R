set.seed(234587)
library(rstan)

sessionInfo()

args=commandArgs(trailingOnly=TRUE)
runname = args[[1]]
sub_year = as.numeric(args[[2]])
sub_session = as.numeric(args[[3]])
if(length(args)==4){
	# How many rows from WITHIN year and session to subsample?
	# Will error if n_subsample > n rows where Year==sub_year & Session==sub_session
	n_subsample = as.numeric(args[[4]])
}else{
	# If unset, use all rows.
	n_subsample = NULL
}

rstan_options(auto_write = TRUE)
options(mc.cores=7)
n_chains = 7
n_iters = 20000
n_warm = 1000
n_predtubes = 4
pred_depths = c(1, 10 , 30, 50, 75, 100, 140)
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

source("../scripts/stat-prep.R") # creates data frame "strpall"
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

rzdat = rzdat[order(rzdat$rootvol.mm3.mm2),]

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
		y_logi=as.numeric(rzdat$rootvol.mm3.mm2 > 0),
		first_pos=which(rzdat$rootvol.mm3.mm2 > 0)[1],
		n_pos=length(which(rzdat$rootvol.mm3.mm2 > 0)),
		crop_first_tube=cropkey$first_tube_alias,
		crop_num_tubes=cropkey$n_tubes,
		N_pred=nrow(rz_pred),
		T_pred=length(unique(rz_pred$tube)),
		C_pred=length(unique(rz_pred$Species)),
		tube_pred=rz_pred$tube,
		depth_pred=rz_pred$depth,
		crop_pred=as.numeric(rz_pred$Species)),
	file="mix_crop_tube_depth.stan",
	iter=n_iters,
	warmup=n_warm,
	chains=n_chains,
	pars=savepars,
	# sample_file=paste0(runname, "_samples.txt"),
	# diagnostic_file=paste0(runname, "_info.txt"),
	verbose=TRUE,
	open_progress=FALSE)

save(rz_mtd, rzdat, rz_pred, cropkey, file=paste0(runname, ".Rdata"))
warnings()
stopifnot(rz_mtd@mode == 0) # 1 or 2 = error

print(rz_mtd, pars=plotpars_mod)
print(rz_mtd, pars=plotpars_pred)
print(paste("mean of depth:", mean(rzdat$Depth)))
print(paste(
	"mean of log(nonzero root volume):",
	mean(log(rzdat$rootvol.mm3.mm2[rzdat$rootvol.mm3.mm2 > 0]))))

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
	formula=rootvol.mm3.mm2 ~ I(round(Depth*2, -1)/2), # rounds to nearest 5 cm
	data=rzdat,
	FUN=function(x)length(which(x>0))/length(x))
names(rzdat_pdet)=c("Depth", "p_detect")
png(
	paste0(runname, "_%03d.png"),
	height=1200,
	width=1800,
	units="px")
print(plot(rz_mtd, pars=plotpars_mod))
print(plot(rz_mtd, pars=plotpars_pred))
print(plot(rz_mtd, pars="crop_tot", show_density=TRUE))
print(plot(rz_mtd, pars="crop_tot_diff", show_density=TRUE))
print(plot(rz_mtd, pars="crop_bdepth_diff", show_density=TRUE))
print(plot(rz_mtd, pars="crop_int_diff", show_density=TRUE))
print(plot(rz_mtd, pars=c("sig_tube", "sigma"), show_density=TRUE))
print(traceplot(rz_mtd, pars=plotpars_mod))
print(traceplot(rz_mtd, pars=plotpars_pred))
print(traceplot(rz_mtd, inc_warmup=TRUE, pars=plotpars_mod))
print(traceplot(rz_mtd, inc_warmup=TRUE, pars=plotpars_pred))
# print(pairs(rz_mtd, pars=plotpars_mod))
# print(pairs(rz_mtd, pars=plotpars_pred))
print(stan_hist(rz_mtd, pars=plotpars_mod))
print(stan_hist(rz_mtd, pars=plotpars_pred))
print(stan_dens(rz_mtd, pars=plotpars_mod))
print(stan_dens(rz_mtd, pars=plotpars_pred))
print(stan_ac(rz_mtd, pars=plotpars_mod))
print(stan_ac(rz_mtd, pars=plotpars_pred))
print(stan_diag(rz_mtd))
print(
	ggplot(rzdat, aes(Depth, log(rootvol.mm3.mm2)))
	+geom_point()
	+facet_wrap(~Species)
	+geom_smooth(
		aes(depth, mean, color="pred_mu"),
		data=rz_pred_mu,
		se=FALSE)
	+geom_smooth(
		aes(depth, `2.5%`, color="pred_mu"),
		data=rz_pred_mu,
		se=FALSE)
	+geom_smooth(
		aes(depth, `97.5%`, color="pred_mu"),
		data=rz_pred_mu,
		se=FALSE)
	+geom_smooth(
		aes(depth, mean, color="pred_mu_obs"),
		data=rz_pred_mu_obs,
		se=FALSE)
	+geom_smooth(
		aes(depth, `2.5%`, color="pred_mu_obs"),
		data=rz_pred_mu_obs,
		se=FALSE)
	+geom_smooth(
		aes(depth, `97.5%`, color="pred_mu_obs"),
		data=rz_pred_mu_obs,
		se=FALSE)
	+geom_smooth(
		aes(depth, mean, color="pred_y"),
		data=rz_pred_y_pos,
		se=FALSE)
	+geom_smooth(
		aes(depth, `2.5%`, color="pred_y"),
		data=rz_pred_y_pos,
		se=FALSE)
	+geom_smooth(
		aes(depth, `50%`, color="pred_y median"),
		data=rz_pred_y_pos,
		se=FALSE)
	+geom_smooth(
		aes(depth, `97.5%`, color="pred_y"),
		data=rz_pred_y_pos,
		se=FALSE)
	+coord_flip()
	+scale_x_reverse()
	+theme_bw(36)
	+theme(aspect.ratio=1.2))
print(
	ggplot(rzdat_pdet, aes(Depth, p_detect))
	+geom_point()
	+geom_smooth(
		aes(depth, mean, color="pred_pdet"),
		data=rz_pred_pdet,
		se=FALSE)
	+geom_smooth(
		aes(depth, `2.5%`, color="pred_pdet"),
		data=rz_pred_pdet,
		se=FALSE)
	+geom_smooth(
		aes(depth, `97.5%`, color="pred_pdet"),
		data=rz_pred_pdet,
		se=FALSE)
	+geom_smooth(
		aes(depth, p_detect, color="pred_y"),
		data=rz_pred_y_det,
		se=FALSE)
	+coord_flip()
	+scale_x_reverse()
	+theme_bw(36)
	+theme(aspect.ratio=1.2))
dev.off()


#set.seed(234587)
library(rstan)

sessionInfo()

runname=commandArgs(trailingOnly=TRUE)[[1]]

n_subsample = 1000 # how many rows to pick from the full dataset?

rstan_options(auto_write = TRUE)
options(mc.cores=7)
n_chains = 7
n_iters = 3000
n_warm = 1000
n_predtubes = 5
pred_depths = c(1, 10 , 30, 50, 75, 100, 140)
savepars=c(
	"a_detect",
	"b_detect",
	"loc_surface",
	"scale_surface",
	"intercept",
	"b_depth",
	"sig_tube",
	"sigma",
	"mu_obs_mean",
	"y_pred",
	"mu_pred",
	"mu_obs_pred",
	"detect_odds_pred",
	"pred_tot", 
	"lp__")
plotpars_mod=c(
	"a_detect",
	"b_detect",
	"loc_surface",
	"scale_surface",
	"intercept",
	"b_depth",
	"sig_tube",
	"sigma",
	"mu_obs_mean",
	"lp__")
plotpars_pred=c(
	"y_pred[1]",
	"y_pred[15]",
	"y_pred[35]",
	"mu_pred[1]",
	"mu_pred[15]",
	"mu_pred[35]",
	"mu_obs_pred[1]",
	"mu_obs_pred[15]",
	"mu_obs_pred[35]",
	"detect_odds_pred[1]",
	"detect_odds_pred[15]",
	"detect_odds_pred[35]",
	"pred_tot[1]")

source("../scripts/stat-prep.R") # creates data frame "strpall"
strpall = strpall[strpall$Depth > 0,]

rows_used = sample(1:nrow(strpall), n_subsample)
rzdat = strpall[rows_used,]
rm(strpall)
print(paste("Subsampling these", n_subsample, "rows from strpall:"))
print(dput(rows_used))

# Stan expects tube numbers to be in 1:T. If subsetting, must remap.
tube_map = data.frame(Tube=sort(unique(rzdat$Tube)))
tube_map$Tube_alias = seq_along(tube_map$Tube)
rzdat=merge(rzdat, tube_map)
print(dput(tube_map))

rzdat = rzdat[order(rzdat$rootvol.mm3.mm2),]

rz_pred = expand.grid(
	tube=1:n_predtubes,
	depth=pred_depths)

rz_mtd = stan(
	data=list(
		N=nrow(rzdat), 
		T=length(unique(rzdat$Tube_alias)),
		tube=rzdat$Tube_alias,
		depth=rzdat$Depth,
		y=rzdat$rootvol.mm3.mm2,
		y_logi=as.numeric(rzdat$rootvol.mm3.mm2 > 0),
		first_pos=which(rzdat$rootvol.mm3.mm2 > 0)[1],
		n_pos=length(which(rzdat$rootvol.mm3.mm2 > 0)),
		N_pred=nrow(rz_pred),
		T_pred=length(unique(rz_pred$tube)),
		tube_pred=rz_pred$tube,
		depth_pred=rz_pred$depth),
	file="mix_tube_depth.stan",
	iter=n_iters,
	warmup=n_warm,
	chains=n_chains,
	pars=savepars,
	sample_file=paste0(runname, "_samples.txt"),
	diagnostic_file=paste0(runname, "_info.txt"),
	verbose=TRUE,
	open_progress=FALSE)

save(rz_mtd, file=paste0(runname, ".Rdata"))
warnings()
stopifnot(rz_mtd@mode == 0) # 1 or 2 = error

print(rz_mtd, pars=plotpars_mod)
print(rz_mtd, pars=plotpars_pred)
print(paste("mean of depth:", mean(rzdat$Depth)))

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
print(traceplot(rz_mtd, pars=plotpars_mod))
print(traceplot(rz_mtd, pars=plotpars_pred))
print(traceplot(rz_mtd, inc_warmup=TRUE, pars=plotpars_mod))
print(traceplot(rz_mtd, inc_warmup=TRUE, pars=plotpars_pred))
print(pairs(rz_mtd, pars=plotpars_mod))
print(pairs(rz_mtd, pars=plotpars_pred))
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
	+geom_smooth(aes(depth, mean, color="pred_mu"), data=rz_pred_mu)
	+geom_smooth(aes(depth, `2.5%`, color="pred_mu"), data=rz_pred_mu)
	+geom_smooth(aes(depth, `97.5%`, color="pred_mu"), data=rz_pred_mu)
	+geom_smooth(
		aes(depth, mean, color="pred_mu_obs"),
		data=rz_pred_mu_obs)
	+geom_smooth(
		aes(depth, `2.5%`, color="pred_mu_obs"),
		data=rz_pred_mu_obs)
	+geom_smooth(
		aes(depth, `97.5%`, color="pred_mu_obs"),
		data=rz_pred_mu_obs)
	+geom_smooth(aes(depth, mean, color="pred_y"), data=rz_pred_y_pos)
	+geom_smooth(aes(depth, `2.5%`, color="pred_y"), data=rz_pred_y_pos)
	+geom_smooth(aes(depth, `50%`, color="pred_y median"), data=rz_pred_y_pos)
	+geom_smooth(aes(depth, `97.5%`, color="pred_y"), data=rz_pred_y_pos)
	+theme_bw(48))
print(
	ggplot(rzdat_pdet, aes(Depth, p_detect))
	+geom_point()
	+geom_smooth(aes(depth, mean, color="pred_pdet"), data=rz_pred_pdet)
	+geom_smooth(aes(depth, `2.5%`, color="pred_pdet"), data=rz_pred_pdet)
	+geom_smooth(aes(depth, `97.5%`, color="pred_pdet"), data=rz_pred_pdet)
	+geom_smooth(aes(depth, p_detect, color="pred_y"), data=rz_pred_y_det)
	+theme_bw(48))
dev.off()


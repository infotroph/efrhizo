library(rstan)
library(dplyr)
# Called below without loading packages:
# tidyr::extract
# broom::tidyMCMC

# usage: Rscript extractfits_mctd.R path/to/standata.Rdata, path/to/output_csv_dir/, [identifier_to_add_to_filenames]
args=commandArgs(trailingOnly=TRUE)
rdata_path = args[[1]]
csv_path = args[[2]]
label = if(length(args)==3){ paste0("_", args[[3]]) } else { NULL }

extend_csv = function(x, file){
	# Because write.csv has no append argument :(
	if(file.exists(file)){
		write.table(x, file, append=TRUE,
			col.names=FALSE, row.names=FALSE,
			quote=FALSE, qmethod="double",
			sep=",", dec=".", eol="\n")
	}else{
		write.table(x, file, append=FALSE,
			col.names=TRUE, row.names=FALSE,
			quote=FALSE, qmethod="double",
			sep=",", dec=".", eol="\n")
	}
}

# Assumes the rdata file contains four objects:
# rz_mtd, a stanfit object fit using mix_crop_tube_depth.stan
#	Note the misnomer! Should arguably be called rz_mctd
# rzdat, a dataframe containing the subset of raw data rows used for this fit
#	Exactly which subset depends on runtime settings -- get these from the logs.
#	Contains all columns present in data/stripped*.csv, 
#	plus "tube_alias", which maps "Tube" from 1:96 to 1:(n_tubes_present_in_this_run).
# rz_pred, a dataframe containing the pseudodata I used to generate predicted values.
#	Contains columns "tube", "depth", "species".
# priors, a named list of the means/sds passed to prior distributions this run.
load(rdata_path)

year = unique(rzdat$Year)
session = unique(rzdat$Session)

if(any(length(year) != 1, length(session) != 1)){
	stop(paste(
		"This script needs model output from just one year/session, but file ",
		rdata_path,
		" seems to contain several sessions."))
}

sesdate=mean(rzdat$Date)

# Map numbers back to crop names
crop_id = data.frame(
	num=1:nlevels(rzdat$Species),
	name=levels(rzdat$Species))

#nth difference is always (crop n+1) - (crop 1)
crop_diff_id = data.frame(
	num=1:(nrow(crop_id) - 1),
	pair=paste(crop_id$name[2:nrow(crop_id)], "-", crop_id$name[[1]]))


# Estimated total root volume in the whole soil profile, per crop
croptot = cbind(crop_id, summary(rz_mtd, pars="crop_tot")$summary)
croptot$Year = year
croptot$Run_ID = label
croptot$Session = session
croptot$Date = sesdate

cropint = cbind(crop_id, summary(rz_mtd, pars="intercept")$summary)
cropint$Year = year
cropint$Run_ID = label
cropint$Session = session
cropint$Date = sesdate

cropb = cbind(crop_id, summary(rz_mtd, pars="b_depth")$summary)
cropb$Year = year
cropb$Run_ID = label
cropb$Session = session
cropb$Date = sesdate

cropsig = cbind(crop_id, summary(rz_mtd, pars="sigma")$summary)
cropsig$Year = year
cropsig$Run_ID = label
cropsig$Session = session
cropsig$Date = sesdate

# Estimated differences between crops:
# intercept (avg log root volume at middle depth)  
crop_diff_int = cbind(
	crop_diff_id,
	summary(rz_mtd, pars="crop_int_diff")$summary)
crop_diff_int$param = "intercept"

# beta_depth ("How fast does log volume decline with log depth?") 
crop_diff_bdepth = cbind(
	crop_diff_id,
	summary(rz_mtd, pars="crop_bdepth_diff")$summary)
crop_diff_bdepth$param = "b_depth"

# total volume
crop_diff_total = cbind(
	crop_diff_id,
	summary(rz_mtd, pars="crop_tot_diff")$summary)
crop_diff_total$param = "crop_tot"

crop_diff = rbind(crop_diff_int, crop_diff_bdepth, crop_diff_total)
crop_diff$Year = year
crop_diff$Session = session
crop_diff$Date = sesdate


# Expected root volume at each depth, by crop.
# Includes variability from locations (tube effect)
# TODO: Does this correctly account for uncertainty in other parameters, e.g. surface effect?
rz_pred_mu = cbind(
	rz_pred,
	summary(rz_mtd, pars="mu_pred")$summary)
rz_pred_mu$Year = year
rz_pred_mu$Session = session
rz_pred_mu$Date = sesdate

rz_pred_pdet = cbind(
	rz_pred,
	summary(rz_mtd, pars="mu_pred")$summary)
rz_pred_pdet$Year = year
rz_pred_pdet$Session = session
rz_pred_pdet$Date = sesdate

prior_df = (as.data.frame(priors)
	%>% gather(key, value)
	%>% extract(key, c("parameter", "key"), "(.*)_prior_(\\w)")
	%>% mutate(key=recode(key, "m"="prior_mean", "s"="prior_sd"))
	%>% spread(key, value))

rz_pars = (
	broom::tidyMCMC(
		x=rz_mtd,
		pars=prior_df$parameter,
		conf.int=TRUE,
		conf.level=0.95.
		ess=TRUE,
		rhat=TRUE)
	%>% rename(conf_2.5=conf.low, conf_97.5=conf.high)
	%>% left_join(broom::tidyMCMC(
		x=rz_mtd,
		pars=prior_df$parameter,
		conf.int=TRUE,
		conf.level=0.5.
		ess=TRUE,
		rhat=TRUE))
	%>% rename(conf_25=conf.low, conf_75=conf.high)
	%>% mutate( # identifiers for use after merging into bigger file
		Year=year,
		Session=session,
		Date=sesdate,
		Run_ID=label)
	%>% tidyr::extract(# "vec_par[1]" -> (vec_par, 1), "scalar_par" -> (scalar_par, NA)
		col=term,
		into=c("parameter", "crop_num"),
		regex="([^\\[]+)\\[?(\\d*)\\]?",
		remove=FALSE,
		convert=TRUE)
	%>% left_join(cropkey %>% select(crop_num=num, crop_name=name))
	%>% left_join(prior_df)
)

# Could just do get_posterior_mean(...)[,n_chains+1],
# but this way works even if result has fewer columns than expected
# (e.g. when some chains have sampling errors)
get_postmean_allchains = function(stanobj, ...){
	x = get_posterior_mean(stanobj, ...)
	x[,ncol(x)]
}
rzdat$mu_hat = get_postmean_allchains(rz_mtd, "mu")
rzdat$mu_obs_hat = get_postmean_allchains(rz_mtd, "mu_obs")
rzdat$detect_odds_hat = get_postmean_allchains(rz_mtd, "detect_odds")
rzdat$sig_hat = get_postmean_allchains(rz_mtd, "sig")

fit_stats = with(
	rzdat[rzdat$rootvol.mm3.mm2 > 0,],
	data.frame(
		MSE=mean((mu_obs_hat - log(rootvol.mm3.mm2))^2, na.rm=TRUE),
		mean_y = mean(log(rootvol.mm3.mm2)),
		var_y = var(log(rootvol.mm3.mm2))))
fit_stats$RMSE = sqrt(fit_stats$MSE)
fit_stats$CV_RMSE = fit_stats$RMSE / fit_stats$mean_y
fit_stats$FVU = fit_stats$MSE / fit_stats$var_y
fit_stats$Year = year
fit_stats$Session = session
fit_stats$Run_ID = label
fit_stats$Date = sesdate

obs_v_pred = rzdat[, c(
	"Year", "Session", "Date", "Tube",
	"Block", "Species", "Depth",
	"rootvol.mm3.mm2", "mu_hat", "mu_obs_hat",
	"detect_odds_hat", "sig_hat")]

extend_csv(
	obs_v_pred,
	file=file.path(csv_path, paste0("obs_vs_pred", label, ".csv")))
extend_csv(
	rz_pred_mu,
	file=file.path(csv_path, paste0("predmu", label, ".csv")))
extend_csv(
	croptot,
	file=file.path(csv_path, paste0("croptotals", label, ".csv")))
extend_csv(
	crop_diff,
	file=file.path(csv_path, paste0("cropdiffs", label, ".csv")))
extend_csv(
	cropint,
	file=file.path(csv_path, paste0("cropintercepts", label, ".csv")))
extend_csv(
	cropb,
	file=file.path(csv_path, paste0("cropbdepths", label, ".csv")))
extend_csv(
	cropsig,
	file=file.path(csv_path, paste0("cropsigmas", label, ".csv")))
extend_csv(
	rz_pars,
	file=file.path(csv_path, paste0("params", label, ".csv")))
extend_csv(
	fit_stats,
	file=file.path(csv_path, paste0("fit", label, ".csv")))

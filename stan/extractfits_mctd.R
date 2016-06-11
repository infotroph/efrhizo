library(rstan)

# usage: Rscript extractfits_mctd.R path/to/output.Rdata, path/to/csv_dir/, [identifier_to_add_to_filenames]
args=commandArgs(trailingOnly=TRUE)
rdata_path = args[[1]]
csv_path = args[[2]]
label = if(length(args)==3){ paste0("_", args[[3]]) } else { NULL }

# Assumes the rdata file contains three objects:
# rz_mtd, a stanfit object fit using mix_crop_tube_depth.stan
#	Note the misnomer! Should arguably be called rz_mctd
# rzdat, a dataframe containing the subset of raw data rows used for this fit
#	Exactly which subset depends on runtime settings -- get these from the logs.
#	Contains all columns present in data/stripped*.csv, 
#	plus "tube_alias", which maps "Tube" from 1:96 to 1:(n_tubes_present_in_this_run).
# rz_pred, a dataframe containing the pseudodata I used to generate predicted values.
#	Contains columns "tube", "depth", "species".
load(rdata_path)

year = unique(rzdat$Year)
session = unique(rzdat$Session)

if(any(length(year) != 1, length(session) != 1)){
	stop(paste(
		"This script needs model output from just one year/session, but file ",
		rdata_path,
		" seems to contain several sessions."))
}


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

cropint = cbind(crop_id, summary(rz_mtd, pars="intercept")$summary)
cropint$Year = year
cropint$Run_ID = label
cropint$Session = session

cropb = cbind(crop_id, summary(rz_mtd, pars="b_depth")$summary)
cropb$Year = year
cropb$Run_ID = label
cropb$Session = session

cropsig = cbind(crop_id, summary(rz_mtd, pars="sigma")$summary)
cropint$Year = year
cropint$Run_ID = label
cropint$Session = session

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


# Expected root volume at each depth, by crop.
# Includes variability from locations (tube effect)
# TODO: Does this correctly account for uncertainty in other parameters, e.g. surface effect?
rz_pred_mu = cbind(
	rz_pred,
	summary(rz_mtd, pars="mu_pred")$summary)
rz_pred_mu$Year = year
rz_pred_mu$Session = session

rz_pred_pdet = cbind(
	rz_pred,
	summary(rz_mtd, pars="mu_pred")$summary)
rz_pred_mu$Year = year
rz_pred_mu$Session = session

parnames = c("loc_detect",
	"scale_detect",
	"loc_surface",
	"scale_surface",
	"sig_tube",
	"intercept",
	"b_depth",
	"sigma",
	"lp__")
rz_pars = as.data.frame(summary(rz_mtd, pars=parnames)$summary)
rz_pars$Year = year
rz_pars$Session = session
rz_pars$Run_ID = label
rz_pars$parameter = rownames(rz_pars)

write.csv(
	rz_pred_mu,
	file=file.path(csv_path, paste0("predmu_", year, "_", session, label, ".csv")),
	row.names=FALSE)
write.csv(
	croptot,
	file=file.path(csv_path, paste0("croptotals_", year, "_", session, label, ".csv")),
	row.names=FALSE)
write.csv(
	crop_diff,
	file=file.path(csv_path, paste0("cropdiffs_", year, "_", session, label, ".csv")),
	row.names=FALSE)
write.csv(
	cropint,
	file=file.path(csv_path, paste0("cropintercepts_", year, "_", session, label, ".csv")),
	row.names=FALSE)
write.csv(
	cropb,
	file=file.path(csv_path, paste0("cropbdepths_", year, "_", session, label, ".csv")),
	row.names=FALSE)
write.csv(
	cropsig,
	file=file.path(csv_path, paste0("cropsigmas_", year, "_", session, label, ".csv")),
	row.names=FALSE)
write.csv(
	rz_pars,
	file=file.path(csv_path, paste0("params_", year, "_", session, label, ".csv")),
	row.names=FALSE)

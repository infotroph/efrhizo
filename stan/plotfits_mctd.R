library("ggplot2")
library("DeLuciatoR")
library("ggplotTicks")
library("cowplot")
library("scales")
library("dplyr")
library("viridis")

# usage: Rscript plotfit_mctd.R path/to/csvs/ path/to/images/
args=commandArgs(trailingOnly=TRUE)
csv_path = file.path(args[[1]])
img_path = file.path(args[[2]])


cropdiff_csvs = list.files(
	path=csv_path,
	pattern="cropdiffs.*.csv",
	full.names=TRUE)
cropdiff = lapply(cropdiff_csvs, read.csv, check.names=FALSE)
cropdiff = do.call("rbind", cropdiff)

croptot_csvs = list.files(
	path=csv_path,
	pattern="croptotals.*.csv",
	full.names=TRUE)
croptot = lapply(croptot_csvs, read.csv, check.names=FALSE)
croptot = do.call("rbind", croptot)

predmu_csvs = list.files(
	path=csv_path,
	pattern="predmu.*.csv",
	full.names=TRUE)
predmu = lapply(predmu_csvs, read.csv, check.names=FALSE)
predmu = do.call("rbind", predmu)
 
param_csvs = list.files(
	path=csv_path,
	pattern="params.*.csv",
	full.names=TRUE)
param_ests = lapply(param_csvs, read.csv, check.names=FALSE)

param_ests = do.call("rbind", param_ests)


fitstat_csvs = list.files(
	path=csv_path,
	pattern="fit.*.csv",
	full.names=TRUE)
fitstats = lapply(fitstat_csvs, read.csv, check.names=FALSE)
fitstats = do.call("rbind", fitstats)

obsvsfit_csvs = list.files(
	path=csv_path,
	pattern="obs_vs_pred.*.csv",
	full.names=TRUE)
obsvsfit = lapply(obsvsfit_csvs, read.csv, check.names=FALSE)
obsvsfit = do.call("rbind", obsvsfit)


# Set factor levels, so that panel order doesn't depend on order in file
predmu$Species=reorder(
	predmu$Species,
	match(predmu$Species, c("Maize-Soybean", "Switchgrass", "Miscanthus", "Prairie")))
croptot$name=reorder(
	croptot$name,
	match(croptot$name, c("Maize-Soybean", "Switchgrass", "Miscanthus", "Prairie")))

# To identify which sessions were midsummer "peak biomass" samplings 
peak = data.frame(
	Year = c(2010, 2011, 2012, 2013, 2014),
	Session = c(4,4,4,5,2))
peakstr = paste(peak$Year, peak$Session)

volume_expr = expression(paste("log(", mm^3, " root ", mm^2, " image)"))

# Root volume by depth
peak_plot = mirror_ticks(
	ggplot(predmu[paste(predmu$Year, predmu$Session) %in% peakstr,],
		aes(depth, mean, fill=factor(Year), color=factor(Year)))
	+facet_wrap(~Species)
	+geom_line()
 	+geom_ribbon(
		aes(x=depth, y=mean, ymin=`25%`, ymax=`75%`),
 		alpha=0.3)
	+coord_flip()
	+scale_x_reverse()
	+scale_color_viridis(discrete=TRUE)
	+scale_fill_viridis(discrete=TRUE)
	+theme_ggEHD()
	+ggtitle("peak each year")
	+ylab(volume_expr)
	+theme(aspect.ratio=1.2))
ggsave_fitmax(
	peak_plot,
	filename=file.path(img_path, "stanfit-peak.png"),
	maxheight=9,
	maxwidth=6.5,
	units="in")

# Root volume by depth, across sessions, within 2010 & 2012
ses10_plot = mirror_ticks(
	ggplot(data=predmu
		%>% filter(predmu$Year == 2010)
		%>% mutate(
			Species = factor(Species, labels = sub("Maize-Soybean", "Soybean", levels(Species)))),
		aes(depth, mean, fill=factor(Session), color=factor(Session)))
	+facet_wrap(~Species)
	+geom_line()
 	+geom_ribbon(
 		aes(x=depth, y=mean, ymin=`25%`, ymax=`75%`),
 		alpha=0.3)
	+coord_flip()
	+ylab(volume_expr)
	+scale_x_reverse()
	+scale_color_manual(
		name="Month", 
		labels=c(`1`="June", `3`="July", `4`="August", `5`="October"),
		values=viridis(5)[1:4])
	+scale_fill_manual(
		name="Month", 
		labels=c(`1`="June", `3`="July", `4`="August", `5`="October"),
		values=viridis(5)[1:4])
	+theme_ggEHD()
	+ggtitle("all days 2010")
	+theme(aspect.ratio=1.2))
ses12_plot = mirror_ticks(
	ggplot(data=predmu
		%>% filter(predmu$Year == 2012)
		%>% mutate(
			Species = factor(Species, labels = sub("Maize-Soybean", "Maize", levels(Species)))),
		aes(depth, mean, fill=factor(Session), color=factor(Session)))
	+facet_wrap(~Species)
	+geom_line()
 	+geom_ribbon(
 		aes(x=depth, y=mean, ymin=`25%`, ymax=`75%`),
 		alpha=0.3)
	+coord_flip()
	+scale_x_reverse()
	+scale_color_manual(
		name="Month", 
		labels=c(`1`="May", `2`="June", `3`="July", `4`="August", `5`="September", `6`="October"),
		values=viridis(7)[1:6])
	+scale_fill_manual(
		name="Month", 
		labels=c(`1`="May", `2`="June", `3`="July", `4`="August", `5`="September", `6`="October"),
		values=viridis(7)[1:6])
	+theme_ggEHD()
	+ggtitle("all days 2012")
	+ylab(volume_expr)
	+theme(aspect.ratio=1.2))
ggsave_fitmax(
	ses10_plot,
	filename=file.path(img_path, "stanfit-2010.png"),
	maxheight=9,
	maxwidth=6.5,
	units="in")
ggsave_fitmax(
	ses12_plot,
	filename=file.path(img_path, "stanfit-2012.png"),
	maxheight=9,
	maxwidth=6.5,
	units="in")

# Estimated total root volume from the whole soil profile.
# Somewhat improved from the version I showed Evan.
# TODO: Do I trust these numbers?
tots_plot = mirror_ticks(
	ggplot(croptot, aes(paste(Year, Session), mean, ymin=`2.5%`, ymax=`97.5%`, color=Run_ID))
	+facet_wrap(~name)
	+geom_pointrange(aes(lty="95%"), position=position_dodge(width=0.5))
	+geom_errorbar(aes(ymin=`25%`, ymax=`75%`, lty="50%"), position=position_dodge(width=0.5))
	+theme_ggEHD(12)
	# +coord_cartesian(ylim=c(0,20))
 	+theme(
		axis.text.x=element_text(angle=45, hjust=1))
 	+ggtitle("Crop totals?"))
ggsave_fitmax(
	tots_plot,
	filename=file.path(img_path, "stanfit-croptots.png"),
	maxheight=9,
	maxwidth=12,
	units="in")

params_plot = mirror_ticks(
	ggplot(
		param_ests[param_ests$parameter != "lp__",], 
		aes(
			paste(Year, Session),
			mean,
			ymin=`2.5%`,
			ymax=`97.5%`,
			color=Run_ID))
	+facet_wrap(~parameter, scales="free")
	+geom_pointrange(position=position_dodge(width=0.5))
	+theme_ggEHD(12)
 	+theme(
		axis.text.x=element_text(angle=45, hjust=1))
 	+ggtitle("posterior estimates (mean ± 95% interval)"))
ggsave_fitmax(
	params_plot,
	filename=file.path(img_path, "stanfit-params.png"),
	maxheight=18,
	maxwidth=18,
	units="in")

fits_plot = mirror_ticks(
	ggplot(
		fitstats,
		aes(
			paste(Year, Session),
			1-FVU,
			color=Run_ID))
	+geom_point()
	+theme_ggEHD(12)
	+theme(
		axis.text.x=element_text(angle=45, hjust=1))
	+ggtitle("fraction of variance explained"))
ggsave_fitmax(
	fits_plot,
	filename=file.path(img_path, "stanfit-fvu.png"),
	maxheight=8,
	maxwidth=8,
	units="in",
	dpi=300)


# Estimated differences between crops in:
# Total root volume, intercept, beta_depth
# MUCH improved from version I showed Evan, which version was best forgotten.
# TODO: do I trust these numbers?
# TODO: These variables should probably _not_ be plotted on the same scale
# or even in the same plot.
diff_int_plot = mirror_ticks(ggplot(subset(cropdiff, param=="intercept"), aes(paste(Year, Session), mean, ymin=`2.5%`, ymax=`97.5%`))
	+facet_grid(.~pair, scales="free")
	+geom_pointrange()
	+geom_hline(aes(yintercept=0), color="red")
 	+theme_ggEHD(12)
 	+theme(
		axis.text.x=element_text(angle=45, hjust=1))
 	+ggtitle("intercept difference between crops"))
diff_tot_plot = mirror_ticks(ggplot(subset(cropdiff, param=="crop_tot"), aes(paste(Year, Session), mean, ymin=`2.5%`, ymax=`97.5%`))
	+facet_grid(.~pair, scales="free")
	+geom_pointrange()
	+geom_hline(aes(yintercept=0), color="red")
 	+theme_ggEHD(12)
 	+theme(
		axis.text.x=element_text(angle=45, hjust=1))
 	+ggtitle("root volume difference between crops"))
diff_beta_plot = mirror_ticks(ggplot(subset(cropdiff, param=="b_depth"), aes(paste(Year, Session), mean, ymin=`2.5%`, ymax=`97.5%`))
	+facet_grid(.~pair, scales="free")
	+geom_pointrange()
	+geom_hline(aes(yintercept=0), color="red")
 	+theme_ggEHD(12)
 	+theme(
		axis.text.x=element_text(angle=45, hjust=1))
 	+ggtitle("b_depth difference between crops"))
ggsave_fitmax(
	plot_grid(
		diff_tot_plot,
		diff_int_plot,
		diff_beta_plot,
		ncol=1,
		labels="auto"),
	filename=file.path(img_path, "stanfit-cropdiffs.png"),
	maxheight=13,
	maxwidth=18,
	units="in")	

fitstats_all = (obsvsfit
	%>% filter(rootvol.mm3.mm2 > 0)
	%>% mutate(
		ln_y = log(rootvol.mm3.mm2),
		pred_lo90 = mu_obs_hat-sig_hat*1.64,
		pred_hi90 = mu_obs_hat+sig_hat*1.64,
		pred_lo50 = mu_obs_hat-sig_hat*0.67,
		pred_hi50 = mu_obs_hat+sig_hat*0.67,
		sq_res = (mu_obs_hat - ln_y)^2 )
	%>% summarize(
		MSE = mean(sq_res, na.rm=TRUE),
		mean_y = mean(ln_y),
		var_y = var(ln_y),
		f_cover90 = (
			length(which(ln_y >= pred_lo90 & ln_y <= pred_hi90)) / n()),
		f_cover50 = (
			length(which(ln_y >= pred_lo50 & ln_y <= pred_hi50)) / n()),
		lim_lo = min(pred_lo90, ln_y),
		lim_hi = max(pred_hi90, ln_y))
	%>% mutate(
		RMSE = sqrt(MSE),
		CV_RMSE = RMSE/mean_y,
		FVU = MSE/var_y,
		pct_expl = (1-FVU)*100))

allfits_plot = mirror_ticks(
	ggplot(obsvsfit, aes(
		x=mu_obs_hat,
		y=log(rootvol.mm3.mm2)))
	+geom_errorbarh(
		aes(xmin=mu_obs_hat-sig_hat*1.64, xmax=mu_obs_hat+sig_hat*1.64),
		color="grey")
	+geom_errorbarh(
		aes(xmin=mu_obs_hat-sig_hat*0.67, xmax=mu_obs_hat+sig_hat*0.67),
		color=viridis(3)[2],
		alpha=0.3)
	+geom_point()
	+geom_abline(lty="dashed")
	+geom_smooth(method="lm")
	+geom_text(
		data=fitstats_all,
		aes(x=lim_lo,
			y=lim_hi,
			label=paste( # plotmath on multiple lines will always be gross, lol
				"atop(",
					"atop(RMSE~", signif(RMSE, 3),
						", Variance~explained~", signif(pct_expl, 2), "*'%'),",
					"atop('1:1'~interval~coverage*':',",
						"90*'%'~", signif(f_cover90, 2),
						"*','~50*'%'~", signif(f_cover50, 2), ")",
				")",
				sep="")),
		parse=TRUE,
		inherit.aes=FALSE,
		size=8,
		hjust="inward",
		vjust="inward")
	+xlab(expression(Predicted~ln(~mm^3~root~mm^-2~image)))
	+ylab(expression(Observed~ln(~mm^3~root~mm^-2~image)))
	+theme_ggEHD()
	+coord_fixed(
		xlim=c(fitstats_all$lim_lo, fitstats_all$lim_hi),
		ylim=c(fitstats_all$lim_lo, fitstats_all$lim_hi))
	+theme(aspect.ratio=1))

ggsave_fitmax(
	allfits_plot,
	filename=file.path(img_path, "stanfit-obsvspred.png"),
	maxheight=9,
	maxwidth=9,
	units="in",
	dpi=300)

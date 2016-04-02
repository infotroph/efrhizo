library("ggplot2")
library("DeLuciatoR")
library("ggplotTicks")
library("cowplot")

# usage: Rscript plotfit_mctd.R path/to/csvs/ path/to/images/
args=commandArgs(trailingOnly=TRUE)
csv_path = file.path(args[[1]])
img_path = file.path(args[[1]])


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
 
# To identify which sessions were midsummer "peak biomass" samplings 
peak = data.frame(
	Year = c(2010, 2011, 2012, 2013, 2014),
	Session = c(4,4,4,5,2))
peakstr = paste(peak$Year, peak$Session)

# Root volume by depth, two ways
# First as shown to Evan 2016-03-31:
peak_plot = mirror_ticks(
	ggplot(predmu[paste(predmu$Year, predmu$Session) %in% peakstr,], aes(depth, mean, fill=factor(Year), color=factor(Year)))
	+facet_wrap(~Species)
	+geom_smooth(se=FALSE)
 	+geom_ribbon(
 		aes(x=depth, y=mean, ymin=`2.5%`, ymax=`97.5%`),
 		alpha=0.3)
	+coord_flip()
	+scale_x_reverse()
	+theme_ggEHD()
	+ggtitle("peak each year")
	+theme(aspect.ratio=1.2))
ggsave_fitmax(
	peak_plot,
	filename=file.path(img_path, "stanfit-peak.png"),
	maxheight=9,
	maxwidth=6.5,
	units="in")

# Second a quick attempt at implementing a suggestion from Evan
# (He suggested with emphasis it was experimental and might be a bad idea): 
# "Each species/year in own panel, with previous year faded out behind it"
peak_predmu = predmu[paste(predmu$Year, predmu$Session) %in% peakstr,]
levels(peak_predmu$Species) = list(
	"Maize/Soybean"="Maize",
	"Maize/Soybean"="Soy",
	"Miscanthus"="Miscanthus",
	"Switchgrass"="Switchgrass",
	"Prairie"="Prairie")
prev_predmu = peak_predmu
prev_predmu$Year = prev_predmu$Year + 1
prev_predmu = prev_predmu[prev_predmu$Year <= 2014,]
peakprev_plot = mirror_ticks(
	ggplot(
		peak_predmu,
		aes(depth, mean))
	+facet_grid(Species~Year)
	+geom_smooth(
		se=FALSE,
		data=prev_predmu,
		color="yellow",
		fill="yellow",
		alpha=0.3)
 	+geom_ribbon(
 		aes(x=depth, y=mean, ymin=`2.5%`, ymax=`97.5%`),
 		alpha=0.3,
 		fill="red",
 		data=prev_predmu)
	+geom_smooth(se=FALSE)
 	+geom_ribbon(
 		aes(x=depth, y=mean, ymin=`2.5%`, ymax=`97.5%`),
 		alpha=0.5)
 	+coord_flip()
	+scale_x_reverse()
	+theme_ggEHD(12)
	+ggtitle("peak each year")
	+theme(aspect.ratio=1.2))
ggsave_fitmax(
	peakprev_plot,
	filename=file.path(img_path, "stanfit-peakprev.png"),
	maxheight=9,
	maxwidth=6.5,
	units="in")

# Root volume by depth, across sessions, within 2010 & 2012
# TODO: Color schemes need work and should match each other
ses10_plot = mirror_ticks(
	ggplot(predmu[predmu$Year == 2010,], aes(depth, mean))
	+facet_wrap(~Species)
	+geom_smooth(se=FALSE, aes(color=Session))
 	+geom_ribbon(
 		aes(x=depth, y=mean, ymin=`2.5%`, ymax=`97.5%`, group=Session, fill=Session),
 		alpha=0.2)
	+coord_flip()
	+scale_x_reverse()
	+theme_ggEHD()
	+ggtitle("all days 2010")
	+theme(aspect.ratio=1.2))
ses12_plot = mirror_ticks(
	ggplot(predmu[predmu$Year == 2012,], aes(depth, mean, fill=factor(Session), color=factor(Session)))
	+facet_wrap(~Species)
	+geom_smooth(se=FALSE)
 	+geom_ribbon(
 		aes(x=depth, y=mean, ymin=`2.5%`, ymax=`97.5%`),
 		alpha=0.3)
	+coord_flip()
	+scale_x_reverse()
	+theme_ggEHD()
	+ggtitle("all days 2012")
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
	ggplot(croptot, aes(paste(Year, Session), mean, ymin=`2.5%`, ymax=`97.5%`))
	+facet_wrap(~name)
	+geom_pointrange()
	+theme_ggEHD(12)
 	+theme(
		axis.text.x=element_text(angle=45, hjust=1))
 	+ggtitle("Crop totals?"))
ggsave_fitmax(
	tots_plot,
	filename=file.path(img_path, "stanfit-croptots.png"),
	maxheight=9,
	maxwidth=6.5,
	units="in")

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

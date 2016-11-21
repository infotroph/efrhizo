library("ggplot2")
library("dplyr")
library("DeLuciatoR")
library("ggplotTicks")
library("viridis")

# Expects three arguments:
# 1. path to obs_vs_pred_<modelname>.csv, containing predictions from at least S4 2011 and S2 2014
# 2. path to tractorcore.csv, containing *only* those sessions,
# 3. path for output PNG
# ... But it doesn't check that for you, so be warned :(
stanpaths = commandArgs(trailingOnly=TRUE)

# Assumed root tissue densities. These are VERY crudely estimated,
# from a pretty token survey of the literature!
# Maize: Pahlavian and Silk 1988, 10.1104/pp.87.2.529
# Miscanthus: composite from generic perennial grasses including
#	Wahl and Ryser 2000, 10.1046/j.1469-8137.2000.00775.x2000
#	Roumet et al 2006 10.1111/j.1469-8137.2006.01667.x
#	Picon-Cochard et al 2011, 10.1007/s11104-011-1007-4
# Switchgrass and prairie: both Craine et al 10.1034/j.1600-0706.2001.930210.x
# Units: g cm^-3
root_tissue_density = c(
	"Maize"=0.08,
	"Miscanthus"=0.2,
	"Switchgrass"=0.19,
	"Prairie"=0.15)

# B.N. Taylor et al 2013, 10.1007/s11104-013-1930-7
# Units: mm
depth_of_view = 0.78

x_label = expression(Root~biomass~"("~ln~g~cm^-3~")")
y_label = expression(Root~volume~"("~ln~mm^3~mm^-2~")")

depth_cuts=c(0,10,30,50,100)

stanpred = (
	read.csv(stanpaths[[1]])
	%>% filter((Year == 2011 & Session == 4) | (Year == 2014 & Session == 2))
	%>% mutate(
		Crop = c(
			"Maize-Soybean"="Maize",
			"Miscanthus"="Miscanthus",
			"Switchgrass"="Switchgrass",
			"Prairie"="Prairie")[as.character(Species)],
		rtd = root_tissue_density[as.character(Crop)],
		dov = depth_of_view,
		Upper=as.numeric(as.character(cut(
			x=Depth,
			breaks=c(depth_cuts, Inf),
			labels=depth_cuts))))
	%>% select(-Species, -Tube, -Date, -Session)
	%>% group_by(Upper, Year, Crop, Block)
	%>% summarize_each(funs(mean, sd))
	%>% mutate(
			mu_hat_2.5 = mu_hat_mean-1.96*mu_hat_sd,
			mu_hat_97.5 = mu_hat_mean+1.96*mu_hat_sd))

core_logmeans = (
	read.csv(stanpaths[[2]])
	%>% rename(Crop=Treatment)
	%>% group_by(Year, Crop, Upper, Block)
	%>% summarize(
		rootmass=mean(log(Biomass_root_g_cm3), na.rm=TRUE),
		rootmass_sd=sd(log(Biomass_root_g_cm3), na.rm=TRUE))
	%>% mutate(
		rootmass_2.5=rootmass-1.96*rootmass_sd,
		rootmass_97.5=rootmass+1.96*rootmass_sd))

both = (
	core_logmeans
	%>% left_join(stanpred)
	%>% na.omit()) # rhizo data are missing 2014 maize blocks 1-4

plt = (ggplot(both,
		aes(
			x=rootmass,
			y=mu_hat_mean,
			color=factor(Year)))
	+ geom_errorbar(aes(ymin=mu_hat_2.5, ymax=mu_hat_97.5))
	+ geom_errorbarh(aes(xmin=rootmass_2.5, xmax=rootmass_97.5))
	+ geom_point()
	+ geom_smooth(
		method="lm",
		show.legend=FALSE)
	+ facet_wrap(~Crop)
	+ geom_abline(
		aes(intercept=log(dov_mean)-log(rtd_mean),
			slope=1,
			linetype="expected"))
	+ ylab(y_label)
	+ xlab(x_label)
	+ scale_color_grey()
	+ scale_linetype_manual(
		name="",
		values=c("expected"="dashed"),
		labels=c("expected"="Expected"))
	+ scale_y_continuous(sec.axis = dup_axis(name=NULL, labels=NULL))
	+ scale_x_continuous(sec.axis = dup_axis(name=NULL, labels=NULL))
	+ theme_ggEHD(16)
	+ theme(
		aspect.ratio=1,
		legend.position=c(0.15, 0.9),
		legend.margin=margin(0, 0, 0, 0, "cm"),
		legend.spacing=unit(0, "cm"),
		legend.title=element_blank(),
		legend.key=element_blank(),
		strip.background=element_blank(),
		strip.placement="outside"))

ggsave_fitmax(
	mirror_ticks(plt),
	filename=stanpaths[[3]],
	maxheight=9,
	maxwidth=6.5,
	units="in",
	dpi=300)

library("dplyr")
library("ggplot2")
library("DeLuciatoR")
library("ggplotTicks")
library("scales")
library("cowplot")
se = plotrix::std.error

## Constants
CORE_DIAM_CM = 1.50 * 2.54 #  Coring tube had 1.5" tip diameter
CORE_AREA_CM2 = pi * (CORE_DIAM_CM/2)^2
CORE_AREA_M2 = CORE_AREA_CM2 / 10000

# Function: Don't propagate NAs from missing CN data if there was no biomass to measure
pct_or_zero = function(mass, percent){
	stopifnot(length(mass) == length(percent))
	res = mass * percent/100
	res[mass==0 & is.na(percent)] = 0
	res
}




coredata=read.csv("data/tractorcore.csv")


# C and N data are missing for some individual samples, so: 
# 1. compute mean %C & %N of roots from each block/horizon,
# and mean %C/%N of rhizomes from each whole block 
# (only a few rhizomes seen in 10-30 layer, and a high proportion are missing CN)
# 2. Combine CN means with individual sample masses to estimate 
# C/N contents of individual samples.
# 3. Take block means of C/N contents. 
# 4. Compute mean/SE of whole field from block means. 

# BEWARE: RECALCULATES C AND N MASS COLUMNS OF COREDATA
# THIS IS VERY LIKELY A BAD IDEA BUT I'M GOING TO DO IT ANYWAY

core_blocks = (coredata
	%>% group_by(Year, Treatment, Block)
	%>% mutate(
		Cp_rhiz=mean(Pct_C_rhizome, na.rm=TRUE),
		Np_rhiz=mean(Pct_N_rhizome, na.rm=TRUE))
	%>% ungroup
	%>% group_by(Year, Treatment, Upper, Block)
	%>% mutate(
		Cp_root=mean(Pct_C_root, na.rm=TRUE),
		Np_root=mean(Pct_N_root, na.rm=TRUE))
	%>% ungroup
	%>% mutate(
		Mass_root_C = pct_or_zero(Mass_root, Cp_root),
		Mass_root_N = pct_or_zero(Mass_root, Np_root),
		Mass_rhizome_C = pct_or_zero(Mass_rhizome, Cp_rhiz),
		Mass_rhizome_N = pct_or_zero(Mass_rhizome, Np_rhiz),
		Mass_total_C = Mass_root_C + Mass_rhizome_C,
		Mass_total_N = Mass_root_N + Mass_rhizome_N,
		RootC_g_cm3 = Mass_root_C / (CORE_AREA_CM2 * Soil_length),
		RootN_g_cm3 = Mass_root_N / (CORE_AREA_CM2 * Soil_length),
		RootC_g_m2 = Mass_root_C / (CORE_AREA_M2 * Num_cores) / Layer_fraction,
		RootN_g_m2 = Mass_root_N / (CORE_AREA_M2 * Num_cores) / Layer_fraction,
		C_g_cm3 = Mass_total_C / (CORE_AREA_CM2 * Soil_length),
		N_g_cm3 = Mass_total_N / (CORE_AREA_CM2 * Soil_length), 
		C_g_m2 = Mass_total_C / (CORE_AREA_M2 * Num_cores) / Layer_fraction,
		N_g_m2 = Mass_total_N / (CORE_AREA_M2 * Num_cores) / Layer_fraction)
	%>% group_by(Year, Treatment, Upper, Block)
	%>% summarize_each(
		funs(mean(., na.rm=TRUE), se(., na.rm=TRUE)),
		Biomass_g_cm3,
		Biomass_g_m2,
		RootC_g_cm3,
		RootN_g_cm3,
		RootC_g_m2,
		RootN_g_m2,
		C_g_cm3,
		N_g_cm3,
		C_g_m2,
		N_g_m2,
		Midpoint))


# mean/se for whole field, disregarding within-block variance
core_avg = (core_blocks
	%>% mutate(
		Biomass_mg_cm3_mean=Biomass_g_cm3_mean*1000,
		RootC_mg_cm3_mean=RootC_g_cm3_mean*1000)
	%>% summarize_each(
		funs(mean(., na.rm=TRUE), se(., na.rm=TRUE)),
		ends_with("_mean")))
names(core_avg) = sub("_mean_mean", "", names(core_avg))
names(core_avg) = sub("_mean_se", "_se", names(core_avg))

core_avg$Upper = factor(core_avg$Upper, ordered=TRUE)
levels(core_avg$Upper) = list(
	"0-10"="0",
	"10-30"="10",
	"30-50"="30",
	"50-100"="50",
	"100+"="100")

coreline_root = (
	ggplot(core_avg, aes(
		x=Midpoint,
		xmax=Midpoint+Midpoint_se,
		xmin=Midpoint-Midpoint_se,
		y=RootC_mg_cm3,
		ymax=RootC_mg_cm3+RootC_mg_cm3_se,
		ymin=RootC_mg_cm3-RootC_mg_cm3_se,
		shape=Treatment))
	+ geom_point(size=3)
	+ geom_errorbar(width=4)
	+ geom_line()
	+ facet_wrap(~Year)
	+ scale_x_reverse()
	+ coord_flip()
	+ theme_ggEHD(18)
	+ theme(
		aspect.ratio=1.5,
		legend.position=c(0.8,0.25),
		legend.key=element_blank(),
		legend.title=element_blank())
	+ ylab(expression(paste("Root biomass, mg ", cm^-3)))
	+ xlab("Depth, cm")
	+ scale_shape_manual(
		values=c(Maize=21, Miscanthus=22, Prairie=23, Switchgrass=24))
)

coreline_rootrhizo = (
	ggplot(core_avg, aes(
		x=Midpoint,
		xmax=Midpoint+Midpoint_se,
		xmin=Midpoint-Midpoint_se,
		y=Biomass_mg_cm3,
		ymax=Biomass_mg_cm3+Biomass_mg_cm3_se,
		ymin=Biomass_mg_cm3-Biomass_mg_cm3_se,
		shape=Treatment))
	+ geom_point(size=3)
	+ geom_errorbar(width=4)
	+ geom_line()
	+ facet_wrap(~Year)
	+ scale_x_reverse()
	+ coord_flip()
	+ theme_ggEHD(18)
	+ theme(
		aspect.ratio=1.5,
		legend.position="none")
	+ ylab(expression(paste("Root + rhizome biomass, mg ", cm^-3)))
	+ xlab("Depth, cm")
	+ scale_shape_manual(
		values=c(Maize=21, Miscanthus=22, Prairie=23, Switchgrass=24))
)

corebars_root = (
	ggplot(core_avg, aes(
		x=Treatment,
		y=RootC_g_m2,
		fill=factor(Upper)))
	+ geom_bar(stat="identity", color="black", width=0.8)
	+ scale_fill_grey(name="Depth, cm", start=0, end=1)
	+ ylab(expression(paste("Root, g C ", m^-2)))
	+ xlab("")
	+ facet_wrap(~Year)
	+ scale_y_continuous(breaks=pretty_breaks(n=5))
	+ theme_ggEHD(14)
	+ theme(
		legend.position=c(0.13, 0.65),
		legend.key=element_blank(),
		legend.key.size=unit(0.8, "lines"),
		axis.ticks.x=element_blank(),
		axis.text.x=element_blank())
)
corebars_rootrhizo = (
	ggplot(core_avg, aes(
		x=Treatment,
		y=C_g_m2,
		fill=factor(Upper)))
	+ geom_bar(stat="identity", color="black", width=0.8)
	+ scale_fill_grey(name="Depth, cm", start=0, end=1)
	+ ylab(expression(paste("Root + rhizome, g C ", m^-2)))
	+ xlab("")
	+ facet_wrap(~Year)
	+ scale_y_continuous(breaks=pretty_breaks(n=5))
	+ theme_ggEHD(14)
	+ theme(
		legend.position="none",
		axis.ticks.x=element_blank(),
		axis.text.x=element_text(angle=45, hjust=1))
)


# note plain ggsave instead of ggsave_fitmax --
# get_dims doesn't understand plot_grid output,
# so compute sizes here for each subfigure and sum them.
dim_lr = get_dims(coreline_root, maxheight=9, maxwidth=6.5)
dim_lrr = get_dims(coreline_rootrhizo, maxheight=9, maxwidth=6.5)
dim_br = get_dims(corebars_root, maxheight=9, maxwidth=6.5)
dim_brr = get_dims(corebars_rootrhizo, maxheight=9, maxwidth=6.5)
lbardims = list(
	height = dim_lr$height + dim_lrr$height,
	width = max(dim_lr$width, dim_lrr$width))
bbardims = list(
	height = dim_br$height + dim_brr$height,
	width = max(dim_br$width, dim_brr$width))
ggsave(
	"figures/tractorcore-exp.png",
	plot_grid(
		ggplotGrob(mirror_ticks(coreline_root)),
		ggplotGrob(mirror_ticks(coreline_rootrhizo)),
		ncol=1,
		align="v",
		rel_heights=c(dim_lr$height, dim_lrr$height),
		labels="auto",
		label_size=24,
		hjust=-2,
		vjust=2),
	height=lbardims$height,
	width=lbardims$width,
	dpi=300)
ggsave(
	filename="figures/tractorcore-bars.png",
	plot=plot_grid(
		mirror_ticks(corebars_root, allPanels=TRUE),
		mirror_ticks(corebars_rootrhizo, allPanels=TRUE),
		ncol=1,
		align="v",
		rel_heights=c(dim_br$height, dim_brr$height),
		labels="auto",
		label_size=18,
		hjust=-4,
		vjust=2),
	height=bbardims$height,
	width=bbardims$width,
	dpi=300)

library("ggplot2")
library("dplyr")
library("DeLuciatoR")
library("ggplotTicks")
library("viridis")
se = plotrix::std.error

# Expects two paths pointing to predmu_<modelname>.csv from S4 2011 and S2 2014
# ... But it doesn't check that for you, so be warned :(
stanpaths = commandArgs(trailingOnly=TRUE)
stanlist = lapply(stanpaths, function(x){res=read.csv(x); res$sourcefile=x; res})
stanpred = do.call("rbind", stanlist)

coredata = read.csv("data/tractorcore.csv")

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

x_label = expression(Depth~"("~ln~cm~")")
y_label = expression(Root~biomass~"("~ln~g~cm^-3~")")

stanpred = (stanpred
	%>% mutate(
		Crop = c(
			"Maize-Soybean"="Maize",
			"Miscanthus"="Miscanthus",
			"Switchgrass"="Switchgrass",
			"Prairie"="Prairie")[as.character(Species)],
		rtd = root_tissue_density[as.character(Crop)],
		dov = depth_of_view,
		adjmean = mean - log(dov) + log(rtd), # = mean/dov*rtd on unit scale
		adj25 = X25. - log(dov) + log(rtd),
		adj75 = X75. - log(dov) + log(rtd),
		adj2.5 = X2.5. - log(dov) + log(rtd),
		adj97.5 = X97.5. - log(dov) + log(rtd),
		source="Minirhizotron"))

core_blocks = (coredata
	%>% group_by(Year, Treatment, Upper, Block)
	%>% summarize_each(
		funs(mean(., na.rm=TRUE), se(., na.rm=TRUE)),
		Biomass_g_cm3,
		Biomass_g_m2,
		Biomass_root_g_cm3,
		Biomass_root_g_m2,
		Midpoint)
	%>% rename(
		Depth=Midpoint_mean,
		Depth_se=Midpoint_se,
		Crop=Treatment)
	%>% mutate(source="Soil cores"))

plt = (ggplot(core_blocks,
		aes(
			x=log(Depth),
			y=log(Biomass_root_g_cm3_mean),
			fill=source,
			color=source,
			shape=source))
	+ geom_point()
	+ geom_ribbon(
		data=stanpred,
		aes(x=log(depth),
			y=adjmean,
			ymin=adj2.5,
			ymax=adj97.5),
		colour=NA,
		alpha=0.3)
	+ geom_point(
		data = stanpred,
		aes(log(depth), adjmean))
	+ geom_line(
		data = stanpred,
		aes(log(depth), adjmean))
	+ geom_smooth(
		method="lm",
		# color="black",
		show.legend=FALSE)
	+ facet_grid(Crop~Year)
	+ coord_flip()
	+ scale_x_reverse()
	+ ylab(y_label)
	+ xlab(x_label)
	+ scale_fill_viridis(discrete=TRUE, begin=0, end=0.8)
	+ scale_color_viridis(discrete=TRUE, begin=0, end=0.8)
	+ theme_ggEHD(16)
	+ theme(
		aspect.ratio=1,
		legend.position=c(0.55, 0.7),
		legend.title=element_blank(),
		legend.key=element_blank(),
		strip.background=element_blank()))

ggsave_fitmax(
	mirror_ticks(plt),
	filename="figures/stan-vs-cores.png",
	maxheight=9,
	maxwidth=6.5,
	units="in",
	dpi=300)

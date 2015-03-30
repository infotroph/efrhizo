require(ggplot2)
require(grid)
source("~/UI/daycent/tools/ggthemes.r")

strp14 = read.csv("data/stripped2014.csv")

levels(strp14$Species)[1] = "Maize"

monthcolors= c(
 	"May" = rgb(0.9, 1.0, 0.8),
 	"June" = rgb(0.8, 0.9, 0.6),
 	"July" = rgb(0.5, 0.8, 0.5),
 	"August" = rgb(0.1, 0.4, 0.2),
 	"October" = rgb(0.0, 0.2, 0.0))
mc14 = c(
	"1" = monthcolors[["June"]],
	"2" = monthcolors[["August"]])

p14 = (ggplot(strp14,
	aes(Depth, 
		log(rootvol.mm3.mm2+1e-4), 
		color=factor(Session), 
		fill=factor(Session)))
	+ theme_delucia()
	+ facet_wrap(~Species)
	+ coord_flip()
	+ scale_x_reverse()
	+ geom_smooth(method="lm", formula=y ~ poly(x,2))
	+ scale_color_manual(
		"Month",
		labels=c("June", "August"),
		values=mc14)
	+scale_fill_manual(
		labels=c("June", "August"),
	 	values=mc14)
	+ylab(expression(paste(
		"Log root volume (", mm^3, " root ", mm^-2, " image)")))
	+ggtitle("2014")
	+guides(
		color=guide_legend(override.aes=list(
			fill=mc14, color=mc14)), 
		fill= FALSE))


png(
	filename="figures/logvol-polyfit-2014.png",
	width=6.5, # destined for a powerpoint, want low rez
	height=6.5,
	units="in",
	res=300)
plot(p14)
dev.off()

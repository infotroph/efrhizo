require(ggplot2)
require(grid)
source("~/UI/daycent/tools/ggthemes.r")

strp10 = read.csv("data/stripped2010.csv")
strp12 = read.csv("data/stripped2012.csv")

levels(strp10$Species)[1] = "Soy"
levels(strp12$Species)[1] = "Maize"

monthcolors= c(
 	"May" = rgb(0.9, 1.0, 0.8),
 	"June" = rgb(0.8, 0.9, 0.6),
 	"July" = rgb(0.5, 0.8, 0.5),
 	"August" = rgb(0.1, 0.4, 0.2),
 	"October" = rgb(0.0, 0.2, 0.0))
mc10 = c(
	"1" = monthcolors[["May"]],
	"3" = monthcolors[["July"]],
	"4" = monthcolors[["August"]],
	"5" = monthcolors[["October"]])
mc12 = c(
	"1" = monthcolors[["May"]],
	"2" = monthcolors[["June"]],
	"3" = monthcolors[["July"]],
	"4" = monthcolors[["August"]])

p10 = (ggplot(strp10,
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
		labels=c("May", "July", "August", "October"),
		values=mc10)
	+scale_fill_manual(
		labels=c("May", "July", "August", "October"),
	 	values=mc10)
	+ylab(expression(paste(
		"Log root volume (", mm^3, " root ", mm^-2, " image)")))
	+ggtitle("2010")
	+guides(
		color=guide_legend(override.aes=list(
			fill=mc10, color=mc10)), 
		fill= FALSE))



p12 = (ggplot(strp12[strp12$Session<5,],
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
		labels=c("May", "June", "July", "August"),
		values=mc12)
	+ scale_fill_manual(
		"Month",
		labels=c("May", "June", "July", "August"),
		values=mc12)
	+ ylab(expression(paste(
		"Log root volume (", mm^3, " root ", mm^-2, " image)")))
	+ggtitle("2012")
	+guides(
		color=guide_legend(override.aes=list(
			fill=mc12, 
			color=mc12)), 
		fill= FALSE))

points12 = (ggplot(strp12[strp12$Session<5 & strp12$Species == "Maize",],
	aes(Depth, log(rootvol.mm3.mm2+1e-4), color=factor(Session)))
	+ theme_delucia()
	+ coord_flip()
	+ scale_x_reverse()
	+geom_point()
	+ scale_color_discrete(
		"Month 2012",
		labels=c("May", "June", "July", "August"))
	+ ylab(expression(paste(
		"Log root volume (", mm^3, " root ", mm^-2, " image)"))))

pl12 = (points12 + geom_smooth(method="lm", formula=y ~ poly(x,2)))

png(
	filename="figures/logvol-polyfit-2010.png",
	width=6.5, # destined for a powerpoint, want low rez
	height=6.5,
	units="in",
	res=300)
plot(p10)
dev.off()

png(
	filename="figures/logvol-polyfit-2012.png",
	width=6.5,

	height=6.5,
	units="in",
	res=300)
plot(p12)
dev.off()

png(
	filename="figures/logvol-cornpoints-2012.png",
	width=6.5,

	height=6.5,
	units="in",
	res=300)
plot(points12)
dev.off()

png(
	filename="figures/logvol-cornpointsline-2012.png",
	width=6.5,

	height=6.5,
	units="in",
	res=300)
plot(pl12)
dev.off()


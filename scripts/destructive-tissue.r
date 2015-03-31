library(ggplot2)
library(grid)
source("~/R/DeLuciatoR/ggthemes.r")
source("~/R/ggplot-ticks/mirror.ticks.r")
theme_set(theme_ggEHD())

roots = read.csv("rawdata/destructive-harvest/rhizo-destructive-belowground.csv")

samplevolumes = read.csv(text="
		Position, Depth.bottom.cm, cm.top, cm.bottom, nom.top, nom.bottom, Volume
		near, 5.0, 0.0, 4.3, 0, 4, 123.79
		near, 10.0, 4.3, 8.7, 4, 9, 160.56
		near, 15.0, 8.7, 13.0, 9, 13, 160.56
		near, 20.0, 13.0, 17.3, 13, 18, 160.56
		near, 25.0, 17.3, 21.7, 18, 22, 160.56
		near, 30.0, 21.7, 26.0, 22, 27, 160.56
		far, 4.5, 0.0, 4.5, 0, 4, 112.5
		far, 9.0, 4.5, 9.0, 4, 9, 112.5
		far, 13.5, 9.0, 13.5, 9, 13, 112.5
		far, 18.0, 13.5, 18.0, 13, 18, 112.5
		far, 22.5, 18.0, 22.5, 18, 22, 112.5
		far, 27.0, 22.5, 27.0, 22, 27, 112.5", 
		strip.white=TRUE)

roots$Crop = substr(roots$Code, 2, 2)
roots = merge(roots, samplevolumes)
roots$wet.bulk = with(roots, whole.fresh.wt.with.bag.g/Volume)
roots$root.per.cm3 = with(roots, g.root/Volume)

imgs = read.csv("data/stripped2014-destructive.csv")
imgs$Crop = imgs$Species


# align images to root samples. 
# Calibrations for today give image heights of about 1.18 cm, 
# so each image extends from(Depth-0.59) to (Depth+0.59).
# We'll just take the mean volume of all frames whose centers are within the 
# nominal sampling depth.
# image depths are only measured to nearest cm,
# so we can't get TOO picky about this.

mean.vol = function(tube,depthtop,depthbot){
	ixs = with(imgs, (
		Tube == tube 
		& Depth >= depthtop
		& Depth <= depthbot))
	return(mean(imgs$rootvol.mm3.mm2[ixs], na.rm=TRUE))
}

roots$Rootvol.seen = mapply(
	FUN=mean.vol, 
	tube=roots$Tube, 
	depthtop=roots$nom.top,
	depthbot=roots$nom.bottom)

png(
	filename="figures/destructive-mass.png",
	width=8,
	height=8,
	units="in",
	pointsize=18,
	res=300)
plot(mirror.ticks(ggplot(roots, aes(nom.bottom, root.per.cm3, color=Position))
+geom_smooth(method="lm", formula=y ~ poly(x,2))
+geom_point()
+facet_wrap(~Crop)
+coord_flip()
+scale_x_reverse()
+theme_ggEHD()
+xlab("Depth (cm)")
+ylab(expression(paste("Root mass (g ", "cm"^"-3", ")")))))
dev.off()

png(
	filename="figures/destructive-vol.png",
	width=8,
	height=8,
	units="in",
	res=300)
plot(mirror.ticks(ggplot(roots, aes(nom.bottom, Rootvol.seen))
+geom_smooth(method="lm", formula=y ~ poly(x,2))
+geom_point()
+facet_wrap(~Crop)
+coord_flip()
+scale_x_reverse()
+theme_ggEHD()
+xlab("Depth (cm)")
+ylab(expression(paste("Visible root volume (", mm^3, " cm"^"-2", ")")))))
dev.off()

png(
	filename="figures/destructive-vol-fulldepth.png",
	width=8,
	height=8,
	units="in",
	res=300)
plot(mirror.ticks(ggplot(imgs, aes(Depth, rootvol.mm3.mm2))
+geom_smooth(method="lm", formula=y ~ poly(x,2))
+geom_point()
+facet_wrap(~Species)
+coord_flip()
+scale_x_reverse()
+theme_ggEHD()
+xlab("Depth (cm)")
+ylab(expression(paste("Visible root volume (", mm^3, " cm"^"-2", ")")))))
dev.off()

png(
	filename="figures/destructive-massvsvol.png",
	width=8,
	height=8,
	units="in",
	res=300)
plot(mirror.ticks(ggplot(roots, 
	aes(root.per.cm3, Rootvol.seen, color=Position))
	+geom_point()
	+facet_wrap(~Crop)
	+geom_smooth(method="lm")
	+xlab(expression(paste("Root mass (g ", "cm"^"-3", ")")))
	+ylab(expression(paste("Visible root volume (", mm^3, " cm"^"-2", ")")))))
dev.off()


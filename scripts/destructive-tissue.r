library(ggplot2)
library(grid)
source("~/R/DeLuciatoR/ggthemes.r")
source("~/R/ggplot-ticks/mirror.ticks.r")
theme_set(theme_ggEHD())

destructive = read.csv("~/UI/efrhizo/rawdata/destructive-harvest/rhizo-destructive-belowground.csv")

samplevolumes = read.csv(text="
		Position, Depth.bottom.cm, cm.deep, nominal.depth, Volume
		near, 5.0, 4.3, 4, 123.79
		near, 10.0, 8.7, 9, 160.56
		near, 15.0, 13.0, 13, 160.56
		near, 20.0, 17.3, 18, 160.56
		near, 25.0, 21.7, 22, 160.56
		near, 30.0, 26.0, 27, 160.56
		far, 4.5, 4.5, 4, 112.5
		far, 9.0, 9.0, 9, 112.5
		far, 13.5, 13.5, 13, 112.5
		far, 18.0, 18.0, 18, 112.5
		far, 22.5, 22.5, 22, 112.5
		far, 27.0, 27.0, 27, 112.5", 
		strip.white=TRUE)

destructive$Crop = substr(destructive$Code, 2, 2)
destructive = merge(destructive, samplevolumes)
destructive$wet.bulk = with(destructive, whole.fresh.wt.with.bag.g/Volume)
destructive$root.per.cm3 = with(destructive, g.root/Volume)

(ggplot(destructive, aes(cm.deep, root.per.cm3,color=Position))
+geom_smooth(method="lm", formula=y ~ poly(x,2))
+geom_point()
+facet_wrap(~Crop)
+coord_flip()
+scale_x_reverse()
+theme_ggEHD())
require(ggplot2)
require(grid)
library(ggplotTicks)
library(DeLuciatoR)
theme_set(theme_ggEHD())



## By number of root tips:
foo = aggregate(TotNumberOfTips,by=list(Species=Species,Depth=Depth),std.error)
fooo = aggregate(TotNumberOfTips,by=list(Species=Species,Depth=Depth),mean)
foo$mean = fooo$x
rm(fooo)
names(foo)[3] = "std.err"
foo = split(foo, foo$Species)

plotCI(foo$Cornsoy$Depth,foo$Cornsoy$mean,foo$Cornsoy$std.err,col="goldenrod",ylim=c(0,4),xlab="Depth (cm)", ylab="No. root tips per frame")
plotCI(foo$Miscanthus$Depth,foo$Miscanthus$mean,foo$Miscanthus$std.err,col="Green",add=TRUE)
plotCI(foo$Switchgrass$Depth,foo$Switchgrass$mean,foo$Switchgrass$std.err,col="black",add=TRUE)
plotCI(foo$Prairie$Depth,foo$Prairie$mean,foo$Prairie$std.err,col="purple",add=TRUE)
points(foo$Cornsoy$Depth,foo$Cornsoy$mean, col="goldenrod",type="l")
points(foo$Miscanthus$Depth,foo$Miscanthus$mean, col="green",type="l")
points(foo$Prairie$Depth,foo$Prairie$mean, col="purple",type="l")
points(foo$Switchgrass$Depth,foo$Switchgrass$mean, col="black",type="l")
legend("topright", legend=c("Cornsoy", "Miscanthus", "Prairie", "Switchgrass"), fill=c("goldenrod","green","purple","black"))

nt = function(tubeno) { plot(s12010[Tube==tubeno, MeasTime])}


# show variation in calibrations. Switch to show ImgArea when computed.
plot(mirror.ticks(ggplot(raw.2010, aes(Date, PxSizeH))+geom_point()))

# a possible main results display.
# Show volumes in log space or orig scale?
# Does smoother add anything?
# Maybe show modeled effects instead of cell means?
(ggplot(logvol.2010, 
	aes(Depth, log.mean, color=Species))
	+geom_point()
	+facet_grid(Block~Session)
	+coord_flip()
	+scale_x_reverse()
	+stat_smooth(method="lm", formula=y~poly(x,2), se=FALSE)
	+ggtitle("2010") 
)


# unconverged model m2.2010 shows GIANT variance in random switchgrass:Block 
# effect. plot to investigate.
ggplot(noeasy.2010, aes(Block, Species))+geom_point()

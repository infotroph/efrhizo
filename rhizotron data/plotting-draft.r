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
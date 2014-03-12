par(mfrow=c(2,5))

plot(oaap$TotProj, oackb$TotProj,xlab="AP",ylab="CKB")
plot(oaap$TotProj, oawam$TotProj,xlab="AP",ylab="WAM")
plot(oaap$TotProj, oalf$TotProj,xlab="AP",ylab="LF")
plot(oaap$TotProj, oampd$TotProj,xlab="AP",ylab="MPD")
plot(oackb$TotProj, oawam$TotProj,xlab="CKB",ylab="WAM")
plot(oackb$TotProj,	oalf$TotProj,xlab="CKB",ylab="LF")
plot(oackb$TotProj, oampd$TotProj,xlab="CKB",ylab="MPD")
plot(oawam$TotProj, oalf$TotProj,xlab="WAM",ylab="LF")
plot(oawam$TotProj, oampd$TotProj,xlab="WAM",ylab="MPD")
plot(oalf$TotProj, oampd$TotProj,xlab="LF",ylab="MPD")


plot(oaap$TotVol, oackb$TotVol,xlab="AP",ylab="CKB")
plot(oaap$TotVol, oawam$TotVol,xlab="AP",ylab="WAM")
plot(oaap$TotVol, oalf$TotVol,xlab="AP",ylab="LF")
plot(oaap$TotVol, oampd$TotVol,xlab="AP",ylab="MPD")
plot(oackb$TotVol, oawam$TotVol,xlab="CKB",ylab="WAM")
plot(oackb$TotVol,	oalf$TotVol,xlab="CKB",ylab="LF")
plot(oackb$TotVol, oampd$TotVol,xlab="CKB",ylab="MPD")
plot(oawam$TotVol, oalf$TotVol,xlab="WAM",ylab="LF")
plot(oawam$TotVol, oampd$TotVol,xlab="WAM",ylab="MPD")
plot(oalf$TotVol, oampd$TotVol,xlab="LF",ylab="MPD")



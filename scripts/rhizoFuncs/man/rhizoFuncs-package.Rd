\name{rhizoFuncs}
\alias{rhizoFuncs-package}
\alias{rhizoFuncs}
\docType{package}
\title{
Minirhizotron data cleanup
}
\description{
Some functions I use together for sorting, finding duplicates, rearranging, and plotting the DeLucia lab's minirhizotron data. Created partly because I was tired of functions filling my .GlobalEnvironment , partly because I wanted to learn how to make an R package, and only a tiny bit because it was useful.
}
\details{
\tabular{ll}{
Package: \tab rhizoFuncs\cr
Type: \tab Package\cr
Version: \tab 0.1-0\cr
Date: \tab 2014-03-11\cr
License: \tab Unlimited\cr
}
~~ An overview of how to use the package, including the most important functions ~~
}
\author{
Chris Black

Maintainer: <chris@bodger.org>
}
\references{
~~ Literature or other references for background information ~~
}
\keyword{ package }
\seealso{
~~ Optional links to other man pages, e.g. ~~
~~ \code{\link[<pkg>:<pkg>-package]{<pkg>}} ~~
}
\examples{
\dontrun{
noeasy.2010.by = by(raw.2010, raw.2010$Img, strip.tracing.dups)
noeasy.2010 = do.call(rbind, noeasy.2010.by)
rm(noeasy.2010.by)

noeasy.2010$Block = assign.block(noeasy.2010$Tube)
noeasy.2010$Species = assign.species(noeasy.2010$Tube)
noeasy.2010$Depth = loc.to.depth(noeasy.2010$Location)
noeasy.2010$rootvol.mm3.mm2 = with(noeasy.2010, 
 	rootvol.perarea(TotVolume.mm3, PxSizeH, PxSizeV))
}
}

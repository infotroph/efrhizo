\name{normalize.soilvol}
\alias{normalize.soilvol}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Scale rhizotron root volume to soil volume
}
\description{
Convert root volume per image into root volume per volume soil.
 
 Assumes rhizotron camera can see 2 mm into soil for fine roots, but full diameter of larger roots. Approximated here by multiplying each diameter class by its bin size.

BUGBUG: These diameter classes are in mm/10, so "greater than 4.5" contains everything 0.45 mm and larger! To fix, set up more appropriate size classes and reload images.

In short: THIS FUNCTION IS EXPERIMENTAL AND ITS OUTPUT DOESN'T CORRESPOND TO ANY REAL QUANTITIES. DO NOT USE IT.
}
\usage{
normalize.soilvol(df)
}

\arguments{
 	\item{df}{
  		Dataframe derived from WinRhizo data. See function definition below to see required column names.
	}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
	Input dataframe with additional columns "rootvol<n>to<n>" corresponding to every "V<n>to<n>" input column, and "rootvol.mm3.mm3" giving frame totals (would be in range(0,1) if the function worked right)
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Chris Black <chris@bodger.org>
}
\note{
	Once again, FIX THIS before using it.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
## The function is currently defined as
normalize.soilvol <- function(df){
	within(df, {
		ImgArea.mm2 = (754 * PxSizeH) * (510 * PxSizeV)

		rootvol0to0.5 = V0to0.5 / ImgArea.mm2 * 2
		rootvol0.5to1 = V0.5to1 / ImgArea.mm2 * 2
		rootvol1to1.5 = V1to1.5 / ImgArea.mm2 * 2
		rootvol1.5to2 = V1.5to2 / ImgArea.mm2 * 2
		rootvol2to2.5 = V2to2.5 / ImgArea.mm2 * 2.5
		rootvol2.5to3 = V2.5to3 / ImgArea.mm2 * 3
		rootvol3to3.5 = V3to3.5 / ImgArea.mm2 * 3.5
		rootvol4.5to4 = V3.5to4 / ImgArea.mm2 * 4
		rootvol4to4.5 = V4to4.5 / ImgArea.mm2 * 4.5
		rootvolgreaterthan4.5 = Vgreaterthan4.5 / ImgArea.mm2 * 5

		rootvol.mm3.mm3 = (
			rootvol0to0.5 
			+ rootvol0.5to1 
			+ rootvol1to1.5 
			+ rootvol1.5to2 
			+ rootvol2to2.5 
			+ rootvol2.5to3 
			+ rootvol3to3.5 
			+ rootvol4.5to4 
			+ rootvol4to4.5 
			+ rootvolgreaterthan4.5)})
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line

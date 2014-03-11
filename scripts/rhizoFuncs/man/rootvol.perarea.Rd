\name{rootvol.perarea}
\alias{rootvol.perarea}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Scale rhizotron root volume by area of image
}
\description{
given total volumes and image pixel-scaling calibrations, return root volume per mm^2}
\usage{
rootvol.perarea(rootvol, pxH, pxV)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{rootvol}{
  numeric. Units should be mm^3 in the whole image
}
  \item{pxH}{
Numeric with length one. Units should be mm/px.
}
  \item{pxV}{
Numeric with length one. Units should be mm/px.
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
Numeric, in the nonsensical but calibration-corrected units of ``cubic millimeters of root per square millimeter of image.''
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Chris Black <chris@bdoger.org>
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (rootvol, pxH, pxV) 
{
    imgarea = (754 * pxH) * (510 * pxV)
    return(rootvol/imgarea)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line

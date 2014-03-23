\name{rootvol.perarea}
\alias{rootvol.perarea}
\title{
Scale rhizotron root volume by area of image
}
\description{
given total volumes and image pixel-scaling calibrations, return root volume per mm^2}
\usage{
rootvol.perarea(rootvol, pxH, pxV)
}
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
\value{
Numeric, in the nonsensical but calibration-corrected units of ``cubic millimeters of root per square millimeter of image.''
}
\author{
Chris Black <chris@bodger.org>
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

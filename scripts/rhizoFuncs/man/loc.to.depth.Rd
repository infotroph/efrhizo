\name{loc.to.depth}
\alias{loc.to.depth}
\title{
Convert location in tube to depth below surface
}
\description{
Convert Bartz camera location number (13.5 mm increments down an angled tube) to depth below soil surface.
}
\usage{
loc.to.depth(loc, offset=22, angle=30)
}
\arguments{
  \item{loc}{Location number, as read off the Bartz indexing handle}
  \item{offset}{Distance along the tube, in cm, from the top end of the tube to the soil surface. Default is 22 cm, which is the offset of a correctly installed tube with the center of location 1 at the soil surface.}
  \item{angle}{Tube installation angle, in degrees from vertical. Default is 30 degrees.}
}
\value{numeric, rounded to nearest whole cm below surface.}
\author{
Chris Black <chris@bodger.org>
}
\examples{
locs = seq(5, 50, 10)

loc.to.depth(locs) # returns c(5, 16, 28, 40, 51)
loc.to.depth(locs, offset=27) # returns c(0, 12, 24, 35, 47)
loc.to.depth(locs, offset=22, angle=45) # returns c(4, 13, 23, 32, 42)

}

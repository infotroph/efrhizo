\name{assign.species}
\alias{assign.species}
\title{
Assign species to tubes
}
\description{
Given a [vector of] tube number[s] from the EBI Energy Farm minirhizotron experiment, return a factor identifying the crop grown in that plot.
}
\usage{
assign.species(tube)
}
\arguments{
  \item{tube}{numeric, hopefully integers in the range 1-96. A factor with numeric levelnames is also acceptable and will be coerced to numeric via as.numeric(as.character(tube)).}
}
\value{
Factor with levels "Cornsoy", "Miscanthus", "Switchgrass", "Prairie".
}
\author{
Chris Black <chris@bodger.org>
}
\seealso{
\code{\link{assign.block}} for the experimental replicate (0-4) of a tube.
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (tube) 
{
	if(is.factor(tube)){
			tube=as.numeric(as.character(tube))
	}
    cut(tube, breaks = c(0, 24, 48, 72, 96), labels = c("Cornsoy", 
        "Miscanthus", "Switchgrass", "Prairie"))
  }
}

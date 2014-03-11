\name{assign.species}
\alias{assign.species}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Assign species to tubes
}
\description{
Given a [vector of] tube number[s] from the EBI Energy Farm minirhizotron experiment, return a factor identifying the crop grown in that plot.
}
\usage{
assign.species(tube)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{tube}{
%%     ~~Describe \code{tube} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
Factor with levels "Cornsoy", "Miscanthus", "Switchgrass", "Prairie".
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
function (tube) 
{
    cut(tube, breaks = c(0, 24, 48, 72, 96), labels = c("Cornsoy", 
        "Miscanthus", "Switchgrass", "Prairie"))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line

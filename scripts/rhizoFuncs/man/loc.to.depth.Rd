\name{loc.to.depth}
\alias{loc.to.depth}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Convert location in tube to depth below surface
}
\description{
Convert Bartz camera location number (13.5 mm increments down an angled tube) to depth below soil surface (Assuming the tube is installed at the depth you think... correct that elsewhere!)
}
\usage{
loc.to.depth(loc)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{loc}{
%%     ~~Describe \code{loc} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
numeric, in units of cm below surface
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
function (loc) 
{
    round((loc * 1.35) * cos((pi/180) * 30))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line

\name{assign.block}
\alias{assign.block}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Assign blocks to tubes
}
\description{
Given a [vector of] tube number[s] from the EBI Energy Farm minirhizotron experiment, return a [vector of] block number[s].
}
\usage{
assign.block(tube)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{tube}{
a numeric vector, hopefully with all values in the range (1,96)
%%     ~~Describe \code{tube} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
Factor with levels %in% c(0,1,2,3,4).
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
\code{\link{assign.species}}
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (tube) 
{
    b = rep(NA, length(tube))
    b[tube \%in\% c(1:8, 25:32, 49:56, 73:80)] = 0
    b[tube \%in\% c(9:12, 33:36, 57:60, 81:84)] = 1
    b[tube \%in\% c(13:16, 37:40, 61:64, 85:88)] = 2
    b[tube \%in\% c(17:20, 41:44, 65:68, 89:92)] = 3
    b[tube \%in\% c(21:24, 45:48, 69:72, 93:96)] = 4
    return(factor(b))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line

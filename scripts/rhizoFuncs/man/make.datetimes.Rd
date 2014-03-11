\name{make.datetimes}
\alias{make.datetimes}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Mash WinRhizo dates and times together into a POSIXct datetime
}
\description{
Given a dataframe with a Date ("2014.07.01") and a Time ("121505") in WinRhizo's weird formats, paste them together into a POSIXct timestamp.
}
\usage{
make.datetimes(df)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{df}{
%%     ~~Describe \code{df} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
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
function (df) 
{
    within(df, {
        Time = as.character(Time)
        Time = ifelse(nchar(Time) < 6, paste0(0, Time), Time)
        DateTime = as.POSIXct(paste(Date, Time), format = "\%Y.\%m.\%d \%H\%M\%S")
        Date = as.Date(Date, format = "\%Y.\%m.\%d")
        MeasDateTime = as.POSIXct(paste(MeasDate, MeasTime), 
            format = "\%m/\%d/\%Y \%H:\%M:\%S")
        MeasDate = as.Date(MeasDate, format = "\%m/\%d/\%Y")
    })
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line

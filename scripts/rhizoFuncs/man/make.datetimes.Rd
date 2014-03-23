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
  \item{df}{A dataframe produced from a WinRhizo datafile.}
}
\details{
	The current implementation performs the following conversions: 
	
	Coerces column "Time"" to character, then pads times <10:00 so that \code{strptime} has a consistent string length to work from.
	
	Coerces columns "Date" and "MeasDate"" to type \code{Date} .
	
	Creates new columns "DateTime" and "MeasDateTime" of type \code{POSIXct}.
	
	Column "MeasTime"" is neither coerced to a time object nor checked for correct formatting -- this should probably be changed eventually.
}
\value{
Dataframe, changed from the input dataframe in the following ways:
	\item{Time}{Converted to character and leading zeroes added where previously missing.}
	\item{Date, MeasDate}{Converted to POSIXct.}
	\item{DateTime, MeasDateTime}{New columns, POSIXct.}
}
\author{
Chris Black \email{chris@bodger.org}
}
\note{
This function only works on freshly read dataframes. It will fail if called on an object of its own creation, because Date and MeasDate formats have changed!	
}
\seealso{
\code{\link{DateTimeClasses}}
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

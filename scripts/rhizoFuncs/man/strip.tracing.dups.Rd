\name{strip.tracing.dups}
\alias{strip.tracing.dups}
\title{
Strip duplicated records for the same images from WinRhizo data
}
\description{
Given a dataframe containing WinRhizo-formatted frame totals, return the dataframe with only the most recent line of data. Optionally, warn if it's not clear that's the correct line to use.
}
\usage{
strip.tracing.dups(x, warn = TRUE)
}
\arguments{
  \item{x}{
  data frame derived from a WinRhizo Tron datafile, or at least containing columns names "MeasDateTime", "PxSizeH", "PxSizeV", and "TotVolume.mm3".
}
  \item{warn}{
  Boolean: should strip.tracing.dups print warnings if the most recent frame may not be the one to keep? See details.
}
}
\details{
	this function takes rhizotron data for a single image and returns the most recent tracing, with a warning if it's unclear that's the correct tracing to keep. The warning is optional, but I recommend it: If warn=FALSE, this function is exactly equivalent to an expensive df[!duplicated(df$Img,fromLast=TRUE),]. You probably want the warnings.
}
\value{
Data frame with the same columns as x and length(unique(x$Img)) rows.
}
\author{
Chris Black <chris@bodger.org>
}
\note{
No, seriously, don't use warn=FALSE.
}
\examples{
\dontrun{
notracedups.2010 = by(raw.rhizo.2010, raw.thizo.2010$Tube, strip.tracing.dups)
notracedups.2010 = do.call(rbind, notracedups.2010)
}

##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (x, warn = TRUE) 
{
    stopifnot(!is.unsorted(x$MeasDateTime))
    if (nrow(x) <= 1) {
        return(x)
    }
    if (length(unique(x$PxSizeH)) > 1 || length(unique(x$PxSizeV)) > 
        1) {
        if (warn) {
            print(paste(x$Img[1], ": multiple cals. PxSizeH: ", 
                paste(x$PxSizeH, collapse = ", "), ", PxSizeV: ", 
                paste(x$PxSizeV, collapse = ", ")))
        }
    }
    xv = x$TotVolume.mm3
    if (length(unique(xv)) == 1 || (all(xv[xv > 0] == xv[length(xv)]) && 
        all(xv == sort(xv)))) {
        return(x[nrow(x), ])
    }
    if (warn) {
        print(paste(x$Img[1], ": multiple values: ", paste(xv, 
            collapse = ", ")))
    }
    return(x[nrow(x), ])
  }
}

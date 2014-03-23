\name{lognormboot}
\alias{lognormboot}
\title{
lognormal bootstrap confidence intervals
}
\description{
Given the log-mean and log-sd of lognormally distributed data, compute parametric bootstrap confidence intervals.
}
\usage{
lognormboot(nboot = 1000, nsim = 4, ybar = 0, s2 = 1, quantiles = c(0.025, 0.975), na.rm = na.rm)
}

\arguments{
  \item{nboot}{
Integer: number of bootstrap simulations to run.
}
  \item{nsim}{
Integer: number of datapoints to simulate (i.e. your sample size).
}
  \item{ybar}{
Numeric: Sample mean.
}
  \item{s2}{
numeric: Sample standard deviation.
}
  \item{quantiles}{
Numeric with length 2: Lower and upper quantiles to compute. Defaults to c(0.025, 0.975) for a 95% CI.
}
  \item{na.rm}{
Method of dealing with missing values. Not currently used; may be removed in a future version. }
}
\details{
The algorithm is from http://www.amstat.org/publications/jse/v13n1/olsson.html, but neither that site nor the package author promises it's correct.
}
\value{
Numeric vector of length 2, corresponding respectively to the lower and upper requested quantiles
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Chris Black <chris@bodger.org>
}

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (nboot = 1000, nsim = 4, ybar = 0, s2 = 1, quantiles = c(0.025, 
    0.975), na.rm = na.rm) 
{
    if (is.na(ybar) || is.na(s2)) {
        return(c(NA, NA))
    }
    t2 = rep(NA, nboot)
    for (i in 1:nboot) {
        z = rnorm(1)
        u2 = rchisq(1, df = nsim - 1)
        t2[i] = (ybar - (z/(sqrt(u2)/sqrt(nsim - 1))) * sqrt(s2)/sqrt(nsim) + 
            1/2 * s2/(u2/(nsim - 1)))
    }
    return(exp(quantile(t2, probs = quantiles)))
  }
}

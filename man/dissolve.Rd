% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cl-handling.R
\name{dissolve}
\alias{dissolve}
\title{Dissolves Coe objects}
\usage{
dissolve(x, retain)
}
\arguments{
\item{x}{a Coe object}

\item{retain}{the partition id to retain. Or their name if the partitions are named
(see x$method) eg after a chop}
}
\description{
the opposite of combine, typically used after it. Note that the \code{$fac} slot may be wrong since
combine...well combines... this \code{$fac}. See examples.
}
\examples{
data(bot)
w <- filter(bot, type=="whisky")
b <- filter(bot, type=="beer")
wf <- efourier(w, 10)
bf <- efourier(b, 10)
wbf <- combine(wf, bf)
dissolve(wbf, 1)
dissolve(wbf, 2)
}
\seealso{
Other handling functions: \code{\link{arrange}},
  \code{\link{at_least}}, \code{\link{chop}},
  \code{\link{combine}}, \code{\link{filter}},
  \code{\link{mutate}}, \code{\link{rename}},
  \code{\link{rm_uncomplete}}, \code{\link{rw_rule}},
  \code{\link{sample_frac}}, \code{\link{sample_n}},
  \code{\link{select}}, \code{\link{slice}},
  \code{\link{subset.Coo}}, \code{\link{transmute}}
}


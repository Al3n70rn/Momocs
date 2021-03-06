% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core-out-efourier.R
\name{efourier_i}
\alias{efourier_i}
\title{Inverse elliptical Fourier transform}
\usage{
efourier_i(ef, nb.h, nb.pts = 120)
}
\arguments{
\item{ef}{\code{list}. A list containing \eqn{a_n}, \eqn{b_n}, \eqn{c_n} and
\eqn{d_n} Fourier coefficients, such as returned by \code{efourier}.}

\item{nb.h}{\code{integer}. The number of harmonics to use. If not
specified, \code{length(ef$an)} is used.}

\item{nb.pts}{\code{integer}. The number of points to calculate.}
}
\value{
A matrix of (x; y) coordinates.
}
\description{
\code{efourier_i} uses the inverse elliptical Fourier transformation to
calculate a shape, when given a list with Fourier coefficients, typically
obtained computed with \link{efourier}.
}
\details{
See \link{efourier} for the mathematical background.
}
\note{
Directly borrowed for Claude (2008), and also called \code{iefourier} there.
}
\examples{
data(bot)
coo <- bot[1]
coo_plot(coo)
ef  <- efourier(coo, 12)
ef
efi <- efourier_i(ef)
coo_draw(efi, border='red', col=NA)
}
\references{
Claude, J. (2008) \emph{Morphometrics with R}, Use R! series,
Springer 316 pp.
Ferson S, Rohlf FJ, Koehn RK. 1985. Measuring shape variation of
two-dimensional outlines. \emph{Systematic Biology} \bold{34}: 59-68.
}
\seealso{
Other efourier: \code{\link{efourier_norm}},
  \code{\link{efourier_shape}}, \code{\link{efourier}}
}


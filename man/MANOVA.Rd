% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mult-Manova.R
\name{MANOVA}
\alias{MANOVA}
\alias{MANOVA.OpnCoe}
\alias{MANOVA.OutCoe}
\alias{MANOVA.PCA}
\title{Multivariate analysis of variance on Coe objects}
\usage{
MANOVA(x, fac, test = "Hotelling", retain, drop, verbose)

\method{MANOVA}{OpnCoe}(x, fac, test = "Hotelling", retain, drop,
  verbose = TRUE)

\method{MANOVA}{OutCoe}(x, fac, test = "Hotelling", retain, drop,
  verbose = TRUE)

\method{MANOVA}{PCA}(x, fac, test = "Hotelling", retain = 0.99, drop,
  verbose = TRUE)
}
\arguments{
\item{x}{a \link{Coe} object}

\item{fac}{a name of a colum in the \code{$fac} slot, or its id, or a formula}

\item{test}{a test for \link{manova} (\code{'Hotelling'} by default)}

\item{retain}{how many harmonics (or polynomials) to retain, for PCA
the highest number of PC axis to retain, or the proportion of the variance to capture.}

\item{drop}{how many harmonics (or polynomials) to drop}

\item{verbose}{logical whether to print messages}
}
\value{
a list of matrices of (x,y) coordinates.
}
\description{
Performs multivariate analysis of variance on \link{PCA} objects.
}
\details{
Performs a MANOVA on PC scores. Just a wrapper around \link{manova}. See examples for multifactorial manova and
\link{summary.manova} for more details and examples.
}
\note{
Needs a review and should be considered as experimental.
}
\examples{
data(bot)
bot.p <- PCA(efourier(bot, 12))
MANOVA(bot.p, 'type')

data(olea)
op <- PCA(npoly(olea, 5))
MANOVA(op, 'domes')

 m <- manova(op$x[, 1:5] ~  op$fac$domes * op$fac$var)
 summary(m)
 summary.aov(m)
}
\seealso{
Other multivariate: \code{\link{CLUST}},
  \code{\link{KMEANS}}, \code{\link{LDA}},
  \code{\link{MANOVA_PW}}, \code{\link{PCA}}
}


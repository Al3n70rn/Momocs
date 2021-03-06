% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mult-PCA.R
\name{which_out}
\alias{which_out}
\title{Remove outliers on Coe}
\usage{
which_out(x, conf, nax, ...)
}
\arguments{
\item{x}{object, either Coe or a numeric on which to search for outliers}

\item{conf}{confidence for dnorm}

\item{nax}{number of axes to retain (only for Coe),
if <1 retain enough axes to retain this proportion of the variance}

\item{...}{additional parameters to be passed to PCA (only for Coe)}
}
\description{
First performs a PCA, then searches for outliers using \link{dnorm}
}
\note{
experimental. dnorm parameters used are \code{median(x), sd(x)}
}
\examples{
x <- rnorm(10)
x[4] <- 99
which_out(x)
}


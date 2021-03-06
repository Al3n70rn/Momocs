% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/babel-import.R
\name{import_Conte}
\alias{import_Conte}
\title{Extracts outlines coordinates from an image silhouette}
\usage{
import_Conte(img, x)
}
\arguments{
\item{img}{a matrix of a binary image mask.}

\item{x}{numeric the (x; y) coordinates of a starting point within the shape.}
}
\value{
a matrix the (x; y) coordinates of the outline points.
}
\description{
Provided with an image 'mask' (i.e. black pixels on a white background),
and a point form where to start the algorithm, returns the (x; y) coordinates of its outline.
}
\details{
Used internally by \link{import_jpg1} but may be useful for other purposes.
}
\references{
\itemize{
\item The original algorithm is due to: Pavlidis, T. (1982). \emph{Algorithms
for graphics and image processing}. Computer science press.
\item is detailed in: Rohlf, F. J. (1990). An overview of image processing and
analysis techniques for morphometrics. In \emph{Proceedings of the Michigan Morphometrics Workshop}. Special Publication No. 2 (pp. 47-60). University of Michigan Museum of Zoology: Ann Arbor.
\item and translated in R by: Claude, J. (2008). \emph{Morphometrics with R}. (p. 316). Springer.
}
}
\seealso{
babel functions.
}


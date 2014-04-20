\name{l2a}
\alias{l2a}
\title{Converts a list of coordinates to an array.}
\usage{
l2a(l)
}
\arguments{
  \item{l}{A \code{list} of matrices of the same
  dimension.}
}
\value{
An array of coordinates.
}
\description{
\code{l2a} converts a list of \code{k} matrices with n-rows
and n-col matrices to a \code{m x n x k} array.
}
\examples{
\dontrun{
data(gorf.dat)
l <- a2l(gorf.dat)
a <- l2a(l)
A.plot(a)
	}
}
\seealso{
\link{a2l}.
}
\keyword{Utilities}
\keyword{coo}

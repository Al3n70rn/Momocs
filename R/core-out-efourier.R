##### Core function for elliptical Fourier analyses

#' Elliptical Fourier transform
#'
#' \code{efourier} computes Elliptical Fourier Analysis (or Transforms or EFT)
#' from a matrix (or a list) of (x; y) coordinates.
#'
#' @param x A \code{list} or a \code{matrix} of coordinates or a \code{Out} object
#' @param nb.h \code{integer}. The number of harmonics to use. If missing 99pc harmonic power is used.
#' @param smooth.it \code{integer}. The number of smoothing iterations to
#' perform.
#' @param verbose \code{logical}. Whether to print or not diagnosis messages.
#' @param norm whether to normalize the coefficients using \link{efourier_norm}
#' @param start logical whether to consider the first point as homologous
#' @param ... useless here
#' @return A list with these components: \item{an }{\code{vector} of
#' \eqn{a_{1->n}} harmonic coefficients.} \item{bn }{\code{vector} of
#' \eqn{b_{1->n}} harmonic coefficients.} \item{cn }{\code{vector} of
#' \eqn{c_{1->n}} harmonic coefficients.} \item{dn }{\code{vector} of
#' \eqn{d_{1->n}} harmonic coefficients.} \item{ao }{\code{ao} Harmonic
#' coefficient.} \item{co }{\code{co} Harmonic coefficient.}
#' @note Directly borrowed for Claude (2008), and also called \code{efourier} there.
#' @details For the maths behind see the paper in JSS.
#'
#' Normalization of coefficients has long been a matter of trouble,
#' and not only for newcomers. There are two ways of normalizing outlines: the first,
#' and by far the msot used, is to use a "numerical" alignment, directly on the
#' matrix of coefficients. The coefficients of the first harmonic are consumed
#' by this process but harmonics of higher rank are normalized in terms of size
#' and rotation. This is sometimes referred as using the "first ellipse", as the
#' harmonics define an ellipse in the plane, and the first one is the mother of all
#' ellipses, on which all others "roll" along. This approach is really convenient
#' as it is done easily by most software (if not the only option) and by Momocs too.
#' It is the default option of \code{efourier}.
#'
#' But here is the pitfall: if your shapes are prone to bad aligments among all
#' the first ellipses, this will result in poorly (or even not at all) "homologous" coefficients.
#' The shapes prone to this are either (at least roughly) circular and/or with a strong
#' bilateral symmetry. You can try to use \code{\link{stack}} on the \code{\link{Coe}} object
#'  returned by \code{efourier}. Also, when plotting PCA using Momocs,
#' this will be strikingly clear though. This phenomenon will result in two clusters,
#' and more strikingly into upside-down (or 180 degrees rotated)
#' shapes on the morphospace. If this happen, you should seriously consider
#' aligning your shapes \emph{before} the \code{efourier} step,
#' and performing the latter with no normalization (\code{norm = FALSE}), since
#' it has been done before.
#'
#' You have several options to align your shapes, using control points (or landmarks),
#' of Procrustes alignment (see \code{\link{fgProcrustes}}) through their calliper
#' length (see \code{\link{coo_aligncalliper}}), etc. You should also make the first
#' point homologous either with \code{\link{coo_slide}} or \code{\link{coo_slidedirection}}
#' to minimize any subsequent problems.
#'
#' I will dedicate (some day) a vignette or a paper to this problem.
#' @family efourier
#' @references Claude, J. (2008) \emph{Morphometrics with R}, Use R! series,
#' Springer 316 pp.
#' Ferson S, Rohlf FJ, Koehn RK. 1985. Measuring shape variation of
#' two-dimensional outlines. \emph{Systematic Biology} \bold{34}: 59-68.
#' @examples
#' data(bot)
#' coo <- bot[1]
#' coo_plot(coo)
#' ef <- efourier(coo, 12)
#' ef
#' efi <- efourier_i(ef)
#' coo_draw(efi, border='red', col=NA)
#' @rdname efourier
#' @export
efourier <- function(x, ...){UseMethod("efourier")}
eFourier <- efourier

#' @rdname efourier
#' @export
efourier.default <- function(x, nb.h, smooth.it = 0, verbose = TRUE, ...) {
    coo <- x
    coo <- coo_check(coo)
    if (is_closed(coo))
        coo <- coo_unclose(coo)
    nr <- nrow(coo)
    if (missing(nb.h)) {
        nb.h <- 32
        message("'nb.h' not provided and set to ", nb.h)
    }
    if (nb.h * 2 > nr) {
        nb.h = floor(nr/2)
        if (verbose) {
            message("'nb.h' must be lower than half the number of points, and has been set to ", nb.h, "harmonics")
        }
    }
    if (nb.h == -1) {
        nb.h = floor(nr/2)
        if (verbose) {
            message("The number of harmonics used has been set to: ", nb.h)
        }
    }
    if (smooth.it != 0) {
        coo <- coo_smooth(coo, smooth.it)
    }
    Dx <- coo[, 1] - coo[, 1][c(nr, (1:(nr - 1)))]  # there was a bug there. check from claude? #todo
    Dy <- coo[, 2] - coo[, 2][c(nr, (1:(nr - 1)))]
    Dt <- sqrt(Dx^2 + Dy^2)
    Dt[Dt < 1e-10] <- 1e-10  # to avoid Nan
    t1 <- cumsum(Dt)
    t1m1 <- c(0, t1[-nr])
    T <- sum(Dt)
    an <- bn <- cn <- dn <- numeric(nb.h)
    for (i in 1:nb.h) {
        Ti <- (T/(2 * pi^2 * i^2))
        r <- 2 * i * pi
        an[i] <- Ti * sum((Dx/Dt) * (cos(r * t1/T) - cos(r * t1m1/T)))
        bn[i] <- Ti * sum((Dx/Dt) * (sin(r * t1/T) - sin(r * t1m1/T)))
        cn[i] <- Ti * sum((Dy/Dt) * (cos(r * t1/T) - cos(r * t1m1/T)))
        dn[i] <- Ti * sum((Dy/Dt) * (sin(r * t1/T) - sin(r * t1m1/T)))
    }
    ao <- 2 * sum(coo[, 1] * Dt/T)
    co <- 2 * sum(coo[, 2] * Dt/T)
    return(list(an = an, bn = bn, cn = cn, dn = dn, ao = ao,
        co = co))
}

#' @rdname efourier
#' @export
efourier.Out <- function(x, nb.h, smooth.it = 0, norm = TRUE, start = FALSE, verbose=TRUE, ...) {
  Out <- x
  # validates
  Out %<>% validate()
  q <- floor(min(sapply(Out$coo, nrow)/2))
  if (missing(nb.h)) {
    #nb.h <- ifelse(q >= 32, 32, q)
    nb.h <- calibrate_harmonicpower(Out, thresh = 99, verbose=FALSE, plot=FALSE)$minh
    if (verbose) message("'nb.h' not provided and set to ", nb.h, " (99% harmonic power)")
  }
  if (nb.h > q) {
    nb.h <- q  # should not be 1 #todo
    message("at least one outline has no more than ", q * 2,
        " coordinates. 'nb.h' has been set to ", q, " harmonics")
  }
  coo <- Out$coo
  col.n <- paste0(rep(LETTERS[1:4], each = nb.h), rep(1:nb.h,
                                                      times = 4))
  coe <- matrix(ncol = 4 * nb.h, nrow = length(coo), dimnames = list(names(coo),
                                                                     col.n))
  for (i in seq(along = coo)) {
    # todo: vectorize ?
    ef <- efourier(coo[[i]], nb.h = nb.h, smooth.it = smooth.it,
                   verbose = TRUE)
    if (norm) {
      ef <- efourier_norm(ef, start = start)
      if (ef$A[1] < 0) {
        ef$A <- (-ef$A)
        ef$B <- (-ef$B)
        ef$C <- (-ef$C)
        ef$D <- (-ef$D)
        ef$lnef <- (-ef$lnef)
      }
      coe[i, ] <- c(ef$A, ef$B, ef$C, ef$D)
    } else {
      coe[i, ] <- c(ef$an, ef$bn, ef$cn, ef$dn)
    }
  }
  coe[abs(coe) < 1e-12] <- 0  #not elegant but round normalized values to 0
  res <- OutCoe(coe = coe, fac = Out$fac, method = "efourier", norm = norm)
  res$cuts <- ncol(res$coe)
  return(res)
}

#' Inverse elliptical Fourier transform
#'
#' \code{efourier_i} uses the inverse elliptical Fourier transformation to
#' calculate a shape, when given a list with Fourier coefficients, typically
#' obtained computed with \link{efourier}.
#'
#' See \link{efourier} for the mathematical background.
#'
#' @param ef \code{list}. A list containing \eqn{a_n}, \eqn{b_n}, \eqn{c_n} and
#' \eqn{d_n} Fourier coefficients, such as returned by \code{efourier}.
#' @param nb.h \code{integer}. The number of harmonics to use. If not
#' specified, \code{length(ef$an)} is used.
#' @param nb.pts \code{integer}. The number of points to calculate.
#' @return A matrix of (x; y) coordinates.
#' @note Directly borrowed for Claude (2008), and also called \code{iefourier} there.
#' @references Claude, J. (2008) \emph{Morphometrics with R}, Use R! series,
#' Springer 316 pp.
#' Ferson S, Rohlf FJ, Koehn RK. 1985. Measuring shape variation of
#' two-dimensional outlines. \emph{Systematic Biology} \bold{34}: 59-68.
#' @family efourier
#' @examples
#' data(bot)
#' coo <- bot[1]
#' coo_plot(coo)
#' ef  <- efourier(coo, 12)
#' ef
#' efi <- efourier_i(ef)
#' coo_draw(efi, border='red', col=NA)
#' @export
efourier_i <- function(ef, nb.h, nb.pts = 120) {
    # if (any(names(ef) != c('an', 'bn', 'cn', 'dn'))) { stop('a
    # list containing 'an', 'bn', 'cn' and 'dn' harmonic
    # coefficients must be provided')}
    if (is.null(ef$ao))
        ef$ao <- 0
    if (is.null(ef$co))
        ef$co <- 0
    an <- ef$an
    bn <- ef$bn
    cn <- ef$cn
    dn <- ef$dn
    ao <- ef$ao
    co <- ef$co
    if (missing(nb.h)) {
        nb.h <- length(an)
    }
    theta <- seq(0, 2 * pi, length = nb.pts + 1)[-(nb.pts + 1)]
    hx <- matrix(NA, nb.h, nb.pts)
    hy <- matrix(NA, nb.h, nb.pts)
    for (i in 1:nb.h) {
        hx[i, ] <- an[i] * cos(i * theta) + bn[i] * sin(i * theta)
        hy[i, ] <- cn[i] * cos(i * theta) + dn[i] * sin(i * theta)
    }
    x <- (ao/2) + apply(hx, 2, sum)
    y <- (co/2) + apply(hy, 2, sum)
    coo <- cbind(x, y)
    colnames(coo) <- c("x", "y")
    return(coo)
}

#' Normalizes harmonic coefficients.
#'
#' \code{efourier_norm} normalizes Fourier coefficients for rotation,
#' tranlation, size and orientation of the first ellipse.
#'
#' See \link{efourier} for the mathematical background of the normalization.
#'
#' Sometimes shapes do not 'align' well each others, and this is usually detectable
#' on a morphospace on a regular PCA. You mat find 180 degrees rotated shapes or bizarre clustering.
#' Most of the time this is due to a poor normalization on the matrix of coefficients, and the
#' variability you observe may mostly be due to the variability in the alignment of the
#' 'first' ellipsis which is defined by the first harmonic, used for the normalization. In that
#' case, you should align shapes \emph{before} \link{efourier} and with \code{norm = FALSE}. You
#' have several options: \link{coo_align}, \link{coo_aligncalliper}, \link{fgProcrustes} either directly on
#' the coordinates or on some landmarks along the outline or elsewhere on your original shape, depending of
#' what shall provide a good alignment. Have a look to Momocs' vignette for some illustration of these pitfalls
#' and how to manage them.
#'
#' @param ef \code{list}. A list containing \eqn{a_n}, \eqn{b_n}, \eqn{c_n} and
#' \eqn{d_n} Fourier coefficients, such as returned by \code{efourier}.
#' @param start \code{logical}. Whether to conserve the position of the first
#' point of the outline.
#' @return A list with the following components:
#' \itemize{
#'  \item \code{A} vector of \eqn{A_{1->n}} \emph{normalized} harmonic coefficients
#'  \item \code{B} vector of \eqn{B_{1->n}} \emph{normalized} harmonic coefficients
#'  \item \code{C} vector of \eqn{C_{1->n}} \emph{normalized} harmonic coefficients
#'  \item \code{D} vector of \eqn{D_{1->n}} \emph{normalized} harmonic coefficients
#'  \item \code{size} Magnitude of the semi-major axis of the first
#' fitting ellipse
#' \item \code{theta} angle, in radians, between the starting
#' point and the semi-major axis of the first fitting ellipse
#' \item psi orientation of the first fitting ellipse
#' \item \code{ao} ao harmonic coefficient
#' \item \code{co} co Harmonic coefficient
#' \item \code{lnef} a list with A, B, C and D concatenated in a vector.
#' }
#' @family efourier
#' @references Claude, J. (2008) \emph{Morphometrics with R}, Use R! series,
#' Springer 316 pp.
#'
#' Ferson S, Rohlf FJ, Koehn RK. 1985. Measuring shape variation of
#' two-dimensional outlines. \emph{Systematic Biology} \bold{34}: 59-68.
#' @examples
#' data(bot)
#' q <- efourier(bot[1], 24)
#' efourier_i(q) # equivalent to efourier_shape(q$an, q$bn, q$cn, q$dn)
#' efourier_norm(q)
#' efourier_shape(nb.h=5, alpha=1.2)
#' efourier_shape(nb.h=12, alpha=0.9)
#' @export
efourier_norm <- function(ef, start = FALSE) {
    A1 <- ef$an[1]
    B1 <- ef$bn[1]
    C1 <- ef$cn[1]
    D1 <- ef$dn[1]
    nb.h <- length(ef$an)
    theta <- 0.5 * atan(2 * (A1 * B1 + C1 * D1)/(A1^2 + C1^2 -
        B1^2 - D1^2))%%pi
    phaseshift <- matrix(c(cos(theta), sin(theta), -sin(theta),
        cos(theta)), 2, 2)
    M2 <- matrix(c(A1, C1, B1, D1), 2, 2) %*% phaseshift
    v <- apply(M2^2, 2, sum)
    if (v[1] < v[2]) {
        theta <- theta + pi/2
    }
    theta <- (theta + pi/2)%%pi - pi/2
    Aa <- A1 * cos(theta) + B1 * sin(theta)
    Cc <- C1 * cos(theta) + D1 * sin(theta)
    scale <- sqrt(Aa^2 + Cc^2)
    psi <- atan(Cc/Aa)%%pi
    if (Aa < 0) {
        psi <- psi + pi
    }
    size <- 1/scale
    rotation <- matrix(c(cos(psi), -sin(psi), sin(psi), cos(psi)),
        2, 2)
    A <- B <- C <- D <- numeric(nb.h)
    if (start) {
        theta <- 0
    }
    for (i in 1:nb.h) {
        mat <- size * rotation %*%
          matrix(c(ef$an[i], ef$cn[i],
                   ef$bn[i], ef$dn[i]), 2, 2) %*%
          matrix(c(cos(i * theta), sin(i * theta),
                   -sin(i * theta), cos(i * theta)), 2, 2)
        A[i] <- mat[1, 1]
        B[i] <- mat[1, 2]
        C[i] <- mat[2, 1]
        D[i] <- mat[2, 2]
        lnef <- c(A[i], B[i], C[i], D[i])
    }
    list(A = A, B = B, C = C, D = D, size = scale, theta = theta,
        psi = psi, ao = ef$ao, co = ef$co, lnef = lnef)
}

#' Calculates and draw 'efourier' shapes.
#'
#' \code{efourier_shape} calculates a 'Fourier elliptical shape' given Fourier
#' coefficients (see \code{Details}) or can generate some 'efourier' shapes.
#' Mainly intended to generate shapes and/or to understand how efourier works.
#'
#' \code{efourier_shape} can be used by specifying \code{nb.h} and
#' \code{alpha}. The coefficients are then sampled in an uniform distribution
#' \eqn{(-\pi ; \pi)} and this amplitude is then divided by
#' \eqn{harmonicrank^alpha}. If \code{alpha} is lower than 1, consecutive
#' coefficients will thus increase. See \link{efourier} for the mathematical
#' background.
#'
#' @param an \code{numeric}. The \eqn{a_n} Fourier coefficients on which to
#' calculate a shape.
#' @param bn \code{numeric}. The \eqn{b_n} Fourier coefficients on which to
#' calculate a shape.
#' @param cn \code{numeric}. The \eqn{c_n} Fourier coefficients on which to
#' calculate a shape.
#' @param dn \code{numeric}. The \eqn{d_n} Fourier coefficients on which to
#' calculate a shape.
#' @param nb.h \code{integer}. The number of harmonics to use.
#' @param nb.pts \code{integer}. The number of points to calculate.
#' @param alpha \code{numeric}. The power coefficient associated with the
#' (usually decreasing) amplitude of the Fourier coefficients (see
#' \bold{Details}).
#' @param plot \code{logical}. Whether to plot or not the shape.
#' @return A list with components:
#' \itemize{
#'  \item \code{x} \code{vector} of x-coordinates
#'  \item \code{y} \code{vector} of y-coordinates.
#'  }
#' @family efourier
#' @references Claude, J. (2008) \emph{Morphometrics with R}, Use R! series,
#' Springer 316 pp.
#'
#' Ferson S, Rohlf FJ, Koehn RK. 1985. Measuring shape variation of
#' two-dimensional outlines. \emph{Systematic Biology} \bold{34}: 59-68.
#' @examples
#'
#' data(bot)
#' ef <- efourier(bot[1], 24)
#' efourier_shape(ef$an, ef$bn, ef$cn, ef$dn) # equivalent to efourier_i(ef)
#' efourier_shape() # is autonomous
#'
#' panel(Out(a2l(replicate(100,
#' efourier_shape(nb.h=6, alpha=2.5, plot=FALSE))))) # Bubble family
#' @export
efourier_shape <- function(an, bn, cn, dn, nb.h, nb.pts = 60,
    alpha = 2, plot = TRUE) {
    if (missing(nb.h) & missing(an))
        nb.h <- 3
    if (missing(nb.h) & !missing(an))
        nb.h <- length(an)
    if (missing(an))
        an <- runif(nb.h, -pi, pi)/(1:nb.h)^alpha
    if (missing(bn))
        bn <- runif(nb.h, -pi, pi)/(1:nb.h)^alpha
    if (missing(cn))
        cn <- runif(nb.h, -pi, pi)/(1:nb.h)^alpha
    if (missing(dn))
        dn <- runif(nb.h, -pi, pi)/(1:nb.h)^alpha
    ef <- list(an = an, bn = bn, cn = cn, dn = dn, ao = 0, co = 0)
    shp <- efourier_i(ef, nb.h = nb.h, nb.pts = nb.pts)
    if (plot)
        coo_plot(shp)
    return(shp)
}

##### end efourier

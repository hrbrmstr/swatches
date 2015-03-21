cmyk <- function(C, M, Y, K) {

  C <- C / 100.0
  M <- M / 100.0
  Y <- Y / 100.0
  K <- K / 100.0

  n.c <- (C * (1-K) + K)
  n.m <- (M * (1-K) + K)
  n.y <- (Y * (1-K) + K)

  r.col <- ceiling(255 * (1-n.c))
  g.col <- ceiling(255 * (1-n.m))
  b.col <- ceiling(255 * (1-n.y))

  return(sprintf("#%02s%02s%02s", as.hexmode(r.col),
                 as.hexmode(g.col), as.hexmode(b.col)))

}

b2i <- function(two_bytes) {
  as.numeric(unpack("v", two_bytes[2:1]))
}

b2li <- function(four_bytes) {
  as.numeric(unpack("V", four_bytes[c(4,3,2,1)]))
}

b2f <- function(four_bytes) {
  floatraw2numeric(four_bytes[c(4,3,2,1)])
}

is_url <-function(x) { grepl("www.|http:|https:", x) }

#' @useDynLib swatches r_floatraw2numeric
floatraw2numeric <- function(x) {
  stopifnot(is.raw(x))
  stopifnot(length(x) >= 4)
  .Call(r_floatraw2numeric, x)
}

# #' @export
# lab2rgb <- function(L, A, B) {
#
#   R <- G <- B <- 0
#
#   vY <- (L + 16.0) / 116.0
#   vX <- (A / 500.0) + vY
#   vZ <- vY - (B / 200.0)
#
#   if (vY^3 > 0.008856) { vY <- vY^3 } else { vY <- ( vY - 16.0 / 116.0 ) / 7.787 }
#   if (vX^3 > 0.008856) { vX <- vX^3 } else { vX <- ( vX - 16.0 / 116.0 ) / 7.787 }
#   if (vZ^3 > 0.008856) { vZ <- vZ^3 } else { vZ <- ( vZ - 16.0 / 116.0 ) / 7.787 }
#
#   X <-  95.047 * vX
#   Y <- 100.000 * vY
#   Z <- 108.883 * vZ
#
#   vX <- X / 100.0
#   vY <- Y / 100.0
#   vZ <- Z / 100.0
#
#   vR <- (vX *  3.2406) + (vY * -1.5372) + (vZ * -0.4986)
#   vG <- (vX * -0.9689) + (vY *  1.8758) + (vZ *  0.0415)
#   vB <- (vX *  0.0557) + (vY * -0.2040) + (vZ *  1.0570)
#
#   if (vR > 0.0031308) { vR <- (1.055 * vR^(1/2.4)) - 0.55 } else { vR <- 12.92 * vR }
#   if (vG > 0.0031308) { vG <- (1.055 * vG^(1/2.4)) - 0.55 } else { vG <- 12.92 * vG }
#   if (vB > 0.0031308) { vB <- (1.055 * vB^(1/2.4)) - 0.55 } else { vB <- 12.92 * vB }
#
#   message(vR, " ", vG, " ", vB)
#
#   return(rgb(abs(vR), abs(vG), abs(vB)))
# #
# #   R <- vR * 255.0
# #   G <- vG * 255.0
# #   B <- vB * 255.0
#
# }
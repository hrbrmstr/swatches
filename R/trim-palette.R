#' Try to intelligently reduce a large palette down to a reasonable smaller
#' set of colors
#'
#' Given a palette and a desired number of colors to use, this function will
#' compute CIEDE2000 and attempt to reduce the input set to a disctinct
#' smaller set of colors based on color distances.
#'
#' @param pal input palette to reduct
#' @param n number of desired colors
#' @return vector of \code{n} colors from \code{pal}
#' @note internal CIEDE2000 color distance implementation by Gaurav Sharma & Maynard P Baalthazar
#' @export
trim_palette <- function(pal, n=5) {

  tmp <- as(colorspace::hex2RGB(pal, gamma=TRUE), "LAB")

  ncols <- nrow(tmp@coords)
  mm <- matrix(nrow=ncols, ncol=ncols)

  outer(1:ncols, 1:ncols, FUN = function(i, j) {
    deltaE2000(tmp[i], tmp[j], 1, 2, 1)
  }) -> mm

  mmd <- as.dist(mm)
  hc <- hclust(mmd, method="ward.D2")
  ct <- cutree(hc, n)

  gsub(" ", "0", pal[!duplicated(ct)])

}

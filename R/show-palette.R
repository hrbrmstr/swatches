#' Display a color palette
#'
#' Given a character vector (hex RGB values), display palette in graphics window.
#'
#' @param palette vector of character hex RGB values
#' @export
#' @examples
#' # built-in palette
#' keep_the_change <- read_ase(system.file("palettes",
#'                             "keep_the_change.ase", package="swatches"))
#' print(keep_the_change)
#' # show_palette(keep_the_change)
show_palette <- function(palette) {
  n <- length(palette)
  if (length(palette > 0)) {
    image(1:n, 1, as.matrix(1:n), col = palette,
          xlab = "", ylab = "", xaxt = "n", yaxt = "n",
          bty = "n")

  }
}

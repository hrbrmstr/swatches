#' Read colors from KDE Palette (colors) files
#'
#' Given a path or URL to an \code{.colors} file, this function will return
#' a named character vector (if color names are present) of hex RGB colors.
#'
#' @param path partial or full file path or URL to a GPL file
#' @param use_names add color names to the vector (defaults to \code{TRUE}). See NOTE
#' @param .verbose show extra information about GPL file processing
#' @note When using named color palettes in a \code{ggplot2} \code{scale_} context, you
#'     must \code{unname}, set \code{use_names} to \code{FALSE} or override their names
#'     to map to your own factor levels.
#' @export
#' @examples
#' # built-in palette
#' fourty <- read_kde(system.file("palettes", "fourty.colors", package="swatches"))
#' print(fourty)
#' #show_palette(fourty)
#'
#' # show_palette(bright)
read_kde <- function(path, use_names=TRUE, .verbose=FALSE) {

  if (is_url(path)) {
    tf <- tempfile()
    httr::stop_for_status(httr::GET(path, httr::write_disk(tf)))
    path <- tf
    on.exit(unlink(tf), add = TRUE)
  }

  path <- normalizePath(path.expand(path))

  kde <- grep("^$", readLines(path, warn=FALSE), value=TRUE, invert=TRUE)

  n_colors <- length(kde) - 1

  if (.verbose) message("# Colors: " , n_colors)

  pal <- NULL

  pal <- sapply(2:length(kde), function(i) {
    mat <- str_match(kde[i],
"[[:blank:]]*([[:digit:]]+)[[:blank:]]*([[:digit:]]+)[[:blank:]]*([[:digit:]]+)[[:blank:]]*(.*)$")
    rgb(mat[2], mat[3], mat[4], names=mat[5], maxColorValue=255)
  })

  if (!use_names) { pal <- unname(pal) }

  gsub(" ", "0", pal)

}
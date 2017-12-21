#' Read colors from Adobe Color (ACO) files
#'
#' Given a path or URL to an \code{.aco} file, this function will return
#' a named character vector (if color names are present) of hex RGB colors.
#'
#' @param path partial or full file path or URL to an ACO file
#' @param use_names add color names to the vector (defaults to \code{TRUE}). See NOTE
#' @param .verbose show extra information about ACO file processing
#' @note When using named color palettes in a \code{ggplot2} \code{scale_} context, you
#'     must \code{unname}, set \code{use_names} to \code{FALSE} or override their names
#'     to map to your own factor levels.
#' @export
#' @examples
#' # built-in palette
#' eighties <- read_aco(system.file("palettes", "tomorrow_night_eighties.aco", package="swatches"))
#' print(eighties)
#' show_palette(eighties)
#'
#' # from the internet directly
#' \dontrun{
#' tomorrow_night <- read_aco("https://bit.ly/tomorrow-night-aco")
#' print(tomorrow_night)
#' show_palette(tomorrow_night)
#' }
read_aco <- function(path, use_names=TRUE, .verbose=FALSE) {

  if (is_url(path)) {
    tf <- tempfile()
    httr::stop_for_status(httr::GET(path, httr::write_disk(tf)))
    path <- tf
    on.exit(unlink(tf), add = TRUE)
  }

  path <- normalizePath(path.expand(path))

  aco <- readBin(path, "raw", file.info(path)$size, endian="big")

  version <- unpack("v", aco[2:1])[[1]]
  n_colors <- unpack("v", aco[4:3])[[1]]

  if (.verbose) {
    message("ACO Version: ", version)
    message("# Colors: " , n_colors)
  }

  pal <- NULL

  if (version == 1) {
    pal <- decode_aco_v1(aco, n_colors)
  } else {
    pal <- decode_aco_v2(aco, n_colors)
  }

  if (!use_names) { pal <- unname(pal) }

  gsub(" ", "0", pal)

}

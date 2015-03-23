#
# # cc-ooo.soc
#
# #' Read colors from OpenOffice Palette (SOC) files
#'
#' Given a path or URL to an \code{.soc} file, this function will return
#' a named character vector (if color names are present) of hex RGB colors.
#'
#' @param path partial or full file path or URL to a GPL file
#' @param use_names add color names to the vector (defaults to \code{TRUE}). See NOTE
#' @param .verbose show extra information about GPL file processing
#' @note When using named color palettes in a \code{ggplot2} \code{scale_} context, you
#'     must \code{unname} them or set \code{use_names} to \code{FALSE}.
#'     Not sure if this is a bug or a deliberate feature in ggplot2. Also, Neither Lab nor
#'     greyscale colors are supported.
#' @export
#' @examples
#' # built-in palette
#' ccooo <- read_soc(system.file("palettes",
#'                      "cc-ooo.soc", package="swatches"))
#' print(ccooo)
#' #show_palette(ccooo)
#'
#' # from the internet directly
#' # galaxy <- read_soc("https://www.openoffice.org/ui/VisualDesign/docs/colors/galaxy.soc")
#' # print(galaxy)
#' # show_palette(galaxy)
read_soc <- function(path, use_names=TRUE, .verbose=FALSE) {

  if (is_url(path)) {
    tf <- tempfile()
    stop_for_status(GET(path, write_disk(tf)))
    path <- tf
  }

  pal <- NULL

  soc <- xmlParse("inst/palettes/cc-ooo.soc")
  tmp <- gsub("^\ +", "", xpathSApply(soc, "//draw:color", xmlAttrs, "draw:name"))
  pal <- tmp[seq(2, length(tmp), 2)]
  names(pal) <- tmp[seq(1, length(tmp), 2)]

  n_colors <- length(pal)

  if (.verbose) {
    message("# Colors: " , n_colors)
  }

  if (!use_names) { pal <- unname(pal) }

  pal

}
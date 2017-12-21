#' Read colors from OpenOffice Palette (SOC) files
#'
#' Given a path or URL to an \code{.soc} file, this function will return
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
#' soc_file <- system.file("palettes", "ccooo.soc", package="swatches")
#' system(sprintf("cat %s", soc_file))
#' ccooo <- read_soc(soc_file)
#' print(ccooo)
#' show_palette(ccooo)
#'
#' # from the internet directly
#' \dontrun{
#' galaxy <- read_soc("https://www.openoffice.org/ui/VisualDesign/docs/colors/galaxy.soc")
#' print(galaxy)
#' show_palette(galaxy)
#' }
read_soc <- function(path, use_names=TRUE, .verbose=FALSE) {

  if (is_url(path)) {
    tf <- tempfile()
    httr::stop_for_status(GET(path, httr::write_disk(tf)))
    path <- tf
  }

  path <- normalizePath(path.expand(path))

  pal <- NULL

  soc <- xml2::read_xml(path)

  col_nodes <- xml2::xml_find_all(soc, "//draw:color", ns = xml2::xml_ns(soc))

  x_names <- xml2::xml_attr(col_nodes, "draw:name", ns = xml2::xml_ns(soc))
  x_names <- trimws(x_names)

  pal <- xml2::xml_attr(col_nodes, "draw:color", ns = xml2::xml_ns(soc))
  names(pal) <- x_names

  n_colors <- length(pal)

  if (.verbose) message("# Colors: " , n_colors)

  if (!use_names) { pal <- unname(pal) }

  gsub(" ", "0", pal)

}
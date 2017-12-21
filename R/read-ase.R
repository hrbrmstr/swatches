#' Read colors from Adobe Swatch Exchange (ASE) files
#'
#' Given a path or URL to an \code{.ase} file, this function will return
#' a named character vector (if color names are present) of hex RGB colors.
#'
#' @param path partial or full file path or URL to an ASE file
#' @param use_names add color names to the vector (defaults to \code{TRUE}). See NOTE
#' @param .verbose show extra information about ASE file processing
#' @note When using named color palettes in a \code{ggplot2} \code{scale_} context, you
#'     must \code{unname}, set \code{use_names} to \code{FALSE} or override their names
#'     to map to your own factor levels. Also, Neither Lab nor greyscale colors are supported.
#' @export
#' @examples
#' # built-in palette
#' keep_the_change <- read_ase(system.file("palettes", "keep_the_change.ase", package="swatches"))
#' print(keep_the_change)
#' show_palette(keep_the_change)
#'
#' # from the internet directly
#' \dontrun{
#' github <- "https://github.com/picwellwisher12pk/en_us/raw/master/Swatches/Metal.ase"
#' metal <- read_ase(github)
#' print(metal)
#' show_palette(metal)
#' }
read_ase <- function(path, use_names=TRUE, .verbose=FALSE) {

  if (is_url(path)) {
    tf <- tempfile()
    httr::stop_for_status(httr::GET(path, httr::write_disk(tf)))
    path <- tf
    on.exit(unlink(tf), add = TRUE)
  }

  path <- normalizePath(path.expand(path))

  ase <- readBin(path, "raw", file.info(path)$size, endian="big")

  if (unpack("A4", ase[1:4])[[1]] != "ASEF") {
    message("Not a valid ASE file")
    stop()
  }

  version <- sprintf("%d.%d", b2i(ase[5:6]), b2i(ase[7:8]))

  block_count <- b2li(ase[9:12])

  if (.verbose) {
    message("ASE Version: ", version)
    message("Block count: ", block_count)
  }

  pal <- decode_ase(ase, block_count)

  if (!use_names) { pal <- unname(pal) }

  gsub(" ", "0", pal)

}

#' Read colors from Adobe Color (ACO) files
#'
#' Given a path or URL to an \code{.aco} file, this function will return
#' a named character vector (if color names are present) of hex RGB colors.
#'
#' @param path partial or full file path or URL to an ACO file
#' @param use_names add color names to the vector (defaults to \code{TRUE}). See NOTE
#' @param .verbose show extra information about ACO file processing#' @export
#' @note When using named color palettes in a \code{ggplot2} \code{scale_} context, you
#'     must \code{unname} them or set \code{use_names} to \code{FALSE}.
#'     Not sure if this is a bug or a deliberate feature in ggplot2. Also, Neither Lab nor
#'     greyscale colors are supported.
#' @export
#' @examples \dontrun{
#' # built-in palette
#' eighties <- read_ase(system.file("palettes",
#'                      "tomorrow_night_eighties.aco", package="swatches"))
#' print(eighties)
#' show_palette(eighties)
#'
#' # from the internet directly
#' tomorrow_night <- read_ase("l.dds.ec/tomorrow-night-aco")
#' print(tomorrow_night)
#' show_palette(tomorrow_night)
#' }
read_aco <- function(path, use_names=TRUE, .verbose=FALSE) {

  if (is_url(path)) {
    tf <- tempfile()
    stop_for_status(GET(path, write_disk(tf)))
    path <- tf
  }

  aco <- readBin(path.expand(path), "raw",
                file.info(path.expand(path))$size, endian="big")

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

  pal

}

#' Read colors from Adobe Swatch Exchange (ASE) files
#'
#' Given a path or URL to an \code{.ase} file, this function will return
#' a named character vector (if color names are present) of hex RGB colors.
#'
#' @param path partial or full file path or URL to an ASE file
#' @param use_names add color names to the vector (defaults to \code{TRUE}). See NOTE
#' @param .verbose show extra information about ASE file processing
#' @note When using named color palettes in a \code{ggplot2} \code{scale_} context, you
#'     must \code{unname} them or set \code{use_names} to \code{FALSE}.
#'     Not sure if this is a bug or a deliberate feature in ggplot2. Also, Neither Lab nor
#'     greyscale colors are supported.
#' @export
#' @examples
#' \dontrun{
#' # built in palette
#' keep_the_change <- read_ase(system.file("palettes",
#'                             "keep_the_change.ase", package="swatches"))
#' print(keep_the_change)
#' show_palette(keep_the_change)
#'
#' # from the internet directly
#' github <- "https://github.com/picwellwisher12pk/en_us/raw/master/Swatches/Metal.ase"
#' metal <- read_ase(github)
#' print(metal)
#' show_palette(metal)
#' }
read_ase <- function(path, use_names=TRUE, .verbose=FALSE) {

  if (is_url(path)) {
    tf <- tempfile()
    stop_for_status(GET(path, write_disk(tf)))
    path <- tf
  }

  ase <- readBin(path, "raw",
                 file.info(path.expand(path))$size, endian="big")

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
  pal

}

#' Display a color palette
#'
#' Given a character vector (hex RGB values), display palette in graphics window.
#'
#' @param palette vector of character hex RGB values
#' @export
#' @examples
#' \dontrun{
#' # built in palette
#' keep_the_change <- read_ase(system.file("palettes",
#'                             "keep_the_change.ase", package="swatches"))
#' print(keep_the_change)
#' show_palette(keep_the_change)
#' }
show_palette <- function(palette) {
  n <- length(palette)
  if (length(palette > 0)) {
    image(1:n, 1, as.matrix(1:n), col = palette,
          xlab = "", ylab = "", xaxt = "n", yaxt = "n",
          bty = "n")

  }
}

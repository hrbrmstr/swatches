#' Read colors from palette files
#'
#' Given a path or URL to an palette file, this function will attempt to determine
#' which palette file format to read by the file type and return
#' a named character vector (if color names are present) of hex RGB colors.
#'
#' @param path partial or full file path or URL to a GPL file
#' @param use_names add color names to the vector (defaults to \code{TRUE}). See NOTE
#' @param .verbose show extra information about GPL file processing
#' @note When using named color palettes in a \code{ggplot2} \code{scale_} context, you
#'     must \code{unname}, set \code{use_names} to \code{FALSE} or override their names
#'     to map to your own factor levels.
#' @export
read_palette <- function(path, use_names=TRUE, .verbose=FALSE) {

  ext <- file_ext(path)

  path <- normalizePath(path.expand(path))

  if (ext == "aco") { return(read_aco(path, use_names, .verbose)) }
  if (ext == "ase") { return(read_ase(path, use_names, .verbose)) }
  if (ext == "gpl") { return(read_gpl(path, use_names, .verbose)) }
  if (ext == "soc") { return(read_soc(path, use_names, .verbose)) }
  if (ext == "colors") { return(read_kde(path, use_names, .verbose)) }

  message("Unrecognized or unsupported palette file format")

  return(NULL)

}

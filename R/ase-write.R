constants <- list(

  FILE_SIGNATURE = "ASEF",
  FORMAT_VERSION  = c(as.raw(0x00), as.raw(0x01)),

  COLOR_START = c(as.raw(0x00), as.raw(0x01)),
  GROUP_START = c(as.raw(0xc0), as.raw(0x01)),
  GROUP_END   = c(as.raw(0xc0), as.raw(0x02)),

  MODE_COLOR  = 1L,
  MODE_GROUP  = 2L,

  STATE_GET_MODE    = 1L,
  STATE_GET_LENGTH  = 2L,
  STATE_GET_NAME    = 3L,
  STATE_GET_MODEL   = 4L,
  STATE_GET_COLOR   = 5L,
  STATE_GET_TYPE    = 6L,

  COLOR_SIZES = list(
    CMYK = 4L,
    RGB = 3L,
    LAB = 3L,
    GRAY = 1L
  ),

  WRITE_COLOR_TYPES = list(
    global = 0L,
    spot = 1L,
    normal = 2L
  )

)

writeUTF8String <- function(buf, x) {
  invisible(c(buf, writeBin(charToRaw(x), con = raw(), endian = "big")))
}

writeUTF16BEString <- function(buf, x) {
  x <- stri_conv(x, from='UTF-8', to = "UTF-16BE", to_raw=TRUE)[[1]]
  invisible(c(buf, writeBin(x, con = raw())))
}

writeInt <- function(buf, x) {
  invisible(c(buf, writeBin(as.integer(x), con = raw(), size = 4, endian = "big")))
}

writeShort <- function(buf, x) {
  invisible(c(buf, writeBin(as.integer(x), con = raw(), size = 2, endian = "big")))
}

writeFloat <- function(buf, x) {
  invisible(c(buf, writeBin(as.double(x), con = raw(), size = 4, endian = "big")))
}

chunk_count <- function(swatch) {

  if (length(names(swatch)) == 0) {
    message("recurse")
    sum(sapply(chunk_count, swatch))
  } else {
    message("in")
    if (hasName(swatch, "data")) return(1)
    if (hasName(swatch, "swatches")) return(2 + length(swatch[["swatches"]]))
  }

}

#' Encode a built ASE object for output
#'
#' @param data An ASE swatch object created by [create_ase()]
#' @return raw vector
#' @export
#' @examples
#' create_ase() |>
#' add_color(
#'   name = "RGB Red",
#'   model = "RGB",
#'   color_vals = as.vector(col2rgb("#FF0000")/255),
#'   type = "global"
#' ) |>
#'   add_color(
#'     name = "RGB Yellow",
#'     model = "RGB",
#'     color_vals = as.vector(col2rgb("#FFFF00")/255),
#'     type = "global"
#'   ) |>
#'   ase_encode() |>
#'   writeBin(tempfile(fileext = ".ase"))
ase_encode <- function(data) {

  ase <- vector("raw")

  ase <- writeUTF8String(ase, constants$FILE_SIGNATURE)
  ase <- c(ase, constants$FORMAT_VERSION)
  ase <- c(ase, as.raw(0x00), as.raw(0x00))
  ase <- writeInt(ase, length(data$colors))

  for (color in data$colors) {

    swatch <- vector("raw")

    ase <- c(ase, constants$COLOR_START)

    swatch <- writeShort(swatch, (nchar(color$name) + 1))
    swatch <- writeUTF16BEString(swatch, color$name)
    swatch <- c(swatch, c(as.raw(0x00), as.raw(0x00)))

    model <- stringi::stri_pad(color$model, width = 4, side = "right")
    swatch <- writeUTF8String(swatch, model)

    for (component in color$color) {
      swatch <- writeFloat(swatch, component)
    }

    swatch <- writeShort(swatch, constants$WRITE_COLOR_TYPES[[color$type]]);

    ase <- writeInt(ase, length(swatch))

    ase <- c(ase, swatch)

  }

  invisible(ase)

}

#' Create an ASE object
#'
#' @return a `list` (invisibly) classed as `ase`
#' @export
#' @examples
#' create_ase() |>
#' add_color(
#'   name = "RGB Red",
#'   model = "RGB",
#'   color_vals = as.vector(col2rgb("#FF0000")/255),
#'   type = "global"
#' ) |>
#'   add_color(
#'     name = "RGB Yellow",
#'     model = "RGB",
#'     color_vals = as.vector(col2rgb("#FFFF00")/255),
#'     type = "global"
#'   ) |>
#'   ase_encode() |>
#'   writeBin(tempfile(fileext = ".ase"))
create_ase <- function() {
  list(
    version = "1.0",
    colors = list()
  ) -> ret
  class(ret) <- c("ase", "list")
  invisible(ret)
}

#' Add a named color to an ASE swatch object
#'
#'
#' @param ase_obj An ASE object created with [create_ase()]
#' @param name name of the color
#' @param model one of "`RGB`", "`Gray`", "`CMYK`", or "`LAB`"
#' @param color_vals vector of color values associated with the chosen `model`
#' @param type one of "`global`", "`spot`", or "`process`"
#' @return `ase_obj` (invisibly)
#' @export
#' @examples
#' create_ase() |>
#' add_color(
#'   name = "RGB Red",
#'   model = "RGB",
#'   color_vals = as.vector(col2rgb("#FF0000")/255),
#'   type = "global"
#' ) |>
#'   add_color(
#'     name = "RGB Yellow",
#'     model = "RGB",
#'     color_vals = as.vector(col2rgb("#FFFF00")/255),
#'     type = "global"
#'   ) |>
#'   ase_encode() |>
#'   writeBin(tempfile(fileext = ".ase"))
add_color <- function(ase_obj, name, model, color_vals, type) {

  name <- name[1]
  model <- match.arg(model[1], c("RGB", "Gray", "CMYK", "LAB"), several.ok = FALSE)
  type <- match.arg(type[1], c("global", "spot", "process"), several.ok = FALSE)

  list(
    name = name,
    model = model,
    color = color_vals,
    type = type
  ) -> new_color

  ase_obj$colors <- append(ase_obj$colors, list(new_color))

  invisible(ase_obj)

}

#' Convert a list of named, hexadecimal RBG colors into an ASE object
#'
#' @param colors named vector of RBG hex colors
#' @param type one of "`global`", "`spot`", or "`process`"
#' @return `ase` object
#' @export
#' @examples
#' ase_temp <- tempfile(fileext = ".ase")
#' on.exit(unlink(ase_temp))
#'
#' github_url <- "https://github.com/picwellwisher12pk/en_us/raw/master/Swatches/Metal.ase"
#' metal <- read_ase(github_url)
#'
#' hex_to_ase(metal, "global") |>
#'   ase_encode() |>
#'   writeBin(ase_temp)
#'
#' read_ase(ase_temp)
hex_to_ase <- function(colors, type) {

  type <- match.arg(type[1], c("global", "spot", "process"), several.ok = FALSE)

  ase <- create_ase()

  for (i in seq_along(colors)) {
    ase <- add_color(
      ase_obj = ase,
      name = names(colors[i]),
      model = "RGB",
      color_vals = as.vector(col2rgb(colors[i])/255),
      type = type[1]
    )
  }

  invisible(ase)

}
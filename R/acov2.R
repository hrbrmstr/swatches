decode_aco_v2 <- function(aco, n_colors) {

  con <- rawConnection(aco)
  on.exit(close(con))

  tmp <- readBin(con, "raw", 4, endian="big")

  val <- sapply(1:n_colors, function(i) {
    parse_aco_v2_block(con)
  })

  val[!is.na(val)]

}

parse_aco_v2_block <- function(con) {

  colorspace <- b2i(readBin(con, "raw", 2, endian="big"))

  color <- NA

  if (colorspace == 0) { # RGB

    w <- b2i(readBin(con, "raw", 2, endian="big"))
    x <- b2i(readBin(con, "raw", 2, endian="big"))
    y <- b2i(readBin(con, "raw", 2, endian="big"))
    z <- b2i(readBin(con, "raw", 2, endian="big"))

    color <- rgb(w, x, y, maxColorValue=65535)

  } else if (colorspace == 1) { # HSB

    w <- b2i(readBin(con, "raw", 2, endian="big"))
    x <- b2i(readBin(con, "raw", 2, endian="big"))
    y <- b2i(readBin(con, "raw", 2, endian="big"))
    z <- b2i(readBin(con, "raw", 2, endian="big"))

    color <- hsv((w/182.04)/360, ((x/655.35)/360), ((y/655.35)/360))

  } else if (colorspace == 2) { # CMYK

    w <- b2i(readBin(con, "raw", 2, endian="big"))
    x <- b2i(readBin(con, "raw", 2, endian="big"))
    y <- b2i(readBin(con, "raw", 2, endian="big"))
    z <- b2i(readBin(con, "raw", 2, endian="big"))

    color <- cmyk((100-w/655.35), (100-x/655.35), (100-y/655.35), (100-z/655.35))

  } else if (colorspace == 7) { # Lab

    w <- b2i(readBin(con, "raw", 2, endian="big"))
    x <- readBin(con, "integer", 1, 2, signed=TRUE, endian="big")
    y <- readBin(con, "integer", 1, 2, signed=TRUE, endian="big")
    z <- b2i(readBin(con, "raw", 2, endian="big"))

#     color <- LAB(w/100, x/100, y/100)

    color <- NA

    message("Lab colors not supported yet")

  } else if (colorspace == 8) { # Grayscale

    w <- b2i(readBin(con, "raw", 2, endian="big"))
    x <- b2i(readBin(con, "raw", 2, endian="big"))
    y <- b2i(readBin(con, "raw", 2, endian="big"))
    z <- b2i(readBin(con, "raw", 2, endian="big"))

    message("Grayscale not supported yet")

    color <- w/39.0625

  } else if (colorspace == 9) { # Wide CMYK

    w <- b2i(readBin(con, "raw", 2, endian="big"))
    x <- b2i(readBin(con, "raw", 2, endian="big"))
    y <- b2i(readBin(con, "raw", 2, endian="big"))
    z <- b2i(readBin(con, "raw", 2, endian="big"))

    color <- cmyk(w/100, x/100, y/100, z/100)

  } else {

    w <- b2i(readBin(con, "raw", 2, endian="big"))
    x <- b2i(readBin(con, "raw", 2, endian="big"))
    y <- b2i(readBin(con, "raw", 2, endian="big"))
    z <- b2i(readBin(con, "raw", 2, endian="big"))

    message("Color format unknown")

    color <- NA
  }

  tmp <- readBin(con, "raw", 2, endian="big")

  label <- ""
  label_length <- b2i(readBin(con, "raw", 2, endian="big")) * 2
  if (label_length > 0) {
    label <- readBin(con, "raw", label_length-2, endian="big")
    label <- rawToChar(label[1:length(label)], multiple=TRUE)
    label <- paste(label, sep="", collapse="")
  }

  names(color) <- label

  tmp <- readBin(con, "raw", 2, endian="big")

  return(color)

}
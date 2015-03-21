decode_aco_v1 <- function(aco, n_colors) {

  palette <- sapply(1:n_colors, function(i) {

    start <- 5 + (10*(i-1))

    colorspace <- b2i(aco[start:(start+1)])

    start <- start + 2
    w <- b2i(aco[start:(start+1)])

    start <- start + 2
    x <- b2i(aco[start:(start+1)])

    start <- start + 2
    y <- b2i(aco[start:(start+1)])

    start <- start + 2
    z <- b2i(aco[start:(start+1)])

    color <- ""

    if (colorspace == 0) { # RGB
      color <- rgb(w, x, y, maxColorValue=65535)
    } else if (colorspace == 1) { # HSB
      color <- hsv((w/182.04)/360, ((x/655.35)/360), ((y/655.35)/360))
    } else if (colorspace == 2) { # CMYK
      color <- cmyk((100-w/655.35), (100-x/655.35), (100-y/655.35), (100-z/655.35))
    } else if (colorspace == 7) { # Lab
      message("Lab not supported yet")
      color <- NA
    } else if (colorspace == 8) { # Grayscale
      message("Greyscale not supported yet")
      color <- w/39.0625
    } else if (colorspace == 9) { # Wide CMYK
      color <- cmyk(w/100, x/100, y/100, z/100)
    } else {
      message("Unknown")
      color <- NA
    }

    return(color)

  })

  return(palette)

}

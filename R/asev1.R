GROUP_START <- 0xc001
GROUP_END <- 0xc002
COLOR_START <- 0x0001

decode_ase <- function(ase, block_count) {

  con <- rawConnection(ase)
  on.exit(close(con))

  tmp <- readBin(con, "raw", 12, endian="big")

  val <- sapply(1:block_count, function(i) {
    parse_block(con)
  })

  val[!is.na(val)]

}

parse_block <- function(con) {

  block_type <- try(readBin(con, "raw", 2, endian="big"))

  if (!inherits(block_type, "try-error")) {

    block_type <- b2i(block_type)

    if (block_type == COLOR_START) {

      block_length <- b2li(readBin(con, "raw", 4, endian="big"))
      data <- readBin(con, "raw", block_length, endian="big")

      label_length <- b2i(data[1:2]) * 2
      label <- data[3:(3+label_length)]
      label <- rawToChar(label[1:(length(label)-1)], multiple=TRUE)
      label <- paste(label, sep="", collapse="")

      color_data <- try(data[3+label_length:length(data)])

      if (!inherits(color_data, "try-error")) {

        color_mode <- gsub("\ +$", "", rawToChar(color_data[1:4]))

        color <- NA

        if (color_mode == "RGB") {

          R <- b2f(color_data[5:8])
          G <- b2f(color_data[9:12])
          B <- b2f(color_data[13:16])
          color <- as.character(rgb(R, G, B))

        } else if (color_mode == "CMYK") {

          C <- b2f(color_data[5:8])
          M <- b2f(color_data[9:12])
          Y <- b2f(color_data[13:16])
          K <- b2f(color_data[17:20])
          color <- as.character(cmyk(C*100, M*100, Y*100, K*100))

        } else if (color_mode == "LAB") {

          message("LAB")

          L <- b2f(color_data[5:8])
          A <- b2f(color_data[9:12])
          B <- b2f(color_data[13:16])
          color <- list(L, A, B)

        } else if (color_mode == "Grey") {

          message("Grey")

          G <- b2f(color_data[5:8])
          color <- G

        }

        color_type <- b2i(color_data[(length(color_data)-1):length(color_data)])

        names(color) <- label

        return(color)

      }

    } else if (block_type == GROUP_START) {

      block_length <- b2li(readBin(con, "raw", 4, endian="big"))
      data <- readBin(con, "raw", block_length, endian="big")

      label_length <- b2i(data[1:2]) * 2
      label <- data[3:(3+label_length)]
      label <- rawToChar(label[1:(length(label)-1)], multiple=TRUE)
      label <- paste(label, sep="", collapse="")

      color_data <- try(data[3+label_length:length(data)])

      return(NA)

    } else if (block_type == GROUP_END) {
      tmp <- readBin(con, "raw", 4, endian="big")
      return(NA)
    } else {
      message("Invalid block type [", block_type, "]. Possible corrupted ASE file")
      return(NA)
    }

  }

}

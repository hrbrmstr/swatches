% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ase-write.R
\name{hex_to_ase}
\alias{hex_to_ase}
\title{Convert a list of named, hexadecimal RBG colors into an ASE object}
\usage{
hex_to_ase(colors, type)
}
\arguments{
\item{colors}{named vector of RBG hex colors}

\item{type}{one of "\code{global}", "\code{spot}", or "\code{process}"}
}
\value{
\code{ase} object
}
\description{
Convert a list of named, hexadecimal RBG colors into an ASE object
}
\examples{
ase_temp <- tempfile(fileext = ".ase")
on.exit(unlink(ase_temp))

github_url <- "https://github.com/picwellwisher12pk/en_us/raw/master/Swatches/Metal.ase"
metal <- read_ase(github_url)

hex_to_ase(metal, "global") |>
  ase_encode() |>
  writeBin(ase_temp)

read_ase(ase_temp)
}

#' Read, Inspect, Manipulate, and Save Color Swatch Files
#'
#' There are numerous places to create and download color
#' palettes. These are usually shared in Adobe swatch file formats of
#' some kind. There is also often the need to use standard palettes
#' developed within an organization to ensure that aesthetics are carried over
#' into all projects and output. Now there is a way to read these swatch
#' files in R and avoid transcribing or converting color values by hand or
#' or with other programs. This package provides functions to read and
#' inspect Adobe Color (ACO), Adobe Swatch Exchange (ASE), GIMP Palette (GPL),
#' OpenOffice palette (SOC) files and KDE Palette ("colors") files. Detailed
#' descriptions of Adobe Color and Swatch Exchange file formats as well as other
#' swatch file formats can be found at <http://www.selapa.net/swatches/colors/fileformats.php>.
#'
#' @name swatches
#' @keywords internal
#' @docType package
#' @import pack stringi
#' @importFrom xml2 read_xml xml_find_all xml_attr
#' @importFrom tools file_ext
#' @importFrom httr write_disk stop_for_status GET
#' @importFrom colorspace hex2RGB coords RGB
#' @importFrom grDevices col2rgb hsv rgb
#' @importFrom graphics image
#' @importFrom methods as
#' @importFrom stats as.dist cutree hclust
"_PACKAGE"


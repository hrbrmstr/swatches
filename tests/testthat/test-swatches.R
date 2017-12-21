context("palettes parse properly")
test_that("KDE", {
  fourty <- read_palette(system.file("palettes", "fourty.colors", package="swatches"))
  expect_equal(fourty[10], c("Dark red"="#800000"))
})

test_that("GIMP", {
  gimp16 <- read_palette(system.file("palettes", "base16.gpl", package="swatches"))
  expect_equal(gimp16[5], c("base04"="#D4CFC9"))
})

test_that("ACO", {
  eighties <- read_palette(system.file("palettes", "tomorrow_night_eighties.aco", package="swatches"))
  expect_equal(eighties[4], "#CCCCCC")
})

test_that("ASE", {
  keep_the_change <- read_palette(system.file("palettes", "keep_the_change.ase", package="swatches"))
  expect_equal(keep_the_change[2], structure("#D9042B", .Names = ""))
})

test_that("SOC", {
  ccooo <- read_palette(system.file("palettes", "ccooo.soc", package="swatches"))
  expect_equal(ccooo[10], c("Blue 2"="#4374b7"))
})

context("palette triming")
test_that("trim_palette", {
  fourty <- read_palette(system.file("palettes", "fourty.colors", package="swatches"))
  ftrim <- trim_palette(fourty)
  structure(
    c("#000000", "#303030", "#C3C3C3", "#FFFFFF", "#800000"),
    .Names = c("Black", "Almost black", "Light gray", "White", "Dark red")
  ) -> ftrim_saved
  expect_equal(ftrim, ftrim_saved)
})


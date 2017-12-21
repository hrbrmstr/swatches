cmyk <- function(C, M, Y, K) {

  C <- C / 100.0
  M <- M / 100.0
  Y <- Y / 100.0
  K <- K / 100.0

  n.c <- (C * (1-K) + K)
  n.m <- (M * (1-K) + K)
  n.y <- (Y * (1-K) + K)

  r.col <- ceiling(255 * (1-n.c))
  g.col <- ceiling(255 * (1-n.m))
  b.col <- ceiling(255 * (1-n.y))

  return(sprintf("#%02s%02s%02s", as.hexmode(r.col),
                 as.hexmode(g.col), as.hexmode(b.col)))

}

b2i <- function(two_bytes) {
  as.numeric(unpack("v", two_bytes[2:1]))
}

b2li <- function(four_bytes) {
  as.numeric(unpack("V", four_bytes[c(4,3,2,1)]))
}

b2f <- function(four_bytes) {
  floatraw2numeric(four_bytes[c(4,3,2,1)])
}

is_url <-function(x) { grepl("(www\\.|http\\:|https\\:)", x) }

#' @useDynLib swatches r_floatraw2numeric
floatraw2numeric <- function(x) {
  stopifnot(is.raw(x))
  stopifnot(length(x) >= 4)
  .Call(r_floatraw2numeric, x)
}

# CIEDE2000

# Gaurav Sharma & Maynard P Baalthazar
deltaE2000 <- function(Labstd, Labsample, kl=1, kc=1, kh=1) {
  lstd <- colorspace::coords(Labstd)[,1]
  astd <- colorspace::coords(Labstd)[,2]
  bstd <- colorspace::coords(Labstd)[,3]
  Cabstd <- sqrt(astd^2+bstd^2)
  lsample <- colorspace::coords(Labsample)[,1]
  asample <- colorspace::coords(Labsample)[,2]
  bsample <- colorspace::coords(Labsample)[,3]
  Cabsample <- sqrt(asample^2 + bsample^2)
  Cabarithmean <- (Cabstd + Cabsample)/2
  G <- 0.5* ( 1 - sqrt( (Cabarithmean^7)/(Cabarithmean^7 + 25^7)))
  apstd <- (1+G)*astd
  apsample <- (1+G)*asample
  apstd <- (1+G)*astd
  apsample <- (1+G)*asample
  Cpsample <- sqrt(apsample^2+bsample^2)
  Cpstd <- sqrt(apstd^2+bstd^2)
  Cpprod <- (Cpsample*Cpstd)
  zcidx <- which(Cpprod == 0)
  hpstd <- atan2(bstd,apstd)
  hpstd <- hpstd+2*pi*(hpstd < 0)
  hpstd[which( (abs(apstd)+abs(bstd))== 0) ] <- 0
  hpsample <-atan2(bsample,apsample)
  hpsample <- hpsample+2*pi*(hpsample < 0)
  hpsample[which( (abs(apsample)+abs(bsample))==0) ] <- 0
  dL <- lsample-lstd
  dC <- Cpsample-Cpstd
  dhp <- hpsample-hpstd
  dhp <-dhp - 2*pi* (dhp > pi )
  dhp <- dhp + 2*pi* (dhp < (-pi) )
  dhp[zcidx ] <- 0
  dH <- 2*sqrt(Cpprod)*sin(dhp/2)
  Lp <- (lsample+lstd)/2
  Cp <- (Cpstd+Cpsample)/2
  hp <- (hpstd+hpsample)/2
  hp <- hp - ( abs(hpstd-hpsample) > pi ) *pi
  hp <- hp + (hp < 0) *2*pi
  hp[zcidx] <- hpsample[zcidx]+hpstd[zcidx]
  Lpm502 <- (Lp-50)^2
  Sl <-1 + 0.015*Lpm502/sqrt(20+Lpm502)
  Sc <- 1+0.045*Cp
  T <- 1-0.17*cos(hp-pi/6 ) + 0.24*cos(2*hp) + 0.32*cos(3*hp+pi/30) -0.20*cos(4*hp-63*pi/180)
  Sh <- 1 + 0.015*Cp*T
  delthetarad <- (30*pi/180)*exp(- ( (180/pi*hp-275)/25)^2)
  Rc <- 2*sqrt((Cp^7)/(Cp^7 + 25^7))
  RT <- -sin(2*delthetarad)*Rc
  klSl <- kl*Sl
  kcSc <- kc*Sc
  khSh <- kh*Sh
  de00 <- sqrt( (dL/klSl)^2 + (dC/kcSc)^2 + (dH/khSh)^2 + RT*(dC/kcSc)*(dH/khSh) )

  return(as.numeric(de00))

}


sort_colors <- function(col) {

  c_rgb <- col2rgb(col)

  c_RGB <- RGB(t(c_rgb) %*% diag(rep(1/255, 3)))
  c_HSV <- as(c_RGB, "HSV")@coords

  col[rev(order(c_HSV[, 1], c_HSV[, 2], c_HSV[, 3]))]

}


# #' @export
# lab2rgb <- function(L, A, B) {
#
#   R <- G <- B <- 0
#
#   vY <- (L + 16.0) / 116.0
#   vX <- (A / 500.0) + vY
#   vZ <- vY - (B / 200.0)
#
#   if (vY^3 > 0.008856) { vY <- vY^3 } else { vY <- ( vY - 16.0 / 116.0 ) / 7.787 }
#   if (vX^3 > 0.008856) { vX <- vX^3 } else { vX <- ( vX - 16.0 / 116.0 ) / 7.787 }
#   if (vZ^3 > 0.008856) { vZ <- vZ^3 } else { vZ <- ( vZ - 16.0 / 116.0 ) / 7.787 }
#
#   X <-  95.047 * vX
#   Y <- 100.000 * vY
#   Z <- 108.883 * vZ
#
#   vX <- X / 100.0
#   vY <- Y / 100.0
#   vZ <- Z / 100.0
#
#   vR <- (vX *  3.2406) + (vY * -1.5372) + (vZ * -0.4986)
#   vG <- (vX * -0.9689) + (vY *  1.8758) + (vZ *  0.0415)
#   vB <- (vX *  0.0557) + (vY * -0.2040) + (vZ *  1.0570)
#
#   if (vR > 0.0031308) { vR <- (1.055 * vR^(1/2.4)) - 0.55 } else { vR <- 12.92 * vR }
#   if (vG > 0.0031308) { vG <- (1.055 * vG^(1/2.4)) - 0.55 } else { vG <- 12.92 * vG }
#   if (vB > 0.0031308) { vB <- (1.055 * vB^(1/2.4)) - 0.55 } else { vB <- 12.92 * vB }
#
#   message(vR, " ", vG, " ", vB)
#
#   return(rgb(abs(vR), abs(vG), abs(vB)))
# #
# #   R <- vR * 255.0
# #   G <- vG * 255.0
# #   B <- vB * 255.0
#
# }
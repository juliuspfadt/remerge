
mergeDf <- function(x, y) {
  
  nx <- nrow(x)
  ny <- nrow(y)
  
  nomx <- names(x)
  nomy <- names(y)
  nomy[which(nomy %in% nomx)] <- paste0(nomy[which(nomy %in% nomx)], "_y")
  names(y) <- nomy
  
  if (nx > ny) {
    y[(ny + 1):nx, ] <- NA
  } else { # this is highlyunlikely
    x[(nx + 1):ny, ] <- NA
  }
  return(cbind(x, y))
  
}
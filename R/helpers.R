transform_list = function(x) {
  x = transpose_list(x)
  map(x, unlist)
}

ffind = function(x, left = -Inf, right = Inf) {
  n = length(x)
  if (left <= x[[1L]] && right >= x[[n]]) {
    return(c(1L, n))
  }
  if (left > x[[n]] || right < x[[1L]]) {
    return(rep(NA_integer_, 2L))
  }
  it = findInterval(c(left, right), x)
  # in case there are no values in the interval, it contains the index of the smallest value below
  # and both values in it are identical,
  # e.g. searching the interval (1.1, 1.2) in c(1, 2) returns c(1, 1) which we here convert to an NA interval
  if (it[[1L]] == it[[2L]] && left > x[[it[[1L]]]]) {
    return(rep(NA_integer_, 2L))
  }
  if (it[[1L]] == 0L) {
    it[[1L]] = 1L
  } else if (x[[it[[1L]]]] < left) {
    it[[1L]] = it[[1L]] + 1L
  }
  it
}

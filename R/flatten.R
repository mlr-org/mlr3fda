#' @title Flattens a functional vector
#' @description
#' For each invividual ${i_1, ... i_n}$ we have obsrevations $o_j = (o_{j, 1}, ..., o_{j, n(j)})$.
#' Each $o_{i, j}$ is a argument-value pair $(a_{i, j}, v_{i, j})$.
#' Flattening a vector means creating a matrix, where there is a different column for
#' each distinct input $v_{i, j}$
#' Flattening a functional vector means creating a matrix with dimension (n, )
#'
#' @param x (`functional()`) Functional vector.
#' @param x (`character(1)`) Prefix for the column names.
#'
#' @examples
#' ids = c("a", "a", "b")
#' args = 1:3
#' vals = args * 2
#' funct = functional(args, vals, ids)
#' ffunct = flatten_functional(funct)
#' print(ffunct)
#'
#' @return
#' Returns a matrix.
#'
#' @export
flatten_functional = function(x) {
  assert_class(x, "functional")
  args = unlist(map(x, "arg"))
  args = unique(args)
  args = sort(args)

  m = matrix(nrow = length(x), ncol = length(args))
  colnames(m) = args
  for (i in seq_along(x)) {
    idx = match(x[[i]]$arg, args)
    m[i, idx] = x[[i]]$value
  }
  return(m)
}

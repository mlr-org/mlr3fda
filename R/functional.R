#' @title Creates a functional vector.
#'
#' @description
#' Creates an vector of class `functional` that contains function evaluations
#' from a usually unknown function f.
#' A functional vector is a list, where each element is again a named list
#' (list(arg = ..., value = ...)) with two equally long vectors `arg` and `value` such that
#' `value[i] = f(arg[i])`.
#'
#' @param args (`numeric()`) Arguments of the functionals.
#' @param value (`numeric()`) Values of the functionals.
#' @param ids (`atomic` vector) Ids assigning the the (arg, value) combinations to a id.
#'
#' @examples
# args = rep(1:3, times = 5)
# values = args * 3 + 2
# ids = rep(letters[1:5], each = 5)
#
# funct = functional(args, values, ids)
# print(funct)
#'
#' @export
functional = function(args, values, ids) {
  validate_functional(args, values, ids)
  dt = data.table(arg = args, value = values, id = ids)
  funct = dt[, .(x = list(list("arg" = arg, "value" = value))), "id"]$x
  # we can have only one evaluation per function
  # unique_sum = sum(dt[, .(count = uniqueN("arg")), by = "id"]$count)
  # assert_true(unique_sum == length(args))

  structure(class = c("functional", "list"), .Data = funct)
}

validate_functional = function(args, values, ids) {
  assert_numeric(args)
  assert_numeric(values)
  assert_atomic(ids)
  assert_true(length(args) == length(values))
  assert_true(length(values) == length(ids))
}


#' @export
`[.functional` = function(obj, ...) {
  functional(unclass(obj)[...])
}

#' @export
print.functional = function(x, ...) {
  catf("<functional[%s]>", length(x))
  invisible(x)
}

#' @export
as_functional = function(x, ...) {
  UseMethod("as_functional", x)
}

#' @export
as_functional.functional = function(x, ...) {
  x
}

#' @export
as_functional.matrix = function(x, args = NULL, ids = NULL, ...) {
  ids = ids %??% rep(seq_len(nrow(x)), each = ncol(x))
  args = args %??% rep(seq_len(ncol(x)), times = nrow(x))
  x = c(x)
  functional(args = args, values = x, ids = ids)
}


#' @export
#' @method as_functional data.table
as_functional.data.table = function(x, values, args, ids, ...) {
  args = x[, args, with = FALSE][[1L]]
  values = x[, values, with = FALSE][[1L]]
  ids = x[, ids, with = FALSE][[1L]]
  functional(args = args, values = values, ids = ids)
}

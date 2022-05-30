# #' @title Creates a functional vector.
# #'
# #' @description
# #' Creates an vector of class `functional` that contains function evaluations
# #' from a usually unknown function f.
# #' A functional vector is a list, where each element is again a named list
# #' (list(arg = ..., value = ...)) with two equally long vectors `arg` and `value` such that
# #' `value[i] = f(arg[i])`.
# #'
# #' @param args (`numeric()`) Arguments of the functionals.
# #' @param value (`numeric()`) Values of the functionals.
# #' @param ids (`atomic` vector) Ids assigning the the (arg, value) combinations to a id.
# #'
# #' @examples
# # args = rep(1:3, times = 5)
# # values = args * 3 + 2
# # ids = rep(letters[1:5], each = 5)
# #
# # funct = functional(args, values, ids)
# # print(funct)
# #'
# #' @export
# functional = function(args, values, ids) {
#   validate_functional(args, values, ids)
#   dt = data.table(arg = args, value = values, id = ids)
#   funct = dt[, .(x = list(list("arg" = arg, "value" = value))), "id"]$x
#   # we can have only one evaluation per function
#   # unique_sum = sum(dt[, .(count = uniqueN("arg")), by = "id"]$count)
#   # assert_true(unique_sum == length(args))
#
#   structure(class = c("functional", "list"), .Data = funct)
# }
#
# validate_functional = function(args, values, ids) {
#   assert_numeric(args)
#   assert_numeric(values)
#   assert_atomic(ids)
#   assert_true(length(args) == length(values))
#   assert_true(length(values) == length(ids))
# }
#
#
# #' @export
# `[.functional` = function(obj, ...) {
#   functional(unclass(obj)[...])
# }
#
# #' @export
# print.functional = function(x, ...) {
#   catf("<functional[%s]>", length(x))
#   invisible(x)
# }
#
# #' Converts object to class 'functional'
# #' @description
# #'   Convenience S3 generic that allows to construct vectors of class 'functional' from objects
# #'   types in which functional data is usually stored (e.g. `data.table()` or `matrix()`).
# #'
# #' @param x (any)
# #' @export
# as_functional = function(x, ...) {
#   UseMethod("as_functional", x)
# }
#
# #' @export
# as_functional.functional = function(x, ...) {
#   x
# }
#
# #' Convert a Matrix to a functional
# #' @description
# #'   Converts a matrix to a vector of class `functional`.
# #'   Rows contain various function evaluations for an individual.
# #' @param args (numeric())\cr
# #'   Arguments, such that $x_{i, j} = f_i(args_j)$.
# #'   Default =
# #'   1:ncol(x).
# #' @param ids (any)\cr
# #'   The ids, that assign labels to the rows of a matrix. Default is `1:nrow(x)`.
# #' @param args (`numeric()`)\cr
# #'   The arguments for the function evaluation. Default is `1:ncol(x)`.
# #' @param args (`numeric()`)
# #' @export
# as_functional.matrix = function(x, args = NULL, ids = NULL, ...) {
#   args = args %??% seq_len(ncol(x))
#   ids = ids %??% seq_len(nrow(x))
#   assert_true(length(args) == ncol(x))
#   assert_true(length(ids) == nrow(x))
#   ids = rep(ids, each = ncol(x))
#   args = rep(args, times = nrow(x))
#   x = c(x)
#   functional(args = args, values = x, ids = ids)
# }
#
#
# #' @export
# #' @method as_functional data.table
# as_functional.data.table = function(x, values, args, ids, ...) {
#   args = x[, args, with = FALSE][[1L]]
#   values = x[, values, with = FALSE][[1L]]
#   ids = x[, ids, with = FALSE][[1L]]
#   functional(args = args, values = values, ids = ids)
# }

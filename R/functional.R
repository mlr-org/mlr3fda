#' @title Creates an object of class 'functional'
#' @description
#' Creates an object of class functional.
#' @param args (`numeric`)
#' @param value (`numeric()`)
#'
#' export
functional = function(args, values, ids) {
  # TODO: allow more than numeric
  assert_numeric(args)
  assert_numeric(values)
  assert_true(length(args) == length(values))
  dt = data.table(arg = args, value = values, id = ids)

  funct = dt[, .(x = list(list("arg" = arg, "value" = value))), "id"]$x

  structure(class = c("functional", "list"),
    .Data = funct
  )
}

#' @export
`[.functional` = function(obj, ...) {
  functional(unclass(obj)[...])
}

#' @export
print.functional = function(x, ...) {
  catf("<functional[%s]>", length(x))
  for (pair in x) {
    # TODO: ints
    catf(" [(%.3f, %.3f), ...]", pair$arg[[1L]], pair$value[[1L]])
  }
  invisible(x)
}

#' @export
as_functional = function(x, ...) {
  UseMethod("as_functional", x)
}

as_functional.functional = function(x, ...) {
  x
}

#' @export
as_functional.matrix = function(x, args = NULL, ids = NULL, ...) {
  ids = ids %??% rownames(x) %??% seq_len(nrow(x))
  args = args %??% colnames(x) %??% seq_len(ncol(x))
  x = c(x)
  functional(args = args, values = x, ids = ids)
}


#' @export
as_functional.data.table = function(x, value, arg, id, ...) {
  args = x[, arg, with = FALSE][[1L]]
  values = x[, value, with = FALSE][[1L]]
  ids = x[, id, with = FALSE][[1L]]
  functional(args = args, values = values, ids = ids)
}

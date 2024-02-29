#' @export
hash_input.tfd_reg = function(x) {
  # The evaluator is a function with environment, srcref, and bytecde, which we want to ignore
  attr(x, "evaluator") = hash_input(attr(x, "evaluator"))
  x
}

#' @export
hash_input.tfd_irreg = function(x) {
  # The evaluator is a function with environment, srcref, and bytecde, which we want to ignore
  attr(x, "evaluator") = hash_input(attr(x, "evaluator"))
  x
}

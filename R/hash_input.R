#' @export
hash_input.tfd = function(x) {
  # The evaluator is a function with environment, srcref, and bytecde, which we want to ignore
  attr(x, "evaluator") = hash_input(attr(x, "evaluator"))
  x
}

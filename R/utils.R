# We need this to avoid name clashes in PipeOpFFE
uniqueify = function(name, existing, count = 0L) {
  # Special case that covers 99.99 % of the cases in the PipeOp above
  if ((count == 0L) && name %nin% existing) {
    return(name)
  }

  if (count == 100L) {
    stopf("Choose a better name.")
  }

  count_inc = count + 1L
  alternative = sprintf("%s_%s", name, count_inc)
  if (alternative %nin% existing) {
    return(alternative)
  } else {
    uniqueify(name, existing, count_inc)
  }

}

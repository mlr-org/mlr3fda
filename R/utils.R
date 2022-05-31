uniqueify_once = function(name, existing, count = 0L) {
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
    uniqueify_once(name, existing, count_inc)
  }
}

# We need this to avoid name clashes in PipeOpFFS
uniqueify = function(names, existing) {
  names_unique = character(length(names))
  for (i in seq_along(names)) {
    name = names[[i]]
    name_unique = uniqueify_once(name, existing)
    existing = c(existing, name_unique)
    names_unique[[i]] = name_unique
  }
  return(names_unique)
}

extract_params = function(extractors) {
  nms = names(extractors)
  assert_names(nms, type = "strict")
  param_set = ps()
  imap(
    extractors,
    function(extractor, name) {
      imap(
        formals(extractor),
        function(value, arg) {
          p = ParamUty$new(id = paste0(name, ".", arg), default = value, tags = c("train", "predict"))
          param_set$add(p)
        }
      )
    }
  )
  param_set
}

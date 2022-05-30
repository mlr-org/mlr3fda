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

# make_feature_names = function(new, existing) {
#   feature_names = map(cols,
#     function(x) {
#       map_chr(names(extractors),
#         function(y) {
#           sprintf("%s.%s", x, y)
#         }
#       )
#     }
#   )
#
#   feature_names = simplify2array(feature_names)
#   if (length(cols) == 1L) {
#     feature_names = matrix(feature_names, ncol = 1L)
#   }
#   if (length(extractors) == 1) {
#     feature_names = matrix(feature_names, nrow = 1L)
#   }
#   if (length(feature_names) == 1) {
#     feature_names = as.matrix(feature_names)
#   }
#
#   for (i in seq_along(feature_names)) {
#     other_names = c(feature_names[-i], cols)
#     feature_names[[i]] = uniqueify(feature_names[[i]], c(other_names))
#   }
#
# }
#
# # create feature names and then create the unique values
# feature_names = map(cols,
#   function(x) {
#     map_chr(names(extractors),
#       function(y) {
#         sprintf("%s.%s", x, y)
#       }
#     )
#   }
# )
# # unlist because the case where we calculate only 1 feature returns a list of length 1,
# # wich does
#
# # there are edge cases, namely when we have 1 feature or one column
# # that we have to deal with,
#
# feature_names = simplify2array(feature_names)
# if (length(cols) == 1L) {
#   feature_names = matrix(feature_names, ncol = 1L)
# }
# if (length(extractors) == 1) {
#   feature_names = matrix(feature_names, nrow = 1L)
# }
# if (length(feature_names) == 1) {
#   feature_names = as.matrix(feature_names)
# }
#
# for (i in seq_along(feature_names)) {
#   other_names = c(feature_names[-i], cols)
#   feature_names[[i]] = uniqueify(feature_names[[i]], c(other_names))
# }

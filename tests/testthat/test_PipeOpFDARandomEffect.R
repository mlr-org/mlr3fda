test_that("PipeOpFDARandomEffect - basic properties", {
  pop = po("fda.randomeffect")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.randomeffect")
})

test_that("PipeOpFDARandomEffect works", {
  # tf_reg works
  task = tsk("dti")
  arg_list = tf::tf_arg(task$data()$cca)
  idx_reggrid = seq_len(task$nrow)[sapply(arg_list, function(x) identical(x, arg_list[[1]]))]
  task = tsk("dti")$select("cca")$filter(idx_reggrid)
  
  po_fre = po("fda.randomeffect", drop = TRUE)
  task_fre = train_pipeop(po_fre, list(task))[[1L]]
  expect_set_equal(task_fre$feature_names, c("cca_random_intercept", "cca_random_slope"))
  
  # drop = FALSE
  po_fre = po("fda.randomeffect", drop = FALSE)
  task_fre = train_pipeop(po_fre, list(task))[[1L]]
  expect_set_equal(task_fre$feature_names, c("cca", "cca_random_intercept", "cca_random_slope"))
  
  # failed to converge, returns a warning 
  task = tsk("fuel")$select("NIR")
  po_fre = po("fda.randomeffect", drop = TRUE)
  expect_warning(train_pipeop(po_fre, list(task))[[1L]])

  # tf_irreg works
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob"),
    arg = c(1, 7, 2, 3, 5),
    value = c(1, 2, 3, 4, 5)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  y = c(1, 2)
  dt = data.table(f = f, y = y)
  task = as_task_regr(dt, target = "y")

  po_fre = po("fda.randomeffect", drop = TRUE)
  task_fre = train_pipeop(po_fre, list(task))[[1L]]
  expect_set_equal(task_fre$feature_names, c("f_random_intercept", "f_random_slope"))
  
  # drop = FALSE 
  po_fre = po("fda.randomeffect", drop = FALSE)
  task_fre = train_pipeop(po_fre, list(task))[[1L]]
  expect_set_equal(task_fre$feature_names, c("f", "f_random_intercept", "f_random_slope"))
  
  # re returns NA if no data in interval 
  po_fre = po("fda.randomeffect", drop = TRUE, left = 100, right = 200)
  task_fre = train_pipeop(po_fre, list(task))[[1L]]
  expect_set_equal(task_fre$feature_names, c("f_random_intercept", "f_random_slope"))
  fre = task_fre$data()[, c('f_random_intercept', "f_random_slope")]
  expect_true(all(is.na(unlist(fre))))
  
  # NAs for subjects with no data and random effects where values are present
  task = tsk("dti")$select(c("cca", "rcst"))
  po_fre = po("fda.randomeffect", drop = TRUE, left = 0.1, right = 0.2)
  task_fre = train_pipeop(po_fre, list(task))[[1L]]
  expect_set_equal(task_fre$feature_names, as.vector(outer(task$feature_names, c("random_intercept", "random_slope"), paste, sep = '_')))
  expect_true(all(is.na(task_fre$data()[3, c("rcst_random_intercept", "rcst_random_slope")])))
  
  # singular solution 
  dt = data.table(
    id = c("Ann", "Ann", "Ann", "Bob", "Bob", "Bob"),
    arg = rep(1:3, 2L),
    value = c(1,1,1,-1,-1,-1)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  y = c(1, 1)
  dt = data.table(f = f, y = y)
  
  task = as_task_regr(dt, target = "y")
  po_fre = po("fda.randomeffect", drop = TRUE)
  expect_message(train_pipeop(po_fre, list(task))[[1L]])
})

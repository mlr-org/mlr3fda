test_that("PipeOpFDAInterpol - basic properties", {
  pop = po("fda.interpol")
  expect_pipeop(pop)
  expect_identical(pop$id, "fda.interpol")
})

test_that("PipeOpFDAInterpol input validation works", {
  expect_error(po("fda.interpol", grid = c("union", "intersect")))
  expect_error(po("fda.interpol", grid = "unionh"))
  expect_error(po("fda.interpol", grid = list(1L)))
  expect_error(po("fda.interpol", grid = logical(1L)))
  expect_error(po("fda.interpol", grid = factor(1L)))
  expect_error(po("fda.interpol", grid = numeric(0L)))
  expect_error(po("fda.interpol", grid = 1:3, method = c("linear", "spline")))
  expect_error(po("fda.interpol", grid = 1:3, method = "cube"))
  task = tsk("fuel")
  pop = po("fda.interpol", grid = 1:3, left = 1, right = 2)
  expect_error(train_pipeop(pop, list(task)))
  pop = po("fda.interpol", grid = 10L, left = 2, right = 1)
  expect_error(train_pipeop(pop, list(task)))
  pop = po("fda.interpol", grid = 10L, left = 2)
  expect_error(
    train_pipeop(pop, list(task)),
    "Either both or none of 'left' and 'right' must be specified."
  )
  pop = po("fda.interpol", grid = 10L, right = 2)
  expect_error(
    train_pipeop(pop, list(task)),
    "Either both or none of 'left' and 'right' must be specified."
  )
})

test_that("PipeOpFDAInterpol extrapolation works", {
  # extrapolate with fill_extend method
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(NA, 2, 5, 5, 7, 3, 5, 10, 2, NA)
  )
  dt_in = data.table(y = 1:2, f = tf::tfd(dt, id = "id", arg = "arg", value = "value"))
  task = as_task_regr(dt_in, target = "y")
  pop = po("fda.interpol", grid = 1:5, method = "fill_extend")
  actual = train_pipeop(pop, list(task))[[1L]]$data()
  setnafill(dt, fill = 2L)
  expected = data.table(y = 1:2, f = tf::tfd(dt, id = "id", arg = "arg", value = "value"))
  expect_equal(actual, expected, ignore_attr = TRUE)
  # throw warning if extrapolation is not possible
  pop = po("fda.interpol", grid = 1:5)
  expect_warning(train_pipeop(pop, list(task)))
})

test_that("PipeOpFDAInterpol works with minmax", {
  # tfr doesnt't have an effect
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, 2, 5, 5, 7, 3, 5, 10, 2, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = "minmax")
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  expect_equal(task_interpol$data(), dt)

  # tfi works with same min and max
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, NA, 5, 5, 7, 3, 5, 10, NA, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = "minmax")
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, 3, 5, 5, 7, 3, 5, 10, 11, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)

  # tfi works with different min and max
  dt = data.table(
    id = c(rep(1L, 3L), rep(2L, 6L)),
    arg = c(3:5, 1:6),
    value = c(2, 5, 6, 1, 3, 4, 5, 6, 7)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = "minmax")
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(3:5, 2L),
    value = c(2, 5, 6, 4, 5, 6)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)
})

test_that("PipeOpFDAInterpol works with intersect", {
  # tfr works
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, 2, 5, 5, 7, 3, 5, 10, 2, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = "intersect")
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  expect_equal(task_interpol$data(), dt)

  # tfi works with same min and max
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, NA, 5, 5, 7, 3, 5, 10, NA, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = "intersect")
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(c(1, 3, 5), 2L),
    value = c(1, 5, 7, 3, 10, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)

  # tfi works with different min and max
  dt = data.table(
    id = c(rep(1L, 3L), rep(2L, 6L)),
    arg = c(3:5, 1:6),
    value = c(2, 5, 6, 1, 3, 4, 5, 6, 7)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = "intersect")
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(3:5, 2L),
    value = c(2, 5, 6, 4, 5, 6)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)
})

test_that("PipeOpFDAInterpol works with union", {
  # tfr works
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, 2, 5, 5, 7, 3, 5, 10, 2, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = "union")
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  expect_equal(task_interpol$data(), dt)

  # works with default
  pop = po("fda.interpol")
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  expect_equal(task_interpol$data(), dt)

  # tfi works with same min and max
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, NA, 5, 5, 7, 3, 5, 10, NA, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = "union")
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, 3, 5, 5, 7, 3, 5, 10, 11, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)

  # tfi works with different min and max
  dt = data.table(
    id = c(rep(1L, 3L), rep(2L, 6L)),
    arg = c(3:5, 1:6),
    value = c(2, NA, 5, 1, 3, 4, 5, 6, 7)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = "union")
  expect_warning(task_interpol <- train_pipeop(pop, list(task))[[1L]])
  dt = data.table(
    id = c(rep(1L, 3L), rep(2L, 6L)),
    arg = c(3:5, 1:6),
    value = c(2, 3.5, 5, 1, 3, 4, 5, 6, 7)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)
})

test_that("PipeOpFDAInterpol works with custom grid", {
  # tfr works
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, 2, 5, 5, 7, 3, 5, 10, 2, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = 3:5)
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(3:5, 2L),
    value = c(5, 5, 7, 10, 2, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)

  # outside of range
  pop = po("fda.interpol", grid = 3:7)
  expect_error(train_pipeop(pop, list(task)), "The grid must be within the range of the domain.")
  pop = po("fda.interpol", grid = -1:3)
  expect_error(train_pipeop(pop, list(task)), "The grid must be within the range of the domain.")

  # tfi works with same min and max
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, NA, 5, 5, 7, 3, 5, 10, NA, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = 3:5)
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(3:5, 2L),
    value = c(5, 5, 7, 10, 11, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)

  # tfi works with different min and max
  dt = data.table(
    id = c(rep(1L, 3L), rep(2L, 6L)),
    arg = c(3:5, 1:6),
    value = c(2, 5, 6, 1, 3, 4, 5, 6, 7)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = 3:5)
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(3:5, 2L),
    value = c(2, 5, 6, 4, 5, 6)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)
})

test_that("PipeOpFDAInterpol works with grid length + left and right", {
  # tfr works with integer output grid
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, 2, 5, 5, 7, 3, 5, 10, 2, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = 3L, left = 2, right = 4)
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(2:4, 2L),
    value = c(2, 5, 5, 5, 10, 2)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)

  # tfr works with numeric output grid
  dt = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, 2, 5, 5, 7, 3, 5, 10, 2, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = 3L, left = 2, right = 5)
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(c(2, 3.5, 5), 2L),
    value = c(2, 5, 7, 5, 6, 12)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)

  # tfi works
  dt = data.table(
    id = c(rep(1L, 3L), rep(2L, 6L)),
    arg = c(3:5, 1:6),
    value = c(2, 5, 6, 1, 3, 4, 5, 6, 7)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  dt = data.table(y = 1:2, f = f)
  task = as_task_regr(dt, target = "y")
  pop = po("fda.interpol", grid = 3L, left = 3, right = 5)
  task_interpol = train_pipeop(pop, list(task))[[1L]]
  dt = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(3:5, 2L),
    value = c(2, 5, 6, 4, 5, 6)
  )
  f = tf::tfd(dt, id = "id", arg = "arg", value = "value")
  expected = data.table(y = 1:2, f = f)
  expect_equal(task_interpol$data(), expected)
})

test_that("PipeOpFDAInterpol method arg works", {
  dt_in = data.table(
    id = rep(1:2, each = 5L),
    arg = rep(1:5, 2L),
    value = c(1, 2, 5, 5, 7, 3, 5, 10, 2, 12)
  )
  dt_out = data.table(
    id = rep(1:2, each = 3L),
    arg = rep(3:5, 2L),
    value = c(5, 5, 7, 10, 2, 12)
  )
  methods = c("linear", "spline", "fill_extend", "locf", "nocb")
  walk(methods, function(method) {
    f = tf::tfd(dt_in, id = "id", arg = "arg", value = "value")
    dt = data.table(y = 1:2, f = f)
    task = as_task_regr(dt, target = "y")
    pop = po("fda.interpol", grid = 3:5, method = method)
    task_interpol = train_pipeop(pop, list(task))[[1L]]

    evaluator = paste0("tf_approx_", method)
    f = do.call(tf::tfd, list(data = dt_out, id = "id", arg = "arg", value = "value", evaluator = evaluator))
    expected = data.table(y = 1:2, f = f)
    expect_equal(task_interpol$data(), expected)
  })
})

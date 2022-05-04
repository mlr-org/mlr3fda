load_task_fuel = function(id = "fuel") {
  x = load_dataset("fuel", package = "mlr3fda")
  b = as_data_backend(x)

  TaskRegr$new(
    id = id,
    backend = b,
    target = "heatan"
  )
}

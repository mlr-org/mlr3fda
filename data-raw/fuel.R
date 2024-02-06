task = mlr::fuelsubset.task
fuel = task$env$data

usethis::use_data(fuel, overwrite = TRUE)

task = mlr::fuelsubset.task
dat = task$env$data

usethis::use_data(dat, overwrite = TRUE)

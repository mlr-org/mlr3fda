library(data.table)
library(tf)

task = mlr::phoneme.task
dat = task$env$data

m = as.matrix(dat[, -151L])
X = as.tfd(tfd(m))


phoneme = data.table(
  class = dat$classlearn,
  X = X
)

usethis::use_data(phoneme, overwrite = TRUE)

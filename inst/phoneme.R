library(data.table)
library(tf)

task = mlr::phoneme.task
dat = task$env$data

m = as.matrix(dat[, -151])
X = as.tfd(tfd(m))


phoneme = data.table(
  class = dat$classlearn,
  X = X
)

save(file = system.file("data", "phoneme.rda", package = "mlr3fda"), phoneme)

load(file = system.file("data", "phoneme.rda", package = "mlr3fda"))

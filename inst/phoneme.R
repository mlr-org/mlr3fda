library(data.table)
library(tf)

task = mlr::phoneme.task
dat = task$env$data

m = as.matrix(dat[, -151])
X = as.tfd_irreg(tfd(m))


phoneme = data.table(
  class = dat$classlearn,
  X = X
)


save(file = "~/mlr/mlr3fda/data/phoneme.rda", phoneme)

load(file = "~/mlr/mlr3fda/data/phoneme.rda")






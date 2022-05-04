library(data.table)
task = mlr::phoneme.task
dat = task$env$data

dat[[1]]
dat[[2]]
dat[[4]]

m = as.matrix(dat[, -151])
funct = as_functional(m)

ids_nir = rep(1:129, each = 231)
ids_uvvis = rep(1:129, each = 134)

args_nir = rep(1:231, times = 129)
args_uvvis = rep(1:134, times = 129)

UVVIS = as_functional(dat[["UVVIS"]], args = args_uvvis, ids = ids_uvvis)
NIR = as_functional(dat[["NIR"]], args = args_nir, ids = ids_nir)
f2 = as_functional(dat[[4]])

phoneme = data.table(
  class = dat$classlearn,
  X = funct
)


save(file = "~/mlr/mlr3fda/data/phoneme.rda", phoneme)

load(file = "~/mlr/mlr3fda/data/phoneme.rda")






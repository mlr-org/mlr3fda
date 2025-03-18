library(data.table)

fn1 = function(dt) {
  dt[, names(.SD) := lapply(.SD, \(x) x**2)]
}

fn2 = function(dt) {
  for (j in seq_along(dt)) {
    set(dt, j = j, value = dt[[j]]**2)
  }
  dt
}

fn3 = function(dt) {
  mlr3misc::map_dtc(dt, \(x) x**2)
}

fn4 = function(dt) {
  mlr3misc::iwalk(dt, function(x, nm) {
    set(dt, j = nm, value = x ** 2)
  })
}

dt = data.table(x = rnorm(1e5), y = rnorm(1e5))
dt2 = copy(dt)
dt3 = copy(dt)
dt4 = copy(dt)
bench::mark(fn1(dt), fn2(dt2), fn3(dt3))

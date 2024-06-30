library(mlr3)
library(checkmate)
library(mlr3misc)
library(mlr3pipelines)
library(R6)
library(paradox)

walk(list.files(system.file("testthat", package = "mlr3"), pattern = "^helper.*\\.[rR]", full.names = TRUE), source)
# filter out helper_compat.R for weird reason to overload testthat functions to v2 behavior
map_if(list.files(system.file("testthat", package = "mlr3pipelines"), pattern = "^helper.*\\.[rR]", full.names = TRUE), function(x) !endsWith(x, "helper_compat.R"), source)

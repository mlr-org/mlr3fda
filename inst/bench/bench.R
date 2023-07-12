library(data.table)
library(mlr3fda)
library(mlr3pipelines)

set.seed(1234)
setDTthreads(threads = 1)

generate_data <- function(n_patients = 100,
                          n_weeks = 10,
                          type = c("reg", "irreg")) {
  type <- match.arg(type)
  if (type == "reg") {
    week <- 1:n_weeks
  }
  lapply(paste0("patient_", seq(1, n_patients)), function(patient_id) {
    if (type == "irreg") {
      week <- sample(n_weeks, sample(n_weeks, 1), replace = FALSE)
      n_weeks <- length(week)
    }
    gender <- sample(c("Male", "Female"), 1)
    tibble::tibble(
      patient_id = patient_id,
      week = week,
      systolic_bp = rnorm(n_weeks, 120, 15),
      diastolic_bp = rnorm(n_weeks, 80, 10),
      heart_rate = rnorm(n_weeks, 70, 10),
      age = sample(20:90, n_weeks, replace = TRUE),
      gender = rep(gender, n_weeks),
      recovery_rate = systolic_bp * 0.3 + diastolic_bp * 0.4 + heart_rate * 0.2
    )
  }) |>
    dplyr::bind_rows() |>
    dplyr::arrange(patient_id, week)
}

analyse_dplyr <- function(patients, window_start, window_end) {
  patients |>
    dplyr::filter(between(week, window_start, window_end)) |>
    dplyr::group_by(patient_id, measurement_type) |>
    dplyr::summarise(
      mean = mean(measurement_value),
      var = var(measurement_value),
      slope = coef(lm(measurement_value ~ week))[[2]],
      .groups = "drop"
    )
}

analyse_dt <- function(patients, window_start, window_end) {
  patients[between(week, window_start, window_end), .(
    mean = mean(measurement_value),
    var = var(measurement_value),
    slope = coef(lm(measurement_value ~ week))[[2]]
  ), keyby = .(patient_id, measurement_type)]
}

build_graph <- function(left = -Inf, right = Inf) {
  po_fmean <- po("ffs",
    feature = "mean",
    id = "mean",
    drop = FALSE,
    left = left,
    right = right
  )
  po_fvar <- po("ffs",
    feature = "var",
    id = "var",
    drop = FALSE,
    left = left,
    right = right
  )
  po_fslope <- po("ffs",
    feature = "slope",
    id = "slope",
    drop = FALSE,
    left = left,
    right = right
  )
  po_fmean %>>%
    po_fvar %>>%
    po_fslope
}

analyse_fda <- function(graph, task) {
  graph$train(task)
}

results <- bench::press(
  type = c("reg", "irreg"),
  n_weeks = c(10, 50, 100),
  n_patients = c(10, 100, 1000),
  {
    window_start <- floor(n_weeks * 0.2)
    window_end <- floor(n_weeks * 0.8)

    patients <- generate_data(
      n_patients = n_patients, n_weeks = n_weeks, type = type
    )
    patients_long <- patients |>
      tidyr::pivot_longer(
        cols = systolic_bp:heart_rate,
        names_to = "measurement_type",
        values_to = "measurement_value"
      )
    patients_dt <- as.data.table(patients_long)

    patients_tf <- patients |>
      dplyr::select(-c(age, gender, recovery_rate)) |>
      tidyfun::tf_nest(systolic_bp:heart_rate, .id = "patient_id", .arg = "week")
    patients_tf$y <- rnorm(nrow(patients_tf), 0, 1)
    task <- as_task_regr(patients_tf, target = "y", id = "patients")
    graph <- build_graph(left = window_start, right = window_end)

    bench::mark(
      dplyr = analyse_dplyr(patients_long, window_start, window_end),
      data_table = analyse_dt(patients_dt, window_start, window_end),
      mlr3fda = analyse_fda(graph, task),
      min_iterations = 100,
      check = FALSE
    )
  }
)
dti = refund::DTI
dti = dti[, c("ID", "pasat", "cca", "rcst", "sex")]

usethis::use_data(dti, overwrite = TRUE)

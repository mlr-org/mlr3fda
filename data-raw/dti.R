library(data.table)
library(tf)

dti = data.table(
  subject_id = as.factor(refund::DTI$ID),
  pasat = refund::DTI$pasat,
  cca = tfd(refund::DTI$cca, arg = seq(0L, 1L, length.out = 93L)),
  rcst = tfd(refund::DTI$rcst, arg = seq(0L, 1L, length.out = 55L)),
  sex = refund::DTI$sex
)
dti = na.omit(dti)

usethis::use_data(dti, overwrite = TRUE)

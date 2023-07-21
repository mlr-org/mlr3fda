library(data.table)
library(tf)

dti = data.table(
  id = as.factor(refund::DTI$ID),
  pasat = refund::DTI$pasat,
  cca = tfd(refund::DTI$cca, arg = seq(0,1, l = 93)),
  rcst = tfd(refund::DTI$rcst, arg = seq(0, 1, l = 55)),
  sex = refund::DTI$sex,
  case = factor(ifelse(refund::DTI$case, "MS", "control"))
)
dti = na.omit(dti)

usethis::use_data(dti, overwrite = TRUE)

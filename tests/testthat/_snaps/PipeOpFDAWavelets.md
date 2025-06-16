# PipeOpFDAWavelets input validation validation

    Code
      po("fda.wavelets", filter = "la4")
    Condition
      Error in `self$assert()`:
      ! Assertion on 'xs' failed: filter: Must be element of set {'d2','d4','d6','d8','d10','d12','d14','d16','d18','d20','la8','la10','la12','la14','la16','la18','la20','bl14','bl18','bl20','c6','c12','c18','c24','c30','haar'}, but is 'la4'.

---

    Code
      po("fda.wavelets", filter = "invalid_filter")
    Condition
      Error in `self$assert()`:
      ! Assertion on 'xs' failed: filter: Must be element of set {'d2','d4','d6','d8','d10','d12','d14','d16','d18','d20','la8','la10','la12','la14','la16','la18','la20','bl14','bl18','bl20','c6','c12','c18','c24','c30','haar'}, but is 'invalid_filter'.

---

    Code
      po("fda.wavelets", filter = c(1, 2, 3))
    Condition
      Error in `self$assert()`:
      ! Assertion on 'xs' failed: filter: Must be either a string, an even numeric vector or wavelet filter object.

---

    Code
      po("fda.wavelets", filter = list("la8"))
    Condition
      Error in `self$assert()`:
      ! Assertion on 'xs' failed: filter: Must be either a string, an even numeric vector or wavelet filter object.


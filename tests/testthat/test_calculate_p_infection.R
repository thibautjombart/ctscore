test_that(
  "calculate_p_infection() gives correct results", 
  {
    ## a single value should be unchanged
    expect_identical(calculate_p_infection(0.123), 0.123)

    ## example with 3 values
    p <- c(0.1, 0.2, 0.5)
    res <- calculate_p_infection(p)
    expect_equal(res[1], p[1])
    expect_equal(res[2], p[2]*(1-p[1]))
    expect_equal(res[3], p[3]*(1-p[2])*(1-p[1]))
  }
)

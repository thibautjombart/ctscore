test_that(
  "process_incub() issues correct errors", 
  {
    msg <- "'x' should be a numeric vector or a distcrete object"
    expect_error(process_incub("jndsf"), msg)
    
    msg <- "'x' should be non-negative"
    expect_error(process_incub(c(0, 0.2, -2)), msg)
    
  }
)




test_that(
  "process_incub() gives expected results", 
  {
    ## basic test for rescaling
    x <- c(1, 2, 3)
    expect_equal(process_incub(x), x/sum(x))
    
    ## test going over max_length
    x <- rep(1, 20)
    res <- process_incub(x, max_delay = 12)
    expect_equal(length(res), 13L)
    expect_equal(res, rep(1/13, 13))  
  
    ## check distcrete objects work
    x <- distcrete::distcrete("norm", mean = 12, sd = 10, interval = 1L)
    res <- process_incub(x, max_delay = 21)
    expect_equal(sum(res), 1L)
    expect_true(all(res >= 0))
  }
)
    
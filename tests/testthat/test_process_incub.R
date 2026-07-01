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
    res <- process_incub(x)
    expect_true(inherits(res, "function"))
    expect_equal(res(0:2), x/sum(x))
    
    ## test that out-of-range values are set to 0
    expect_equal(res(-1), 0)
    expect_equal(res(3), 0)
    
    ## check distcrete objects work
    x <- distcrete::distcrete("exp", rate = 2, interval = 1L)
    res <- process_incub(x)
    expect_true(inherits(res, "function"))
    expect_equal(sum(res(0:100)), 1L)
    expect_true(all(res(0) >= 0))
  }
)



test_that(
  "process_incub() gives identical results with numeric or distcrete input", 
  {
    incub_1 <- distcrete::distcrete("exp", rate = 2.6548, interval = 1L)
    incub_2 <- incub$d(0:100)
    
    res_1 <- process_incub(incub_1)
    res_2 <- process_incub(incub_2)
    
    ## we test results with numerics and difftimes
    expect_equal(res_1(0:30), res_2(0:30))
    dates <- Sys.Date() + 0:30
    expect_equal(res_1(Sys.Date() - dates), res_2(Sys.Date() - dates))
    
  }
)
    
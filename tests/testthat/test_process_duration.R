test_that(
  "process_duration() issues correct errors", 
  {
    msg <- "'x' must be a single value"
    expect_error(process_duration(c(1, 2)), msg)
    
    msg <- "'x' must be numeric"
    expect_error(process_duration("a"), msg)
    
    msg <- "'x' must be finite"
    expect_error(process_duration(Inf), msg)
    
    msg <- "'x' must be strictly positive"
    expect_error(process_duration(0, strictly_positive = TRUE), msg)
    
    msg <- "'x' must be positive"
    expect_error(process_duration(-1), msg)
  }
)

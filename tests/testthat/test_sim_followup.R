test_that(
  "sim_followup() issues correct errors", 
  {
    x <- sim_ctdata(5)
    
    msg <- "x must be a ctdata object"
    expect_error(sim_followup("lkjdsf"), msg)
    
    msg <- "is.numeric\\(duration\\) is not TRUE"
    expect_error(sim_followup(x, duration = NA), msg)
    
    msg <- "is.finite\\(duration\\) is not TRUE"
    expect_error(sim_followup(x, duration = Inf), msg)
    
    msg <- "duration > 0 is not TRUE"
    expect_error(sim_followup(x, duration = 0), msg)
    
    msg <- "is.numeric\\(coverage\\) is not TRUE"
    expect_error(sim_followup(x, coverage = NULL), msg)
    
    msg <- "is.finite\\(coverage\\) is not TRUE"
    expect_error(sim_followup(x, coverage = Inf), msg)
    
    msg <- "coverage >= 0 is not TRUE"
    expect_error(sim_followup(x, coverage = -3), msg)
    
    msg <- "coverage <= 1 is not TRUE"
    expect_error(sim_followup(x, coverage = 1.123), msg)
    
  }
)

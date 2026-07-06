test_that(
  "sim_followup() issues correct errors", 
  {
    
    msg <- "x must be a ctdata object"
    expect_error(sim_followup("lkjdsf"), msg)
    
  }
)
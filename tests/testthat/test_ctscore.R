test_that(
  "ctscore issues correct errors", 
  {
    msg <- "'x' should be a ctdata object as returned by make_ctdata\\(\\)"
    expect_error(ctscore("pmspodf"), msg)
    
    x <- make_ctdata(
      contact_id = integer(0), 
      date = integer(0), 
      type = character(0), 
      location = character(0)
    )
    msg <- "x' has 0 row; at least one data entry is required"
    expect_error(ctscore(x), msg)
      
  }
)

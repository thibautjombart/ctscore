test_that(
  "ctscore issues correct errors", 
  {
    msg <- "'x' should be a ctdata object as returned by make_ctdata\\(\\)"
    expect_error(ctscore("pmspodf"), msg)
      
    msg <- "'incub' should be a numeric vector or a distcrete object"
    expect_error(
      ctscore(make_ctdata(contact_id = 1, date = Sys.Date()), incub = "pmspodf"), 
      msg
    )
    
  }
)




test_that(
  "ctscore gives expected results", 
  {
    ## We first make a ctdata object
    ## 
    ## 'null' exposure is used as a sanity check to ensure that the function
    ## correctly handles zero probabilities of infection
    ## We also make an incubation time distribution with zero mass at day 1,
    ## where the score should be zero.
    x <- make_ctdata(
      contact_id = c(1, 1, 2, 3, 4), 
      date = Sys.Date() - c(6, 4, 5, 1, 5),
      type = c("normal", "funeral", "normal", "normal", "null"),
      location = "some-town",
      infection_proba = list(normal = 0.2, funeral = 0.9, null = 0),
      last_visit = Sys.Date() - c(4, 4, 1, 1, 3)
    )
    ## Incub gives the pmf of the incubation time from time 0 to length(incub) -
    ## 1
   # incub <- c(0, 0, 1, 2, 4, 3, 2, 1)
    
   # res <- ctscore(x, incub)
  }
)
test_that(
  "extract_indiv_data() issues correct errors", 
  {
    msg <- "'x' should be a ctdata object"
    expect_error(extract_indiv_data("jnsk"), msg)
  }
)



test_that(
  "extract_indiv_data() gives expected results",
  {
    ## test the function with a regular ctdata() object
    x <- make_ctdata(
      contact_id = c(1, 1, 2, 3, 3), 
      date = Sys.Date() - c(6, 4, 2, 2, 3),
      type = c("normal", "funeral", "normal", "normal", "funeral"),
      location = c("some-town", "some-town", "some-town", "sincity", "sincity"),
      infection_proba = list(normal = 0.2, funeral = 0.9),
      last_visit = Sys.Date() - c(4, 4, 1, NA, NA)
    )
    
    res <- extract_indiv_data(x)
    
    expect_equal(nrow(res), length(unique(x$contact_id)))
    expect_equal(ncol(res), ncol(x) - 3) # date, type and p_infection are removed
    expect_equal(names(res), c("contact_id", "location", "last_visit"))
  
  
  ## test function with a ctdata() object containing scores (returned by ctscore())
  scores <- ctscore(x, 
                    incub = c(0, 0, 1, 2, 4, 3, 2, 1), 
                    current_date = Sys.Date(), 
                    out_type = "ctdata_full"
                    )
  res <- extract_indiv_data(scores)
  expect_equal(nrow(res), length(unique(scores$contact_id)))
  expect_equal(ncol(res), ncol(scores) - 3) # date, type and p_infection are removed
  expect_equal(names(res), c("contact_id", "location", "last_visit", "score"))
  
  }
)

test_that(
  "Constructor issues correct errors", 
  {
    msg <- 'argument "contact_id" is missing, with no default'
    expect_error(make_ctdata(), msg)
    
    msg <- 'argument "date" is missing, with no default'
    expect_error(make_ctdata(contact_id = 1), msg)
      
  }
)




test_that(
  "Constructor works with basic input", 
  {
  res <- make_ctdata(contact_id = "toto", date = Sys.Date())
  expect_identical(
    dim(res),
    c(1L, 5L)
  )
  expect_identical(
    names(res),
    c("contact_id", "date", "type", "location", "p_infection")
  )
  
  expect_true(inherits(res, "ctdata"))
  expect_true(inherits(res, "data.frame"))
  
  }
)




test_that(
  "Constructor does basic input processing",
  {
    id <- 1:3
    date <- Sys.Date() + 1:3
    type <- c("normal", "normal", "funeral")
    location <- factor("town")
    date_txt <- as.character(date)
    res <- make_ctdata(
      contact_id = id, 
      date = date_txt, 
      type = type, 
      location = location, 
      infection_proba = list(normal = 0.1, funeral = 0.5)
    )
    
    expect_true(inherits(res, "ctdata"))
    expect_true(inherits(res, "data.frame"))
    expect_identical(res$contact_id, id)
    expect_identical(res$date, date)
    expect_identical(res$type, type)
    expect_identical(res$location, rep("town", 3))
    
  } 
)

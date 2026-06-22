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
  "Constructor does basic input processing and reordering",
  {
    id <- c(1, 1, 2)
    date <- as.Date("2026-06-19") - 1:3
    type <- c("normal", "funeral", "funeral")
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
    expect_identical(res$date, as.Date(c("2026-06-17", "2026-06-18", "2026-06-16")))
    expect_identical(res$type, c("funeral", "normal", "funeral"))
    expect_identical(res$location, rep("town", 3))
    expect_equal(res$p_infection, c(0.5, 0.1, 0.5))
  
  } 
)

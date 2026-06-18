test_that(
  "Constructor issues correct errors", 
  {
    msg <- 'argument "contact_id" is missing, with no default'
    expect_error(make_ctdata(), msg)
    
    
  }
)

test_that(
  "Constructor works with basic input", 
  {
  res <- make_ctdata(contact_id = "toto", date = Sys.Date())
  expect_identical(
    dim(res),
    c(1L, 4L)
  )
  expect_identical(
    names(res),
    c("contact_id", "date", "type", "group")
  )        
  }
)
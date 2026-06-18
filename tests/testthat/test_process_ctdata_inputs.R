test_that(
  "process_contact_id() works as expected", 
  {
    msg <- 'inherits\\(x, c\\("character", "numeric"\\)\\) is not TRUE'
    expect_error(process_contact_id(NULL), msg)
    
    expect_identical(
      process_contact_id("lksd"),
      "lksd"
    )
    
    expect_identical(
      process_contact_id("letters"),
      "letters"
    )
  }
)



test_that(
  "process_date() works as expected", 
  {
    msg <- 'inherits\\(x, c\\("Date", "numeric", "integer"\\)\\) is not TRUE'
    expect_error(process_date(NULL), msg)
    
    expect_identical(
      process_date(1:3),
      1:3
    )
    
    some_dates <- Sys.Date() - 1:3
    expect_identical(
      process_date(some_dates),
      some_dates
    )
    expect_identical(
      process_date(as.character(some_dates)),
      some_dates
    )
    
  }
)

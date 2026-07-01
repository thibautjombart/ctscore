test_that(
  "process_contact_id() works as expected", 
  {
    msg <- 'inherits\\(x, c\\("character", "numeric", "integer"\\)\\) is not TRUE'
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
    
    msg <- "Dates cannot be NA"
    expect_error(process_date(NA_real_), msg)
    
    msg <- "Dates cannot be NA"
    expect_error(process_date(c(1, NA, 2), msg))
    
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
    expect_identical(
      process_date(c(1, NA, 3), na_ok = TRUE),
      c(1, NA, 3)
    )
    
  }
)



test_that(
  "process_type() works as expected", 
  {
    expect_identical(
      process_type(1:3),
      as.character(1:3)
    )
    
    expect_identical(
      process_type(c("normal", "funeral")),
      c("normal", "funeral")
    )
    
    
    expect_identical(
      process_type(factor(c("normal", "funeral"))),
      c("normal", "funeral")
    )
  }
)




test_that(
  "process_location() works as expected", 
  {
    expect_identical(
      process_location(1:3),
      as.character(1:3)
    )
    
    expect_identical(
      process_location(c("town", "village")),
      c("town", "village")
    )
    
    expect_identical(
      process_location(factor(c("town", "village"))),
      c("town", "village")
    )
  }
)



test_that(
  "process_infection_proba() works as expected", 
  {
    x <- data.frame(
      contact_id = 1:3,
      date = Sys.Date() - 3:1,
      type = c("normal", "normal", "funeral"),
      location = c("town", "town", "village")
    )
    
    msg <- "Names of infection_proba must be identical to the types in the ctdata object"
    expect_error(
      process_infection_proba(list("1" = 0.5, "3" = 0.8), x),
      msg
    )
  
    msg <- "All elements of infection_proba must be numeric"
    expect_error(
      process_infection_proba(list("normal" = "0.5", funeral = "toto"), x),
      msg
    )
    
    msg <- "All elements of infection_proba must be probabilities \\(between 0 and 1\\)"
    expect_error(
      process_infection_proba(list("normal" = 1.5, funeral = -0.2), x),
      msg
    )
      
    proba <- list("normal" = 0.5, "funeral" = 0.8)
    res <- process_infection_proba(
      proba, 
      x
    )
    expect_identical(
      res,
      proba
    )
    
  }
)
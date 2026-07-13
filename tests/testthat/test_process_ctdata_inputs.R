test_that(
  "process_contact_id() works as expected", 
  {
   
    expect_identical(
      process_contact_id("lksd"),
      "lksd"
    )
    
    expect_identical(
      process_contact_id(1:10),
      as.character(1:10)
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

test_that("process_infected() enforces a logical vector", {
  expect_identical(process_infected(c(TRUE, FALSE, NA)), c(TRUE, FALSE, NA))
  expect_identical(process_infected(NA), NA)                 # logical NA ok

  msg <- "'infected' must be a logical vector"
  expect_error(process_infected(c(0, 1)), msg)
  expect_error(process_infected("TRUE"), msg)
  expect_error(process_infected(factor("yes")), msg)
})


test_that("process_onset_infected() enforces onset => infected", {
  ## consistent combinations pass
  expect_true(process_onset_infected(onset = c(NA, NA), infected = c(TRUE, FALSE)))
  expect_true(process_onset_infected(c(10, NA), c(TRUE, FALSE)))  
  expect_true(process_onset_infected(NA, TRUE))

  ## onset present without confirmed infection fails, and reports the rows
  msg <- "onset implies infected = TRUE"
  expect_error(process_onset_infected(c(NA, 5), c(TRUE, FALSE)), msg)  # FALSE
  expect_error(process_onset_infected(5, NA), msg)                     # unknown status
  expect_error(process_onset_infected(c(1, 2), c(FALSE, FALSE)), "1, 2")
})


test_that("process_extra_columns() validates optional inputs", {
  expect_identical(process_extra_columns(list(), n_rows = 3), list())

  d <- list(vaccinated = TRUE, age = c(10, 20, 30))          # length 1 and length n both ok
  expect_identical(process_extra_columns(d, n_rows = 3), d)

  expect_error(process_extra_columns(list(1), n_rows = 3), "must be named")
  expect_error(process_extra_columns(setNames(list(1, 2), c("a", "")), n_rows = 3), "must be named")
  expect_error(process_extra_columns(setNames(list(1, 2), c("a", "a")), n_rows = 3), "must be unique")
  expect_error(process_extra_columns(list(score = 1), n_rows = 3), "clash with reserved")
  expect_error(process_extra_columns(list(detection_date = 1), n_rows = 3), "clash with reserved")
  expect_error(process_extra_columns(list(foo = c(1, 2)), n_rows = 3), "must be length 1 or 3")
})
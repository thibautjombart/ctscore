x <- data.frame(
  contact_id = letters[1:5], 
  date = sample(1:10, 5),
  type = rep(c("regular", "high_risk"), c(2,3)),
  location = "whatever"
)
class(x) <- c("ctdata", "data.frame")


test_that(
  "add_infection_proba() issues the correct errors",
  {
  
    msg <- "Names of infection_proba must be identical to the types in the ctdata object"
    expect_error(
      add_infection_proba(x, list()),
      msg
    )
    
    msg <- "All elements of infection_proba must be probabilities \\(between 0 and 1\\)"
    expect_error(
      add_infection_proba(x, list(regular = 0.1, high_risk = 1.2)),
      msg
    )
  }
)



test_that(
  "add_infection_proba() returns expected results",
  {
    ## basic processing of the list of proba
    proba <- list(regular = 0.2, high_risk = 0.95)
    res <- add_infection_proba(x, proba)
    expect_equal(
      res$infection_proba, 
      rep(c(0.2, 0.95), c(2,3))
    )
    
    ## changing probas of an existing object
    res <- add_infection_proba(x, list(regular = 0.1, high_risk = 0.25))
    expect_equal(
      res$infection_proba, 
      rep(c(0.1, 0.25), c(2,3))
    )
    
    ## adjust to changes in types
    x$type[4] <- "low_risk"
    res <- add_infection_proba(
      x, 
      list(regular = 0.1, high_risk = 0.25, low_risk = 0.01)
    )
    expect_equal(
      res$infection_proba, 
      c(0.1, 0.1, 0.25, 0.01, 0.25)
    )
    
  }
)
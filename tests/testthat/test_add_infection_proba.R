## a small ctdata object: contacts a-e, one exposure each, two exposure types
x <- make_ctdata(
  exposures = tibble::tibble(
    contact_id    = letters[1:5],
    date          = 1:5,
    exposure_type = rep(c("regular", "high_risk"), c(2, 3))
  ),
  infection_proba = list(regular = 0, high_risk = 0)
)


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
    ## one row per exposure type, ordered by type, exposures left untouched
    proba <- list(regular = 0.2, high_risk = 0.95)
    res <- add_infection_proba(x, proba)
    expect_identical(
      res$risk,
      tibble::tibble(
        exposure_type = c("high_risk", "regular"),
        infection_proba = c(0.95, 0.2)
      )
    )
    expect_identical(res$exposures, x$exposures)

    ## changing probas of an existing object
    res <- add_infection_proba(x, list(regular = 0.1, high_risk = 0.25))
    expect_identical(res$risk$infection_proba, c(0.25, 0.1))

    ## adjust to changes in types
    x$exposures$exposure_type[4] <- "low_risk"
    res <- add_infection_proba(
      x,
      list(regular = 0.1, high_risk = 0.25, low_risk = 0.01)
    )
    expect_identical(
      res$risk,
      tibble::tibble(
        exposure_type = c("high_risk", "low_risk", "regular"),
        infection_proba = c(0.25, 0.01, 0.1)
      )
    )
  }
)

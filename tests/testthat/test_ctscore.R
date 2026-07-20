## helper: the shared ctdata used across several tests
make_x <- function() {
  make_ctdata(
    exposures = tibble::tibble(
      contact_id = c(1, 1, 2, 3, 4),
      date       = Sys.Date() - c(6, 4, 5, 1, 5),
      type       = c("normal", "funeral", "normal", "normal", "null")
    ),
    linelist = tibble::tibble(
      contact_id = c(1, 2, 3, 4),
      last_visit_date = Sys.Date() - c(2, 1, 1, 3)
    ),
    infection_proba = list(normal = 0.2, funeral = 0.9, null = 0)
  )
}


test_that(
  "ctscore issues correct errors",
  {
    msg <- "'x' should be a ctdata object as returned by make_ctdata\\(\\)"
    expect_error(ctscore("pmspodf"), msg)

    x <- make_ctdata(
      exposures = tibble::tibble(contact_id = 1, date = Sys.Date(), type = "default")
    )
    msg <- "'x' should be a numeric vector or a distcrete object"
    expect_error(ctscore(x, incub = "pmspodf"), msg)
  }
)


test_that(
  "ctscore gives expected results",
  {
    ## 'null' exposure is a sanity check for zero probability of infection.
    ## incub has zero mass at day 1, where the score should be zero.
    x <- make_x()

    ## incub gives the pmf of the incubation time from day 0 to length(incub) - 1
    incub <- c(0, 0, 1, 2, 4, 3, 2, 1)

    res <- ctscore(x, incub)

    ## dimensions, names etc.
    expect_equal(length(res), 4)
    expect_equal(names(res), as.character(1:4))

    ## contact 1: a non-trivial positive value
    ## contact 2: a positive value
    ## contact 3: 0 because exposure is too recent
    ## contact 4: 0 because null exposure
    expect_true(res[1] > 0)
    expect_true(res[2] > 0)
    expect_equal(unname(res[3]), 0)
    expect_equal(unname(res[4]), 0)
  }
)


test_that(
  "ctscore gives identical results for distcrete and numeric incubation",
  {
    x <- make_x()

    incub <- distcrete::distcrete("gamma", interval = 1, shape = 2, scale = 2.5, w = 0)
    incub_num <- incub$d(0:1000)
    res_1 <- ctscore(x, incub_num)
    res_2 <- ctscore(x, incub)
    expect_equal(res_1, res_2)
  }
)


test_that(
  "ctscore() handles NA in last_visit_date correctly",
  {
    incub <- distcrete::distcrete("gamma", interval = 1, shape = 2, scale = 2.5, w = 0)

    x_1 <- make_ctdata(
      exposures = tibble::tibble(
        contact_id = c("a", "a", "b", "c", "d"),
        date       = Sys.Date() - c(6, 4, 5, 1, 5),
        type       = c("normal", "funeral", "normal", "normal", "null")
      ),
      linelist = tibble::tibble(
        contact_id = c("a", "b", "c", "d"),
        last_visit_date = Sys.Date() - c(4, NA, NA, NA)
      ),
      infection_proba = list(normal = 0.2, funeral = 0.9, null = 0)
    )

    ## a very old last_visit_date is equivalent to never having been seen
    x_2 <- x_1
    x_2$linelist$last_visit_date[2:4] <- as.Date("2000-12-02")

    expect_identical(
      ctscore(x_1, incub),
      ctscore(x_2, incub)
    )
  }
)


test_that(
  "add_ctscore() appends scores to the linelist",
  {
    x <- make_x()

    incub <- distcrete::distcrete(
      "gamma",
      interval = 1, shape = 3.123, scale = 2.5, w = 0
    )

    score <- ctscore(x, incub)
    expect_true(is.numeric(score))

    res <- add_ctscore(x, score)
    expect_s3_class(res, "ctdata")
    expect_identical(names(res), c("linelist", "exposures"))
    expect_true("score" %in% names(res$linelist))
    expect_identical(res$exposures, x$exposures)

    ## score matched to the right contact
    expect_equal(
      res$linelist$score,
      unname(score[as.character(res$linelist$contact_id)])
    )
  }
)

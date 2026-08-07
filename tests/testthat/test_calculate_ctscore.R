## We generate toy data to calculate scores
w <- c(0, 0, 1, 2, 3, 2, 0.5)
incub <- process_incub(w)

test_that(
  "calculate_ctscore gives correct results",
  {
    x <- data.frame(
      date_exposure = c(0, 2, 3),
      p_exposure = c(0.1, 0.9, 0.1)
    )

    ## expect 0 because too early post first exposure
    res <- calculate_ctscore(
      p_inf = x$p_exposure,
      e = x$date_exposure,
      s = -1,
      t = 1,
      incub = incub
    )
    expect_equal(res, 0)

    ## expect score=p_inf because very late after exposures
    res <- calculate_ctscore(
      p_inf = x$p_exposure,
      e = x$date_exposure,
      s = -1,
      t = 100,
      incub = incub
    )
    expect_equal(res, sum(calculate_p_infection(x$p_exposure)))

    ## with a single exposure and no followup
    res <- calculate_ctscore(
      p_inf = 0.2,
      e = 0,
      s = -1,
      t = 5,
      incub = incub
    )
    expect_equal(res, 0.2 * sum(incub(0:5)))

    ## with a single exposure and some followup
    res <- calculate_ctscore(
      p_inf = 0.2,
      e = 0,
      s = 4,
      t = 5,
      incub = incub
    )
    expect_equal(res, 0.2 * sum(incub(5)) / sum(incub(5:10)))

    ## several exposures, no followup
    res <- calculate_ctscore(
      p_inf = x$p_exposure,
      e = x$date_exposure,
      s = -1,
      t = 4,
      incub = incub
    )
    p_inf <- c(0.1, 0.9 * 0.9, 0.1 * 0.9 * 0.1)
    p_symp <- c(sum(incub(0:4)), sum(incub(0:2)), sum(incub(0:1)))
    expect_equal(res, sum(p_inf * p_symp))

    ## several exposures, some followup
    res <- calculate_ctscore(
      p_inf = x$p_exposure,
      e = x$date_exposure,
      s = 3,
      t = 5,
      incub = incub
    )
    p_inf <- c(0.1, 0.9 * 0.9, 0.1 * 0.9 * 0.1)
    p_symp <- c(
      sum(incub(4:5)) / sum(incub(4:10)),
      sum(incub(2:3)) / sum(incub(2:10)),
      sum(incub(2)) / sum(incub(1:10))
    )
    expect_equal(res, sum(p_inf * p_symp))
  }
)


test_that(
  "calculate_ctscore() works when last_visit_date is NA",
  {
    res_1 <- calculate_ctscore(
      p_inf = c(0.1, 0.9, 0.1),
      e = c(0, 2, 3),
      s = NA,
      t = 4,
      incub = incub
    )

    res_2 <- calculate_ctscore(
      p_inf = c(0.1, 0.9, 0.1),
      e = c(0, 2, 3),
      s = -1,
      t = 4,
      incub = incub
    )

    expect_identical(res_1, res_2)
  }
)

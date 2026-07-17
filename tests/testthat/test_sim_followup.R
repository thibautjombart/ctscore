test_that(
  "sim_followup() issues correct errors",
  {
    x <- sim_ctdata(5)

    msg <- "x must be a ctdata object"
    expect_error(sim_followup("lkjdsf"), msg)


    msg <- "'time' must be numeric"
    expect_error(sim_followup(x, time = NA), msg)

    msg <- "'time' must be finite"
    expect_error(sim_followup(x, time = Inf), msg)

    msg <- "'time' must be strictly positive"
    expect_error(sim_followup(x, time = 0), msg)


    msg <- "'delay' must be numeric"
    expect_error(sim_followup(x, delay = NA), msg)

    msg <- "'delay' must be finite"
    expect_error(sim_followup(x, delay = Inf), msg)

    msg <- "'delay' must be strictly positive"
    expect_error(sim_followup(x, delay = 0), msg)


    msg <- "'duration' must be numeric"
    expect_error(sim_followup(x, duration = NA), msg)

    msg <- "'duration' must be finite"
    expect_error(sim_followup(x, duration = Inf), msg)

    msg <- "'duration' must be strictly positive"
    expect_error(sim_followup(x, duration = 0), msg)


    msg <- "'coverage' must be a single value"
    expect_error(sim_followup(x, coverage = NULL), msg)

    msg <- "'coverage' must be finite"
    expect_error(sim_followup(x, coverage = Inf), msg)

    msg <- "'coverage' must be >= 0"
    expect_error(sim_followup(x, coverage = -3), msg)

    msg <- "'coverage' must be <= 1"
    expect_error(sim_followup(x, coverage = 1.123), msg)
  }
)

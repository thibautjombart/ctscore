test_that(
  "process_proportion() issues correct errors",
  {
    msg <- "'x' must be a single value"
    expect_error(process_proportion(c(1, 2)), msg)

    msg <- "'x' must be numeric"
    expect_error(process_proportion("a"), msg)

    msg <- "'x' must be finite"
    expect_error(process_proportion(Inf), msg)

    msg <- "'x' must be >= 0"
    expect_error(process_proportion(-.0123), msg)

    msg <- "'x' must be <= 1"
    expect_error(process_proportion(1.0123), msg)
  }
)

test_that("random follow-up with coverage = 0 records nothing", {
  x <- sim_ctdata(10)
  y <- sim_followup(x, coverage = 0, strategy = "random")

  expect_true(all(is.na(y$last_visit)))
  expect_true(all(is.na(y$detection_date)))
})

test_that("random follow-up detects a symptomatic contact within its window", {
  ## contact A infected (onset day 12), contact B never infected; both exposed day 10
  x <- make_ctdata(
    contact_id = c("A", "B"),
    date       = c(10, 10),
    last_visit = c(NA_real_, NA_real_)
  )
  x$onset <- c(12, NA)

  ## coverage = 1 => everyone eligible visited every day
  y <- sim_followup(
    x,
    delay = 1,
    duration = 21,
    coverage = 1,
    strategy = "random"
  )
  a <- y[y$contact_id == "A", ]
  b <- y[y$contact_id == "B", ]

  ## A: window [11, 31]; seen asymptomatic on 11, detected on onset day 12
  expect_false(is.na(a$detection_date))
  expect_equal(a$detection_date, 12)
  expect_equal(a$last_visit, 11)

  ## B: never symptomatic; visited to end of window, never detected
  expect_true(is.na(b$detection_date))
  expect_equal(b$last_visit, 31)
})

#' Test sample proportion against expectation
#'
#' Checks whether the observed proportion in a binary vector is consistent
#' with a specified probability p using a normal approximation to the
#' binomial sampling distribution.
#'
#' Assumes independent Bernoulli trials and sufficiently large n.
#'
#' @param x Binary vector (0/1) of observed outcomes.
#' @param p True success probability under the data-generating process.
#' @param z Number of standard errors used as acceptance threshold.
expect_proportion <- function(x, p, z = 5) {
  n <- length(x)
  se <- sqrt(p * (1 - p) / n)
  expect_lt(abs(mean(x) - p), z * se)
}

#' Test sample mean against expectation
#'
#' Checks whether the observed sample mean is consistent with a specified
#' mean mu given a known variance sigma2, using a normal approximation to
#' the sampling distribution of the mean.
#'
#' Assumes independent observations, known variance, and sufficiently large n.
#'
#' @param x Numeric vector of observations.
#' @param mu True mean under the data-generating process.
#' @param sigma2 Known variance of the data-generating process.
#' @param z Number of standard errors used as acceptance threshold.
expect_mean <- function(x, mu, sigma2, z = 5) {
  n <- length(x)
  se <- sqrt(sigma2 / n)
  expect_lt(abs(mean(x) - mu), z * se)
}

# ------------------------------------
#           Tests
# ------------------------------------

test_that("each contact's timeline is internally consistent", {
  set.seed(1)
  sim <- simulate_ct(n_contacts = 2000)

  ## At least one contact is infected
  expect_true(any(sim$infected))

  ## the last symptom-free visit never lands after onset
  inf <- sim[sim$infected, ]
  expect_true(all(inf$date_onset >= inf$last_visit))

  ## the last visit is at or after every exposure (including the first one)
  expect_true(all(sim$last_visit >= sim$date))

  ## No infection when p_inf = 0
  sim <- simulate_ct(n_contacts = 2000, p_inf = list(default = 0))
  expect_false(all(sim$infected))
})

test_that("number of exposures matches the input distribution", {
  set.seed(1)
  n_exp <- 1L + rpois(1000L, 3)
  ## p_inf = 0 -> nobody infected -> no censoring -> every drawn exposure kept
  sim <- simulate_ct(
    n_contacts = 5000,
    n_exposures = n_exp,
    p_inf = list(default = 0)
  )
  per_contact <- as.numeric(table(sim$contact_id))
  expect_mean(per_contact, mean(n_exp), var(n_exp))
})

test_that("infection probability matches p_inf for each type", {
  set.seed(1)
  p <- list(low = 0.1, high = 0.9)
  ## one exposure per contact -> P(infected) is exactly that type's p_inf
  sim <- simulate_ct(n_contacts = 5000, n_exposures = 1L, p_inf = p)
  for (type in names(p)) {
    expect_proportion(sim$infected[sim$type == type], p[[type]])
  }
})

test_that("contacts are split across locations as specified", {
  set.seed(1)
  locs <- list(A = 0.5, B = 0.2, C = 0.2, D = 0.1)

  sim <- simulate_ct(
    n_contacts = 5000,
    n_exposures = 1L,
    p_inf = list(default = 0),
    locations = locs
  )
  shares <- unlist(locs)
  for (loc in names(locs)) {
    expect_proportion(sim$location == loc, shares[[loc]])
  }
})

test_that("follow-up coverage matches the input", {
  set.seed(1)
  cvg <- 0.7
  ## covered contacts get a visit after their exposure (last_visit > date);
  ## Using long window and delay 1 day so the visit is never censored
  sim <- simulate_ct(
    n_contacts = 5000,
    duration = 500,
    n_exposures = 1L,
    p_inf = list(default = 0),
    coverage = cvg,
    followup_delay = 1L
  )
  expect_proportion(sim$last_visit > sim$date, cvg)
})

test_that("follow-up delay matches the input distribution", {
  set.seed(1)
  delays <- 1 + rpois(1000L, 5)

  sim <- simulate_ct(
    n_contacts = 5000,
    duration = 500,
    n_exposures = 1L,
    p_inf = list(default = 0),
    coverage = 1,
    followup_delay = delays
  )
  expect_mean(sim$last_visit - sim$date, mean(delays), var(delays))
})

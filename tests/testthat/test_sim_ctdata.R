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

##########################
## Input validation:
##########################

test_that("sim_ctdata rejects invalid inputs", {
  ## naming conventions
  expect_error(sim_ctdata(infection_proba = list(0.1, b = 0.2)), "named lists")

  expect_error(
    sim_ctdata(
      locations = list(A = 1),
      n_exposures = list(A = 1, B = 1)
    ),
    "same names"
  )

  expect_error(
    sim_ctdata(
      infection_proba = list(a = 0.1, b = 0.2),
      type_proba = list(a = 1, c = 1)
    ),
    "same names"
  )

  ## values must be in range
  expect_error(sim_ctdata(infection_proba = list(default = 1.5)), "\\[0, 1\\]")

  expect_error(sim_ctdata(duration = 10, n_exposures = list(default = 20)), "between 1 and")
})

##########################
## Output validation:
##########################


test_that("infection status and onset are internally consistent", {
  set.seed(1)
  sim <- sim_ctdata(
    n_contacts = 2000,
    n_exposures = list(A = 3, B = 3),
    locations = list(A = 0.5, B = 0.5)
  )

  ## at least one contact is infected under the default probability
  expect_true(any(sim$infected))

  ## onset is recorded exactly for infected contacts
  expect_false(all(is.na(sim$onset[sim$infected])))
  expect_true(all(is.na(sim$onset[!sim$infected])))

  ## infected, onset and location are unique per contact_id
  one <- function(x) {
    length(unique(x)) == 1L
  }
  expect_true(all(tapply(sim$infected, sim$contact_id, one)))
  expect_true(all(tapply(sim$onset, sim$contact_id, one)))
  expect_true(all(tapply(sim$location, sim$contact_id, one)))

  ## infection_date follows the same NA pattern as onset
  expect_true(all(is.na(sim$infection_date[!sim$infected])))
  expect_false(all(is.na(sim$infection_date[sim$infected])))
  expect_true(all(tapply(sim$infection_date, sim$contact_id, one)))

  ## onset is on/after the infection date
  expect_true(all(sim$onset[sim$infected] >= sim$infection_date[sim$infected]))

  ## no infection (and no onset) when the probability is zero
  sim0 <- sim_ctdata(
    n_contacts = 2000,
    infection_proba = list(default = 0)
  )
  expect_false(any(sim0$infected))
  expect_true(all(is.na(sim0$onset)))
  expect_true(all(is.na(sim0$infection_date)))
})


test_that("type_proba are respected", {
  sim <- sim_ctdata(
    n_contacts = 200,
    infection_proba = list(a = 0.5, b = 0.5),
    type_proba = list(b = 0, a = 1)
  )
  expect_true(all(sim$type == "a"))
})


test_that("n_exposures are respected", {
  set.seed(1)
  n_exp <- 1L + rpois(5000, 3)
  ## exposures are never censored, so every drawn exposure yields one row
  sim <- sim_ctdata(
    n_contacts = 5000,
    duration = 50,
    n_exposures = list(default = n_exp),
    infection_proba = list(default = 0),
    locations = list(default = 1)
  )
  per_contact <- as.numeric(table(sim$contact_id))
  expect_mean(per_contact, mean(n_exp), var(n_exp))
})

test_that("infection_proba are respected", {
  set.seed(1)
  p <- list(low = 0.1, high = 0.9)
  ## one exposure per contact -> P(infected) is exactly that type's probability
  sim <- sim_ctdata(
    n_contacts = 5000,
    n_exposures = list(default = 1),
    infection_proba = p,
    locations = list(default = 1)
  )
  for (type in names(p)) {
    expect_proportion(sim$infected[sim$type == type], p[[type]])
  }
})

test_that("locations are respected", {
  set.seed(1)
  locs <- list(
    A = 0.5,
    B = 0.2,
    C = 0.2,
    D = 0.1
  )

  ## one exposure per location so every contact contributes a single row
  sim <- sim_ctdata(
    n_contacts = 5000,
    n_exposures = list(
      A = 1,
      B = 1,
      C = 1,
      D = 1
    ),
    infection_proba = list(default = 0),
    locations = locs
  )
  shares <- unlist(locs)
  for (loc in names(locs)) {
    expect_proportion(sim$location == loc, shares[[loc]])
  }
})

##########################
## Compatibility with ctscore():
##########################

test_that("sim_ctdata returns a ctdata usable by ctscore", {
  set.seed(1)
  n_contacts <- 50
  sim <- sim_ctdata(n_contacts = n_contacts)

  ## check class and required columns
  expect_s3_class(sim, "sim_ctdata")
  expect_s3_class(sim, "ctdata")
  expect_true(all(c("infection_proba", "infected", "infection_date", "onset") %in% names(sim)))


  sc <- ctscore(sim,
    incub = c(1, 2, 3, 4, 5, 6, 7),
    current_date = 31
  )
  expect_length(sc, n_contacts)
  expect_true(all(sc >= 0 & sc <= 1))
})

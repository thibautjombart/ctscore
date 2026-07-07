#' Simulate contact tracing data
#'
#' Simulate contact tracing data for a set of contacts. A contact has one or
#' more exposures, each with a probability of causing infection. Infected
#' contacts develop symptoms after an incubation period.
#'
#' @author Cyril Geismar
#'
#' @param n_contacts Number of contacts to simulate.
#' @param duration Length of the exposure period (days).
#' @param incub Integer vector of incubation periods (days), sampled with replacement.
#' @param locations Named list giving the probability of each location being assigned to a contact. Names must match `n_exposures`.
#' @param n_exposures Named list giving the number of exposures per contact for each location. Names must match `locations`.
#' @param infection_proba Named list giving the probability of infection for each exposure type. Names must match `type_weights`.
#' @param type_weights Named list giving the relative frequency of each exposure type. Names must match `infection_proba`. Defaults to uniform.
#'
#' @return An object of class `c("sim_ctdata", "ctdata", "data.frame")` with one
#'   row per exposure. It carries the standard `ctdata` columns (`contact_id`,
#'   `date`, `type`, `location`, `last_visit`, `p_infection`) plus the
#'   simulation truth `infected` (logical, per contact) and `onset` (symptom
#'   onset day, `NA` when not infected).
#'
#' @seealso [make_ctdata()] to create a `ctdata` object from real data.

#' @importFrom stats rbinom rgamma rpois runif
#'
#' @export
#'
#' @examples
#' x <- sim_ctdata(
#'  n_contacts = 10,
#' duration = 30,
#' incub = 1:7,
#' locations = list(cityA = 0.8, cityB = 0.2),
#' n_exposures = list(cityA = 2, cityB = 1 + rpois(n = 10, lambda = 5)),
#' infection_proba = list(household = 0.2, funeral = 0.4),
#' type_weights = list(household = 0.7, funeral = 0.3)
#' )
#' head(x)
#'

sim_ctdata <- function(
  n_contacts = 100,
  duration = 30,
  incub = 1:7,
  locations = list(default = 1),
  n_exposures = list(default = 1),
  infection_proba = list(default = 0.1),
  type_weights = NULL
) {
  ## ---- Input validation ----------------------------------------------------
  ## `locations`/`n_exposures` are keyed by location,
  ## `infection_proba`/ `type_weights` by exposure type
  is_named_list <- function(x) {
    is.list(x) && length(x) > 0L && !is.null(names(x)) && all(nzchar(names(x)))
  }

  if (
    !is_named_list(locations) ||
      !is_named_list(n_exposures) ||
      !is_named_list(infection_proba)
  ) {
    stop("`locations`, `n_exposures` and `infection_proba` must be named lists")
  }
  if (!setequal(names(locations), names(n_exposures))) {
    stop("`locations` and `n_exposures` must have the same names")
  }
  if (!is.null(type_weights)) {
    if (!is_named_list(type_weights)) {
      stop("`type_weights` must be a named list")
    }
    if (!setequal(names(infection_proba), names(type_weights))) {
      stop("`infection_proba` and `type_weights` must have the same names")
    }
  }

  ## Numeric ranges: guard against silent misuse and cryptic downstream errors.
  if (
    !is.numeric(n_contacts) ||
      length(n_contacts) != 1L ||
      n_contacts < 1 ||
      !is.numeric(duration) ||
      length(duration) != 1L ||
      duration < 1
  ) {
    stop("`n_contacts` and `duration` must each be a single positive integer")
  }
  if (!is.numeric(incub) || length(incub) < 1L || any(incub < 0)) {
    stop("`incub` must be a non-empty vector of non-negative integers")
  }
  if (any(unlist(infection_proba) < 0) || any(unlist(infection_proba) > 1)) {
    stop("`infection_proba` values must be probabilities in [0, 1]")
  }
  if (any(unlist(n_exposures) < 1) || any(unlist(n_exposures) > duration)) {
    stop("`n_exposures` values must be integers between 1 and `duration`")
  }

  ## sample(x, n) is unsafe: for a length-1 x it draws from seq_len(x), not x.
  ## So sample positions and index x — a length-1 x then returns x itself.

  resample <- function(x, n) x[sample.int(length(x), n, replace = TRUE)]

  dist <- list(
    incub = resample(incub, n_contacts),
    n_exposures = lapply(n_exposures, resample, n = n_contacts)
  )

  one_ct <- function(id) {
    l <- sample(names(locations), 1, prob = unlist(locations))
    k <- resample(dist$n_exposures[[l]], 1)
    te <- sort(sample(1:duration, k, replace = FALSE)) #only one exposure per day
    type <- sample(
      names(infection_proba),
      k,
      replace = TRUE,
      prob = if (is.null(type_weights)) {
        NULL
      } else {
        unlist(type_weights)[names(infection_proba)]
      }
    )
    pi_e <- calculate_p_infection(unlist(infection_proba[type]))

    # which exposure caused the infection, if any (NA = never infected)
    k_inf <- sample(c(seq_along(pi_e), NA), 1, prob = c(pi_e, 1 - sum(pi_e)))
    infected <- !is.na(k_inf)

    t_ons <- if (infected) te[k_inf] + dist$incub[id] else NA_real_

    data.frame(
      contact_id = id,
      date = te,
      type = type,
      location = l,
      last_visit = NA_real_,
      infected = infected,
      onset = t_ons,
      stringsAsFactors = FALSE
    )
  }

  ct <- do.call(rbind, lapply(seq_len(n_contacts), one_ct))

  out <- make_ctdata(
    contact_id = ct$contact_id,
    date = ct$date,
    type = ct$type,
    location = ct$location,
    infection_proba = infection_proba[unique(ct$type)],
    last_visit = ct$last_visit
  )

  ## Re-attach the latent truth dropped by make_ctdata().
  # `infected` and `onset` are constant within a contact, so they are matched back on contact_id.
  truth <- ct[!duplicated(ct$contact_id), c("contact_id", "infected", "onset")]
  i <- match(out$contact_id, truth$contact_id)
  out$infected <- truth$infected[i]
  out$onset <- truth$onset[i]

  class(out) <- c("sim_ctdata", class(out))
  out
}

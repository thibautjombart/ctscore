#' Simulate contact tracing data
#'
#' Simulate contact tracing data for a set of contacts. A contact has one or
#' more exposures, each with a probability of causing infection. Infected
#' contacts develop symptoms after an incubation period.
#'
#' @author Cyril Geismar
#'
#' @export
#'
#' @param n_contacts Number of contacts to simulate.
#'
#' @param duration Length of the exposure period (days).
#'
#' @param incub Integer vector of incubation periods (days), sampled with replacement.
#'
#' @param locations Named list giving the probability of each location being assigned to a contact.
#' Names must match `n_exposures`.
#'
#' @param n_exposures Named list giving the number of exposures per contact for each location.
#' Names must match `locations`.
#'
#' @param infection_proba Named list giving the probability of infection for each exposure type.
#' Names must match `type_proba`.
#'
#' @param type_proba Named list giving the relative probability of each exposure type. Names must match `infection_proba`. Defaults to uniform.
#'
#' @return An object of class `c("sim_ctdata", "ctdata", "data.frame")` with one
#'   row per exposure. Alongside the standard `ctdata` columns it carries the
#'   simulation ground truth, constant within each contact: `infected` (logical),
#'   `infection_date` (day of the infecting exposure, `NA` if not infected), and
#'   `onset` (= `infection_date` + incubation, `NA` if not infected).
#'
#' @seealso [make_ctdata()] to create a `ctdata` object from real data.
#'
#' @examples
#' x <- sim_ctdata(
#'   n_contacts = 10,
#'   duration = 30,
#'   incub = 1:7,
#'   locations = list(cityA = 0.8, cityB = 0.2),
#'   n_exposures = list(cityA = 2, cityB = c(2, 2, 3, 4, 5, 10)),
#'   infection_proba = list(household = 0.2, funeral = 0.4),
#'   type_proba = list(household = 0.7, funeral = 0.3)
#' )
#' head(x)
#' class(x)
sim_ctdata <- function(n_contacts = 100,
                       duration = 30,
                       incub = 1:7,
                       locations = list(default = 1),
                       n_exposures = list(default = 1),
                       infection_proba = list(default = 0.1),
                       type_proba = NULL) {
  ## Input validation
  ## `locations`/`n_exposures` are keyed by location,
  ## `infection_proba`/ `type_proba` by exposure type
  is_named_list <- function(x) {
    is.list(x) &&
      length(x) > 0L && !is.null(names(x)) && all(nzchar(names(x)))
  }

  if (!is_named_list(locations) ||
    !is_named_list(n_exposures) ||
    !is_named_list(infection_proba)) {
    stop("`locations`, `n_exposures` and `infection_proba` must be named lists")
  }
  if (!setequal(names(locations), names(n_exposures))) {
    stop("`locations` and `n_exposures` must have the same names")
  }
  if (!is.null(type_proba)) {
    if (!is_named_list(type_proba)) {
      stop("`type_proba` must be a named list")
    }
    if (!setequal(names(infection_proba), names(type_proba))) {
      stop("`infection_proba` and `type_proba` must have the same names")
    }
  }

  ## Check that numeric inputs are valid
  if (!is.numeric(n_contacts) ||
    length(n_contacts) != 1L ||
    n_contacts < 1 ||
    !is.numeric(duration) ||
    length(duration) != 1L ||
    duration < 1) {
    stop("`n_contacts` and `duration` must each be a single positive integer")
  }
  if (!is.numeric(incub) || length(incub) < 1L || any(incub < 0)) {
    stop("`incub` must be a non-empty vector of non-negative integers")
  }
  if (any(unlist(infection_proba) < 0) ||
    any(unlist(infection_proba) > 1)) {
    stop("`infection_proba` values must be probabilities in [0, 1]")
  }
  if (any(unlist(n_exposures) < 1) ||
    any(unlist(n_exposures) > duration)) {
    stop("`n_exposures` values must be integers between 1 and `duration`")
  }

  ## sample() behaves differently when x is a vector of length 1 vs >1.
  ## Sample indices instead, then subset x.
  resample <- function(x, n) {
    x[sample.int(length(x), n, replace = TRUE)]
  }

  dist <- list(
    incub = resample(incub, n_contacts),
    n_exposures = lapply(n_exposures, resample, n = n_contacts)
  )

  one_ct <- function(id) {
    l <- sample(names(locations), 1, prob = unlist(locations))
    k <- resample(dist$n_exposures[[l]], 1)
    te <- sort(sample(1:duration, k, replace = FALSE)) # only one exposure per day
    type <- sample(names(infection_proba),
      k,
      replace = TRUE,
      prob = if (is.null(type_proba)) {
        NULL
      } else {
        unlist(type_proba)[names(infection_proba)]
      }
    )
    pi_e <- calculate_p_infection(unlist(infection_proba[type]))

    ## Sample the exposure responsible for infection (NA = not infected)
    k_inf <- sample(c(seq_along(pi_e), NA), 1, prob = c(pi_e, 1 - sum(pi_e)))
    infected <- !is.na(k_inf)
    t_inf <- if (infected) te[k_inf] else NA_real_
    t_ons <- if (infected) te[k_inf] + dist$incub[id] else NA_real_

    data.frame(
      contact_id = id,
      date = te,
      type = type,
      location = l,
      last_visit = NA_real_,
      infected = infected,
      infection_date = t_inf,
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
    last_visit = ct$last_visit,
    infected = ct$infected,
    infection_date = ct$infection_date,
    onset = ct$onset
  )

  class(out) <- c("sim_ctdata", class(out))
  out
}

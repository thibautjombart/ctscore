#' Simulate contact tracing data
#'
#' Simulate contact tracing data for a set of contacts. Each contact has one or
#' more exposures, each with a probability of causing infection. Infected
#' contacts develop symptoms after an incubation period and are followed only
#' while symptom-free. Contacts are assigned to locations with location-specific
#' follow-up coverage. The output contains one row per observed exposure,
#' together with the true infection status and dates.
#'
#' @author Cyril Geismar
#'
#' @param n_contacts Number of contacts to simulate.
#' @param duration Length of the exposure period (days). Exposures occur on days
#'   `1:duration`.
#' @param n_exposures Integer vector giving the number of exposures per contact,
#'   sampled with replacement.
#' @param p_inf Named list giving the infection probability for each exposure
#'   type.
#' @param incub Integer vector of incubation periods (days), sampled with
#'   replacement.
#' @param locations Named list giving the proportion of contacts assigned to
#'   each location. If unnamed, contacts are distributed equally across
#'   locations.
#' @param coverage Follow-up probability. Either a single value for all
#'   locations or a named list of location-specific values.
#' @param followup_delay Integer vector of delays (days) from exposure to
#'   follow-up, sampled with replacement.
#'
#' @return A `sim_ctdata` `data.frame` with one row per observed exposure and
#'   columns `contact_id`, `date`, `type`, `location`, `last_visit`,
#'   `p_infection`, `infected`, `date_infection`, and `date_onset`.
#' @importFrom stats rbinom rgamma rpois runif
#'
#' @export
#'
#' @examples
#' sim <- simulate_ct(
#'   n_contacts = 50,
#'   p_inf = list(household = 0.2, funeral = 0.8)
#' )
#' head(sim)
#'
simulate_ct <- function(
  n_contacts = 100,
  duration = 30,
  n_exposures = 1L + rpois(1000L, 1),
  p_inf = list(default = 0.1),
  incub = 1L + rpois(1000L, 7),
  locations = list(default = 1),
  coverage = 0.8,
  followup_delay = 1L + rpois(1000L, 3)
) {
  proba <- unlist(p_inf)
  types <- names(p_inf)
  today <- duration + 1L

  dist <- list(
    incub = incub,
    n_exposures = n_exposures,
    followup_delay = followup_delay
  )
  for (nm in names(dist)) {
    x <- dist[[nm]]
    if (!is.numeric(x) || length(x) == 0L || anyNA(x) || any(x < 0)) {
      stop(
        sprintf(
          "`%s` must be a non-empty numeric vector of non-negative integer values.",
          nm
        ),
        call. = FALSE
      )
    }
  }

  incub <- sample(incub, n_contacts, replace = TRUE)
  n_exposures <- sample(n_exposures, n_contacts, replace = TRUE)
  followup_delay <- sample(followup_delay, n_contacts, replace = TRUE)

  ## locations: each value is a location's share of contacts (sums to 1).
  if (is.null(names(locations))) {
    loc_names <- unlist(locations)
    loc_prob <- rep(1, length(loc_names))
  } else {
    loc_names <- names(locations)
    loc_prob <- unlist(locations)
  }
  loc_prob <- loc_prob / sum(loc_prob)

  ## coverage: each value is a location's follow-up probability (each 0-1).
  cov <- if (is.null(names(coverage))) {
    rep(coverage, length(loc_names))
  } else {
    unlist(coverage)[loc_names]
  }
  names(cov) <- loc_names

  one_contact <- function(id) {
    k <- max(1L, n_exposures[id])
    exp_days <- sort(sample.int(duration, k, replace = TRUE))
    type <- sample(types, k, replace = TRUE)
    pi_e <- unname(proba[type])
    location <- sample(loc_names, 1, prob = loc_prob)

    ## infection (at most once): the first exposure that transmits
    k_inf <- match(1L, rbinom(k, size = 1, prob = pi_e)) #match(TRUE, runif(k) < pi_e)
    infected <- !is.na(k_inf)
    date_infection <- if (infected) exp_days[k_inf] else NA_real_

    date_onset <- if (infected) {
      date_infection + sample(incub, 1, replace = TRUE)
    } else {
      NA_real_
    }

    ## tracking stops at onset: a contact is followed only while symptom-free,
    ## so exposures on/after the onset date are dropped. The infecting exposure
    ## is always kept, so every contact retains at least one exposure.
    horizon <- if (infected) min(today, date_onset) else today
    keep <- exp_days < horizon
    if (infected) {
      keep[k_inf] <- TRUE
    }
    exp_days <- exp_days[keep]
    type <- type[keep]
    pi_e <- pi_e[keep]

    ## follow-up: one visit per retained exposure if the contact's is covered
    visits <- if (runif(1) < cov[[location]]) {
      # may need to add 1 day to avoid same-day visits?
      exp_days + sample(followup_delay, length(exp_days), replace = TRUE)
    } else {
      numeric()
    }
    ## last symptom-free observation: latest exposure-or-visit before the
    ## horizon, floored at the most recent exposure so that s >= every exposure
    seen <- c(exp_days, visits)
    last_visit <- max(seen[seen < horizon], max(exp_days))

    data.frame(
      contact_id = id,
      date = exp_days,
      type = type,
      location = location,
      last_visit = last_visit,
      p_infection = pi_e,
      infected = infected,
      date_infection = date_infection,
      date_onset = date_onset,
      stringsAsFactors = FALSE
    )
  }

  out <- do.call(rbind, lapply(seq_len(n_contacts), one_contact))
  class(out) <- c("sim_ctdata", "data.frame")
  attr(out, "today") <- today
  out
}

#' Simulate contact tracing data
#'
#' Simulate exposure events and contact tracing data for each contact.
#' Each contact gets one or more exposures (each of a type carrying an infection probability),
#' is infected at most once, and (if infected) develops symptoms after an incubation period
#' drawn from `incub`. A contact is tracked only while symptom-free, so any
#' exposures on or after the onset date are dropped. A coverage draw decides
#' whether the contact is followed up; `last_visit` is the last day they were
#' seen symptom-free.
#' The output is a `data.frame` with one row per exposure, including the truth columns
#' `infected`, `date_infection`, and `date_onset`.
#'
#' @author Cyril Geismar
#'
#' @param n_contacts number of contacts to simulate.
#' @param incub a `distcrete` object for the incubation period; delays are drawn
#'   with `incub$r()`.
#' @param p_inf named `list` mapping exposure type to its per-exposure
#'   infection probability in `[0, 1]`.
#' @param n_exposures exposures per contact: an integer, or a `function(n)`
#'   returning `n` counts. Defaults to `1 + Poisson(1)`.
#' @param duration length of the exposure window, in days; exposures fall on
#'   days `1:duration` and the analysis day (today) is `duration + 1`.
#' @param coverage probability in `[0, 1]` that a contact is followed up at all.
#' @param followup_delay mean number of days from an exposure to its visit.
#'
#' @return A `data.frame` of class `sim_ctdata`, one row per exposure, with
#'   columns `contact_id`, `date`, `type`, `last_visit`,
#'   `p_infection`, and the truth columns `infected`, `date_infection`,
#'   `date_onset`.
#'
#' @importFrom stats rpois runif
#'
#' @export
#'
#' @examples
#' \dontrun{
#' incub <- distcrete::distcrete("gamma", shape = 4, scale = 1.5, w = 0.5, interval = 1)
#' sim <- simulate_ct(
#'   n_contacts      = 100,
#'   incub           = incub,
#'   p_inf = list(household = 0.2, funeral = 0.8)
#' )
#' head(sim)
#' }
simulate_ct <- function(
  n_contacts = 100,
  incub,
  p_inf = list(default = 0.1),
  n_exposures = function(n) 1L + rpois(n, 1),
  duration = 30,
  coverage = 0.8,
  followup_delay = 3
) {
  proba <- unlist(p_inf)
  types <- names(p_inf)
  today <- duration + 1L
  n_exp <- n_exposures(n_contacts)

  one_contact <- function(id) {
    k <- max(1L, n_exp[id])
    exp_days <- sort(sample.int(duration, k, replace = TRUE))
    type <- sample(types, k, replace = TRUE)
    pi_e <- unname(proba[type])

    ## infection (at most once): the first exposure that transmits
    k_inf <- match(1L, rbinom(k, size = 1, prob = pi_e)) #match(TRUE, runif(k) < pi_e)
    infected <- !is.na(k_inf)
    date_infection <- if (infected) exp_days[k_inf] else NA_real_

    date_onset <- if (infected) date_infection + incub$r(1) else NA_real_

    ## tracking stops at onset: a contact is followed only while symptom-free,
    ## so exposures on/after the onset date are dropped. The infecting exposure
    ## is always kept (covers the rare incubation = 0 case where onset coincides
    ## with it), so every contact retains at least one exposure.
    horizon <- if (infected) min(today, date_onset) else today
    keep <- exp_days < horizon
    if (infected) {
      keep[k_inf] <- TRUE
    }
    exp_days <- exp_days[keep]
    type <- type[keep]
    pi_e <- pi_e[keep]

    ## follow-up: one visit per retained exposure if covered
    visits <- if (runif(1) < coverage) {
      exp_days + rpois(length(exp_days), followup_delay) # may need to add 1 day to avoid same-day visits, but this is not critical
    } else {
      numeric()
    }
    ## last symptom-free observation s: latest exposure-or-visit before the
    ## horizon, floored at the most recent exposure so that s >= every exposure
    seen <- c(exp_days, visits)
    last_visit <- max(seen[seen < horizon], max(exp_days))

    data.frame(
      contact_id = id,
      date = exp_days,
      type = type,
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
  out
}

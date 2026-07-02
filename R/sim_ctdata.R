#' Simulate contact tracing data
#'
#' Simulate contact tracing data for a set of contacts. Each contact has one or
#' more n_exposures, each with a probability of causing infection. Infected
#' contacts develop symptoms after an incubation period.
#'
#' @author Cyril Geismar
#'
#' @param n_contacts Number of contacts to simulate.
#' @param duration Length of the exposure period (days).
#' @param n_exposures Named list giving the number of exposures per contact for each location.
#' @param infection_proba Named list giving the probability of infection for each exposure type.
#' @param incub Integer vector of incubation periods (days), sampled with
#'   replacement.
#' @param locations Named list giving the probability of each location being sampled for a contact.
#'
#' @return An object of class `c("sim_ctdata", "ctdata", "data.frame")` with one
#'   row per exposure. It carries the standard `ctdata` columns (`contact_id`,
#'   `date`, `type`, `location`, `last_visit`, `p_infection`) plus the
#'   simulation truth `infected` (logical, per contact) and `onset` (symptom
#'   onset day, `NA` when not infected).
#'
#' @seealso [make_ctdata()], which builds the `ctdata` core, and [ctscore()].

#' @importFrom stats rbinom rgamma rpois runif
#'
#' @export
#'
#'

sim_ctdata <- function(
  n_contacts = 100,
  duration = 30,
  incub = 1:7,
  n_exposures = list(default = 1),
  infection_proba = list(default = 0.1),
  locations = list(default = 1)
) {
  dist <- list(
    incub = sample(incub, n_contacts, replace = TRUE),
    n_exposures = lapply(n_exposures, function(x) {
      sample(x, n_contacts, replace = TRUE)
    })
  )

  one_ct <- function(id) {
    l <- sample(names(locations), 1, prob = unlist(locations))
    k <- sample(dist$n_exposures[[l]], 1)
    te <- sort(sample(1:duration, k, replace = FALSE)) #only one exposure per day
    type <- sample(names(infection_proba), k, replace = TRUE)
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

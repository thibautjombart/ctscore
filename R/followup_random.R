is_eligible <- function(t, opens, closes, detected) {
  t >= opens & t <= closes & !detected
}

#' Random follow-up strategy for `sim_followup()` (internal)
#'
#' On each simulated day, a proportion `coverage` of the contacts currently
#' eligible for follow-up are visited at random. A visit records the contact as
#' seen without symptoms (updating `last_visit`), unless they have already
#' reached onset (`t >= onset`), in which case they are flagged `detected` and
#' leave follow-up.
#'
#'
#' @author Cyril Geismar
#'
#' @keywords internal
#' 
#' @noRd
#' 
#' @importFrom stats rbinom
#'
#' @param x a `ctdata` object
#'
#' @param coverage the expected proportion of contacts visited at any time step; defaults
#'   to 0 - no follow-up
#'
#' @param time an `integer` indicating the number of days to run the simulation
#'   for; starts from the most recent date in `x`, be it in follow-up
#'   history or in exposures; defaults to 1 day @thibautjombart NOT USING IT CURRENTLY
#'
#' @param delay an `integer` the minimum delay for follow-up to start, after the
#'   first exposure of the concerned contact; defaults to 1 - visit can start
#'   the day after the first exposure
#'
#' @param duration an `integer` indicating the number of days after the last
#'   exposure a contact should be followed for; usually determined according to
#'   the incubation time distribution; defaults to 21 days
#'
#' @return `x` with columns `last_visit`, `detected` and `detection_date` updated according to the follow-up strategy.
#'
#' @seealso [sim_ctdata()] and [sim_followup()] to simulate contact tracing data and follow-up strategies
#'
#' @details
#' A contact is considered eligible for followup when the current time step `t` lies between:
#' - `opens` = first exposure + `delay`
#' - `closes` = last exposure + `duration`
#'

`_followup_random` <- function(x, time, delay, duration, coverage) {
  ## one row per contact, each with its own follow-up window:
  ##   opens  = first exposure + delay
  ##   closes = last exposure + duration
  first_exp <- tapply(x$date, x$contact_id, min)
  last_exp <- tapply(x$date, x$contact_id, max)
  ct <- data.frame(
    contact_id = names(first_exp),
    opens = as.integer(first_exp) + delay,
    closes = as.integer(last_exp) + duration,
    onset = x$onset[match(names(first_exp), x$contact_id)],
    ## @thibautjombart do we use the last_visit from x?
    last_visit = NA_real_,
    #as.integer(x$last_visit[match(names(first_exp), x$contact_id)]),
    detected = FALSE,
    detection_date = NA_real_,
    stringsAsFactors = FALSE
  )
  
  ## daily loop over the whole follow-up period: earliest opening -> latest closing
  for (t in seq.int(min(ct$opens), max(ct$closes))) {
    ## find eligible contacts
    eligible <- which(is_eligible(t, ct$opens, ct$closes, ct$detected))
    if (length(eligible) == 0L) {
      next
    }
    
    ## how many contacts visited today
    n_visited <- rbinom(1L, length(eligible), coverage)
    if (n_visited == 0L) {
      next
    }
    
    ## who is visited (random)
    visited <- eligible[sample.int(length(eligible), n_visited)]
    
    ## update: symptomatic at the visit -> detected; otherwise seen asymptomatic
    symptomatic <- !is.na(ct$onset[visited]) &
      t >= ct$onset[visited]
    ct$detected[visited[symptomatic]] <- TRUE
    ct$detection_date[visited[symptomatic]] <- t
    ct$last_visit[visited[!symptomatic]] <- t
  }
  
  ## write per-contact follow-up history back onto the exposure rows
  i <- match(x$contact_id, ct$contact_id)
  x$last_visit <- ct$last_visit[i]
  x$detected <- ct$detected[i]
  x$detection_date <- ct$detection_date[i]
  x
}

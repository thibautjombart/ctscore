#' Calculate contact tracing score
#'
#' This function calculates the probability of detecting symptoms in a contact
#' on a given day given their exposure and follow-up history, as described in
#' Jombart et al. 2026.
#'
#' @author Thibaut Jombart
#' @export
#'
#' @param x a `ctdata` object as returned by [make_ctdata()]
#'
#' @param incub the incubation period distribution; can be provided as a vector
#'   of probabilities giving p(0 day), p(1 day), p(2 days) ... or as a
#'   `distcrete` object as returned by distcrete::distcrete()
#'
#' @param current_date the current date, provided either as a `numeric` value or
#'   as a `Date`; defaults to the current date as returned by `Sys.Date()`
#'
#' @return A named numeric vector giving the probability of detecting symptoms
#'   for each contact, named by contact ID. Use [add_ctscore()] to attach these
#'   scores to the `linelist` of the source `ctdata`.
#'
#' @seealso [add_ctscore()] to attach the scores back onto the `ctdata`.
#'
#' @examples
#' x <- make_ctdata(
#'   exposures = tibble::tibble(
#'     contact_id = c(1, 1, 2, 3, 4),
#'     date       = Sys.Date() - c(6, 4, 5, 1, 5),
#'     type       = c("normal", "funeral", "normal", "normal", "null")
#'   ),
#'   linelist = tibble::tibble(
#'     contact_id = c(1, 2, 3, 4),
#'     last_visit = Sys.Date() - c(2, 1, 1, 3)
#'   ),
#'   infection_proba = list(normal = 0.2, funeral = 0.9, null = 0)
#' )
#'
#' ## incubation time PMF from day 0 to 7
#' incub <- c(0, 0, 1, 2, 4, 3, 2, 1)
#'
#' ## a named vector of scores
#' score <- ctscore(x, incub)
#' score
#'
#' ## attach the scores to the ctdata linelist
#' add_ctscore(x, score)
#'
#' ## incubation as a distcrete object
#' incub <- distcrete::distcrete("gamma", interval = 1, shape = 2, scale = 2.5, w = 0)
#' ctscore(x, incub)
ctscore <- function(x,
                    incub,
                    current_date = Sys.Date()) {
  if (!inherits(x, "ctdata")) {
    stop("'x' should be a ctdata object as returned by make_ctdata()",
      call. = FALSE
    )
  }
  incub <- process_incub(incub)

  ## date of last asymptomatic visit, keyed by contact_id (one row per contact)
  last_visit <- x$linelist$last_visit
  names(last_visit) <- x$linelist$contact_id

  ## score each contact from its exposures (dates ascending within a contact)
  by_contact <- split(x$exposures, x$exposures$contact_id)
  vapply(names(by_contact), function(id) {
    e <- by_contact[[id]]
    calculate_ctscore(
      p_inf = e$infection_proba,
      e = e$date,
      s = last_visit[[id]],
      t = current_date,
      incub = incub
    )
  }, numeric(1))
}


#' Attach ctscores to a ctdata linelist
#'
#' Adds the per-contact scores returned by [ctscore()] as a `score` column of the
#' `ctdata`'s `linelist`, matched by `contact_id`.
#'
#' @param x the `ctdata` object to which the scores should be added
#' @param score a named numeric vector of scores as returned by [ctscore()]
#'
#' @return The `ctdata` object `x`, with a `score` column added to its
#'   `linelist`.
#'
#' @seealso [ctscore()]
#'
#' @export
add_ctscore <- function(x, score) {
  x$linelist$score <- unname(score[as.character(x$linelist$contact_id)])
  x
}

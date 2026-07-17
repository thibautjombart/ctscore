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
#' @param out_type a `character` indicating the type of output to return:
#'   "vector" (default) returns a named numeric vector of scores; "data.frame"
#'   returns a tibble with `contact_id` and `score`; "ctdata" returns the input
#'   `ctdata` object with a `score` column added to its `linelist`.
#'
#' @return By default (`out_type = "vector"`) a named numeric vector giving the
#'   probability of detecting symptoms for each contact, named by contact ID.
#'   See `out_type` for the other shapes.
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
#' ## default: a named vector of scores
#' ctscore(x, incub)
#'
#' ## other shapes
#' ctscore(x, incub, out_type = "data.frame")
#' ctscore(x, incub, out_type = "ctdata")
#'
#' ## incubation as a distcrete object
#' incub <- distcrete::distcrete("gamma", interval = 1, shape = 2, scale = 2.5, w = 0)
#' ctscore(x, incub)
ctscore <- function(x,
                    incub,
                    current_date = Sys.Date(),
                    out_type = c("vector", "data.frame", "ctdata")) {
  if (!inherits(x, "ctdata")) {
    stop("'x' should be a ctdata object as returned by make_ctdata()",
      call. = FALSE
    )
  }
  incub <- process_incub(incub)
  out_type <- match.arg(out_type)

  ## date of last asymptomatic visit, keyed by contact_id (one row per contact)
  last_visit <- x$linelist$last_visit
  names(last_visit) <- x$linelist$contact_id

  ## score each contact from its exposures (dates ascending within a contact)
  by_contact <- split(x$exposures, x$exposures$contact_id)
  scores <- vapply(names(by_contact), function(id) {
    e <- by_contact[[id]]
    calculate_ctscore(
      p_inf = e$infection_proba,
      e = e$date,
      s = last_visit[[id]],
      t = current_date,
      incub = incub
    )
  }, numeric(1))

  ## scores are individual-level (one per contact) -> shape as requested
  if (out_type == "data.frame") {
    return(tibble::tibble(contact_id = names(scores), score = unname(scores)))
  }
  if (out_type == "ctdata") {
    x$linelist$score <- unname(scores[x$linelist$contact_id])
    return(x)
  }
  scores
}

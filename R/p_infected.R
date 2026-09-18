#' Calculate the probability of infection
#'
#' This function calculates the probability of a contact having been infected 
#' given prior exposures, as described in Jombart et al. 2026. Unlike 
#' `ctscore()`, it requires only exposure data, and no information on follow-up
#' history or incubation period.
#'
#' @author Thibaut Jombart
#' @export
#'
#' @param x a `ctdata` object as returned by [make_ctdata()]
#' 
#' @return A named numeric vector giving the probability of infection for each 
#' contact, named by contact ID. Use [add_p_infected()] to attach these results
#' to the `linelist` of the source `ctdata`.
#'
#' @seealso [add_p_infected()] to attach the results back onto the `ctdata`.
#'
#' @examples
#' x <- make_ctdata(
#'   exposures = tibble::tibble(
#'     contact_id = c(1, 1, 2, 3, 4),
#'     date = Sys.Date() - c(6, 4, 5, 1, 5),
#'     exposure_type = c("normal", "funeral", "normal", "normal", "null")
#'   ),
#'   linelist = tibble::tibble(
#'     contact_id = c(1, 2, 3, 4),
#'     last_visit_date = Sys.Date() - c(2, 1, 1, 3)
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
p_infected <- function(x) {
  
  if (!inherits(x, "ctdata")) {
    stop("'x' should be a ctdata object as returned by make_ctdata()",
      call. = FALSE
    )
  }

  ## probability of infection, keyed by exposure type (one row per type)
  proba <- x$risk$infection_proba
  names(proba) <- x$risk$exposure_type
  x$exposures$proba <- proba[x$exposures$exposure_type]
  
  ## calculate proba of infection for each contact
  out <- tapply(
    x$exposures$proba, 
    x$exposures$contact_id, 
    function(e) sum(calculate_p_infection(e))
    )
  
  ## reshape output from an array to a vector
  out_names <- names(out)
  out <- as.numeric(out)
  names(out) <- out_names
  out
}


#' Attach probabilities of infections to a ctdata linelist
#'
#' Adds the per-contact probabilities of infections returned by [p_infected()] 
#' as a `p_infected` column of the `ctdata`'s `linelist`, matched by 
# `contact_id`.
#'
#' @param x the `ctdata` object to which the scores should be added
#' 
#' @param p_inf a named numeric vector of probabilities of infeciton as returned 
#'  by [p_infected()]
#'
#' @return The `ctdata` object `x`, with a `score` column added to its
#'   `linelist`.
#'
#' @seealso [p_infected()] to calculate the individual probabilities of 
#' infection, and [ctscore()] and [add_ctscore()] for followup scores.
#'
#' @export
add_p_infected <- function(x, p_inf) {
  x$linelist$p_infected <- unname(p_inf[as.character(x$linelist$contact_id)])
  x
}

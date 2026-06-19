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
ctscore <- function(x, incub) {
  if (!inherits(x, "ctdata")) {
    msg <- "'x' should be a ctdata object as returned by make_ctdata()"
    stop(msg)
  }
  if (nrow(x) == 0L) {
    msg <- "'x' has 0 row; at least one data entry is required"
    stop(msg)
  }
  
}
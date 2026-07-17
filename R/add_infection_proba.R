#' Add/change infection probabilities in a ctdata object
#'
#' This function can be used to add or change infection probabilities in a
#' `ctdata` object. It is useful for changing the probabilities of infection for
#' different types of exposures. Probabilities are provided as a named `list`
#' which must have one probability for each exposure type in the `ctdata`
#' object.
#'
#' @author Thibaut Jombart
#'
#' @return a `ctdata` object with updated infection probabilities in its
#'   `exposures` table
#'
#' @param x a `ctdata` object
#'
#' @param proba a named `list` of probabilities for each exposure type
#' @export
#'
add_infection_proba <- function(x, proba) {
  if (!inherits(x, "ctdata")) {
    stop("`x` must be a ctdata object.", call. = FALSE)
  }
  proba <- process_infection_proba(proba, x$exposures)
  x$exposures$infection_proba <- unlist(proba[x$exposures$type], use.names = FALSE)
  x
}

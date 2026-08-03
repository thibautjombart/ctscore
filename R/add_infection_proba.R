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
#' @return a `ctdata` object with an updated `risk` table
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
  x$risk <- dplyr::arrange(
    tibble::tibble(
      exposure_type = names(proba),
      infection_proba = unlist(proba, use.names = FALSE)
    ),
    exposure_type
  )
  x
}

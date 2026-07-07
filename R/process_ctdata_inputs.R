#' Process inputs for ctdata object construction
#'
#' These functions are non-exported. They check the validity of inputs for
#' constructing a `ctdata` object, perform some trivial changes, and return 
#' their inputs. They are used internally in the `ctdata` constructor.
#' 
#' @author Thibaut Jombart
#' 
#' @name process_ctdata_inputs
#' 
#' @noRd
NULL




#' This function checks that contact IDs are either characters or numeric values
#' @noRd
#' 
process_contact_id <- function(x) {
  as.character(x)
}




#' This function checks that dates are either Date or numeric values
#' @noRd
#' 
process_date <- function(x, na_ok = FALSE) {
 
  if (inherits(x, c("character", "POSIXct"))) {
    x <- as.Date(x)
  }
  stopifnot(inherits(x, c("Date", "numeric", "integer")))
  if (!na_ok && any(is.na(x))) {
    msg <- "Dates cannot be NA"
    stop(msg)
  }
  x
}




#' This function ensures 'type' is a character
#' @noRd
#' 
process_type <- function(x) {
  as.character(x)
}




#' This function ensures 'location' is a character
#' @noRd
#' 
process_location <- function(x) {
  as.character(x)
}



#' This function ensures the infection_proba is a list of named numeric values
#' with the correct names and that numeric values are all probabilities. Because
#' the 'type' argument of make_ctdata() is required, the input to this function 
#' is the whole data.frame(). Names of the list must be identical to the types.
#' @noRd
process_infection_proba <- function(proba, x) {
  stopifnot(is.list(proba))
  if (!identical(sort(names(proba)), sort(unique(x$type)))) {
    msg <- "Names of infection_proba must be identical to the types in the ctdata object"
    stop(msg)
  }
  if (!all(vapply(proba, is.numeric, logical(1)))) {
    msg <- "All elements of infection_proba must be numeric"
    stop(msg)
  }
  if (!all(vapply(proba, function(y) all(y >= 0 & y <= 1), logical(1)))) {
    msg <- "All elements of infection_proba must be probabilities (between 0 and 1)"
    stop(msg)
  }
  proba
}

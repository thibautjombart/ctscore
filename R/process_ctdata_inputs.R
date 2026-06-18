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
  if (is.factor(x)) {
    x <- as.character(x)
  }
  stopifnot(inherits(x, c("character", "numeric", "integer")))
  x
}




#' This function checks that dates are either Date or numeric values
#' @noRd
#' 
process_date <- function(x) {
 
  if (inherits(x, c("character", "POSIXct"))) {
    x <- as.Date(x)
  }
  stopifnot(inherits(x, c("Date", "numeric", "integer")))
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

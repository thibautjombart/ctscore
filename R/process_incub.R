#' Process incubation time distribution
#'
#' Internal. Incubation time distribution can be either a vector of
#' probabilities or a distcrete object.
#' 
#' @author Thibaut Jombart
#' @noRd
#' 
#' @param x the incubation time distribution, either as numeric or distcrete 
#'   object
#' @param max_delay the maximum duration of the incubation time; defaults to 100
#'   days
#' 

process_incub <- function(x, max_delay = 100) {
  if (!inherits(x, c("numeric", "distcrete"))) {
    msg <- "'x' should be a numeric vector or a distcrete object"
    stop(msg)
  }
  
  ## if x is a distcrete object, convert to a vector of probabilities
  if (inherits(x, "distcrete")) {
    x <- x$d(0:max_delay)
  }
  
  ## check that the incubation period distribution is non-negative
  if (any(x < 0)) {
    msg <- "'x' should be non-negative"
    stop(msg)
  }
  
  ## keep only first max_delay values, rescale to sum to 1
  x <- head(x, max_delay + 1L)
  x <- x / sum(x)
  
  x
}

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
#' 
#' @returns A function outputing the PMF of the incubation time distribution,
#'   with support from 0 to max_delay days.

process_incub <- function(x, max_delay = 100) {
  if (!inherits(x, c("numeric", "distcrete"))) {
    msg <- "'x' should be a numeric vector or a distcrete object"
    stop(msg)
  }
  
  ## if x is a distcrete object, convert to a vector of probabilities
  if (inherits(x, "distcrete")) {
    out <- x$d
  }
  
  ## if x is a numeric object, we turn it into a function returning the PMF
  if (inherits(x, "numeric")) {
    ## check that the incubation period distribution is non-negative
    if (any(x < 0)) {
    msg <- "'x' should be non-negative"
    stop(msg)
    }
   
    ### closure function to attach x to the function outputing the PMF of the
    ### incubation time distribution;
    ###
    
    f_out <- function(x) {
      x <- x / sum(x)
      n <- length(x) - 1L
      # t is a vector of delays
      function(t) {
        are_in_range <- t >= 0 & t <= n
        res <- double(length(t))
        res[are_in_range] <- x[t[are_in_range] + 1L]
        res
      }
    }
    out <- f_out(x)
  }
  out
}

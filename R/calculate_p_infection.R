#' Calculate the probability of infection from past exposures
#' 
#' Internal. Used to calculate the probability that an infection took place at 
#' a given exposure, accounting for previous ones.
#' 
#' @author Thibaut Jombart
#' @noRd
#' 
#' @param x a vector of probabilities of infection for different successive 
#' exposures, ordered by increasing date
#'
# No checking of input is needed as this is an internal function.
# Formula: 
# p(\mbox{inf}_k | e_1, \ldots e_{k-1}) = \pi_{e_k} \prod_{r=1}^{k-1} (1- \pi_{e_r})
calculate_p_infection <- function(x) {
  n <- length(x)
  if (n == 1L) return(x)
  
  p_not_inf <- cumprod(1 - x[-n])
  out <- c(x[1], x[-1] * p_not_inf)
  out
}

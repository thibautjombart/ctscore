#' Calculate the probability of decting symptoms in a given contact
#' 
#' Internal. Used to calculate the probability that a contact infected on day
#' 'e' shows symptoms on day 't', after having not shown symptoms until day 's'.
#' 
#' @author Thibaut Jombart
#' @noRd
#' 
#' @param e the date at which the individual was exposed
#' @param s the date at which the individual was last seen and had no symptom
#' @param t the current date
#' @param incub the incubation time distribution, provided as a function
#'   returning PMF probabilities
#'
# No checking of input is needed as this is an internal function.
# Formula: 
#  \phi(t_e,s,t) = 
#     \frac{\sum_{r = s+1}^{t} f(r-e)}{1- \sum_{r = e}^{s} f(r - e)} 
calculate_p_symptoms <- function(e, s, t, incub) {
  num <- sum(incub(seq(s+1, t) - e))
  denom <- 1 - sum(incub(seq(e,s) - e))
  out <- num / denom
 
  ## fix mandatory zeros
  are_zero <- t <= s | t < e
  out[are_zero] <- 0
  out
}

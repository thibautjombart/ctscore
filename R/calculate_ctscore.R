#' Calculate ctscore for one individual
#' 
#' Internal. This function calculates the ctscore for a single individual.
#' 
#' @author Thibaut Jombart
#' @noRd
#' 
#' @param p_inf a vector of probabilities of infection for different successive 
#' exposures, ordered by increasing date
#' @param e the dates at which the individual was infected, having the same 
#'   length as `p_inf`; must be sorted from the oldest to the most recent date
#' @param s the date at which the individual was last seen and had no symptom
#' @param t the current date
#' @param incub the incubation time distribution, provided as a function
#'   returning PMF probabilities
#' 
#' Formula: p(\mathbf{e},s,t) = \sum_{k=1}^{K} \psi(e_k) \phi(t_{e_k}, s, t)
#' where:
#'   - \psi(e_k) is returned by calculate_p_infection
#'   - \phi(t_{e_k}, s, t) is returned by calculate_p_symptoms
#' 
#' No input checking, this is an internal function
calculate_ctscore <- function(p_inf, e, s, t, incub) {
  psi <- calculate_p_infection(p_inf)
  phi <- vapply(e, function(t_e) calculate_p_symptoms(t_e, s, t, incub), numeric(1))
  sum(psi*phi)
}

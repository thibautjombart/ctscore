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
#' @param current_date the current date, provided either as a `numeric` value or
#'   as a `Date`; defaults to the current date as returned by `Sys.Date()`
#'   
#' @param out_type a `character` indicating the type of output to return; can be 
#'   either "vector" (default) to return a named vector of scores, "data.frame" 
#'   to return a data frame with contact IDs and scores, or "ctdata" to return a
#'   `ctdata` object with an additional column for the scores.
#' 
#' @return A named numeric vector giving the probability of detecting symptoms
#'  for each contact, with names corresponding to the contact IDs.
#'  
#' @examples
#' ## make dummy contact tracing data
#' x <- make_ctdata(
#'   contact_id = c(1, 1, 2, 3, 4), 
#'   date = Sys.Date() - c(6, 4, 5, 1, 5),
#'   type = c("normal", "funeral", "normal", "normal", "null"),
#'   location = "some-town",
#'   infection_proba = list(normal = 0.2, funeral = 0.9, null = 0),
#'   last_visit = Sys.Date() - c(4, 2, 1, 1, 3)
#' )
#' 
#' ## make a dummy incubation time distribution, specifying the PMF from 0 to 
#' ## 7 days here
#' incub <- c(0, 0, 1, 2, 4, 3, 2, 1)
#' 
#' ## get results
#' res <- ctscore(x, incub)
#' res
#' 
#' ## other example using `distcrete` to build the incubation time distribution
#' incub <- distcrete::distcrete("gamma", interval = 1, shape = 2, scale = 2.5, w = 0)
#' res <- ctscore(x, incub)
#' res
#' 
#' ## trying other output shapes
#' ### data.frame with individual data
#' res_df <- ctscore(x, incub, out_type = "data.frame")
#' res_df
#' 
#' ### ctdata object with scores appended
#' res_ctdata <- ctscore(x, incub, out_type = "ctdata")
#' res_ctdata
#' 

ctscore <- function(x, 
                    incub, 
                    current_date = Sys.Date(), 
                    out_type = c("vector", "data.frame", "ctdata")) {
  ## process inputs
  
   if (!inherits(x, "ctdata")) {
    msg <- "'x' should be a ctdata object as returned by make_ctdata()"
    stop(msg)
  }
 
  incub <- process_incub(incub)
  out_type <- match.arg(out_type)
  
  ## split the data.frame by contact ID and calculate the score for each contact
  list_x <- split(x, x$contact_id)
  
  ## calculate the probability of infection
  out <- vapply(
    list_x, 
    function(e) calculate_ctscore(p_inf = e$p_infection, 
                                  e = e$date, 
                                  s = max(e$last_visit), 
                                  t = current_date, 
                                  incub = incub), 
    numeric(1)
  )
  
  ## shape result into desired output type
  if (out_type == "data.frame") {
    out <- data.frame(contact_id = names(out), score = out)
  } 
  
  if (out_type == "ctdata") {
    out <- dplyr::left_join(x, 
                            data.frame(contact_id = names(out),
                                       score = out), 
                            by = "contact_id")
  }
  out
}
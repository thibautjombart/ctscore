#' Build a ctdata object
#'
#' This constructor will build a `ctdata` object from different inputs
#' describing past exposures and follow-up history for different individuals.
#'
#' @author Thibaut Jombart
#'
#' @export
#'
#' @param contact_id a `character` or a `numeric` vector indicating identifiers
#'   for the contacts
#'
#' @param date a `Date`, `numeric`, or `character` vector indicating dates of
#'   exposures; `character` will be converted to `Date` using `as.Date`, with
#'   expected formats "%Y-%m-%d" or "%Y/%m/%d"; fancier conversions should be 
#'   done before creating a `ctdata` object
#'
#' @param type a `character` used to describe the type of exposure; defaults to
#'   `default`
#'
#' @param location a `character` used to describe the geographic location of the
#'   contact; defaults to `default`
#'   
#' @param infection_proba a `list` of named numeric values, each indicating the 
#'  probability of infection for a given contact; defaults to a list with
#'  'default' exposure having a probability of infection of 0
#'  
#' @return A `ctdata` object, which is a validated and ordered (by contact ID
#'   and date of exposure) `data.frame` designed to be used in the [ctscore] 
#'   function.
#'   
#' @examples
#' 
#' x <- make_ctdata(
#'   contact_id = c(1, 1, 2, 3), 
#'   date = Sys.Date() - c(6, 4, 2, 2),
#'   type = c("normal", "funeral", "normal", "normal"),
#'   location = "some-town",
#'   infection_proba = list(normal = 0.2, funeral = 0.9)
#' )
#' x
#' class(x)

make_ctdata <- function(contact_id,
                        date, 
                        type = "default", 
                        location = "default", 
                        infection_proba = list(default = 0)
                        ) {
  out <- data.frame(
    contact_id = process_contact_id(contact_id), 
    date = process_date(date), 
    type = process_type(type), 
    location = process_location(location)
  )
  class(out) <- c("ctdata", class(out))
  
  ## process the infection_proba argument and add infection probabilities to the
  ## final object; all input checking is done inside add_infection_proba()
  out <- add_infection_proba(out, infection_proba)
  
  ## reorder output by: contact_id, date
  out <- dplyr::arrange(out, contact_id, date)
  out
}



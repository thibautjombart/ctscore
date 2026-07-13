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
#'   for the contacts; will be converted to `character` if not already
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
#' @param last_visit the date of the last visit to the contact, where they 
#'   exhibited no symptoms; the type provided must match that of `date`; if the 
#'   contact has not been visited yet, this should be `NA`
#' 
#' @param infected `logical` infection status per contact, or `NA` when unknown; 
#' defaults to `NA`.
#' 
#' @param onset the date of symptom onset for the contact; the type provided 
#' must match that of `date`; if the contact has not developed symptoms, 
#' this should be `NA`
#' 
#' @param ... additional named vectors to append as extra columns; each must be
#'   length 1 (recycled) or match the number of rows, and names must not clash
#'   with existing columns
#' 
#' @return A `ctdata` object, which is a validated and ordered (by contact ID
#'   and date of exposure) `data.frame` designed to be used in the [ctscore] 
#'   function.
#' 
#' @seealso [sim_ctdata()] to simulate contact tracing data.
#'   
#' @examples
#' 
#' x <- make_ctdata(
#'   contact_id = c(1, 1, 2, 3), 
#'   date = Sys.Date() - c(6, 4, 2, 2),
#'   type = c("normal", "funeral", "normal", "normal"),
#'   location = "some-town",
#'   infection_proba = list(normal = 0.2, funeral = 0.9),
#'   last_visit = Sys.Date() - c(4, 4, 1, NA)
#' )
#' x
#' class(x)

make_ctdata <- function(contact_id,
                        date, 
                        type = "default", 
                        location = "default", 
                        infection_proba = list(default = 0), 
                        last_visit = NA_real_,
                        infected = NA,
                        onset = NA_real_,
                        ...
                        ) {
  out <- data.frame(
    contact_id = process_contact_id(contact_id), 
    date = process_date(date),
    type = process_type(type), 
    location = process_location(location), 
    last_visit = process_date(last_visit, na_ok = TRUE),
    infected = process_infected(infected),
    onset = process_date(onset, na_ok = TRUE)
  )
  ## a symptom onset date implies the contact is infected
  process_onset_infected(out$onset, out$infected)

  ## append any additional user-supplied columns
  extra <- process_extra_columns(list(...), n_rows = nrow(out))
  for (nm in names(extra)) out[[nm]] <- extra[[nm]]


  class(out) <- c("ctdata", class(out))
  
  ## process the infection_proba argument and add infection probabilities to the
  ## final object; all input checking is done inside add_infection_proba()
  out <- add_infection_proba(out, infection_proba)
  
  ## reorder output by: contact_id, date
  out <- dplyr::arrange(out, contact_id, date) #@thibautjombart dplyr is in suggests so you may need a requireNamespace("dplyr") here
  out
}



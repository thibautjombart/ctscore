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
#' @param date_format a `character` indicating the format of the dates; used
#'   only if `date` is a `character`, in which case it is passed as the `format`
#'   argument of `as.Date`; in the absence of format (default), 
make_ctdata <- function(contact_id,
                        date, 
                        type = "default", 
                        location = "default"
                        ) {
  out <- data.frame(
    contact_id = process_contact_id(contact_id), 
    date = process_date(date), 
    type = process_type(type), 
    location = process_location(location)
  )
  class(out) <- c("ctdata", class(out))
  out
}



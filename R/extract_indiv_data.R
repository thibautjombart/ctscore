#' Extract individual data from a `ctdata` object
#' 
#' `ctdata` objects are used to store exposure data; as contacts may report
#' multiple exposures, the corresponding individual data (e.g. location, data of
#' last visit) are repeated. This function extracts individual data so that the
#' output has a single row for each individual, effectively stripping exposure
#' data.
#' 
#' @export
#' @author Thibaut Jombart
#' 
#' @param x a `ctdata` object as returned by [make_ctdata()] or [sim_ctdata()]
#' 
#' @examples
#' ## with a simple ctdata
#' x <- make_ctdata(
#'   contact_id = c(1, 1, 2, 3, 3), 
#'   date = Sys.Date() - c(6, 4, 2, 2, 3),
#'   type = c("normal", "funeral", "normal", "normal", "funeral"),
#'   location = c("some-town", "some-town", "some-town", "sincity", "sincity"),
#'   infection_proba = list(normal = 0.2, funeral = 0.9),
#'   last_visit = Sys.Date() - c(4, 4, 1, NA, NA)
#' )
#' x
#' 
#' extract_indiv_data(x)
#' 
#' ## with a ctdata object containing scores (returned by ctscore())
#' scores <- ctscore(x, 
#'   incub = c(0, 0, 1, 2, 4, 3, 2, 1), 
#'   current_date = Sys.Date(), 
#'   out_type = "ctdata"
#' )
#' 
#' scores
#' extract_indiv_data(scores)
#' 
extract_indiv_data <- function(x) {
  if (!inherits(x, "ctdata")) {
    stop("'x' should be a ctdata object")
  }
 
  ## remove columns that are specific to exposures
  to_remove <- names(x) %in% c("date", "type", "infection_proba")
  out <- x[, !to_remove, drop = FALSE]
  
  ## keep only the first occurrence of each contact_id
  ids <- unique(out$contact_id)
  to_keep <- match(ids, out$contact_id)
  out <- out[to_keep, , drop = FALSE]
  
  return(out)
}

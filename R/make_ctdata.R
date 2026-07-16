#' Build a ctdata object
#'
#' This constructor will build a `ctdata` object from different inputs
#' describing past exposures and follow-up history for different individuals.
#'
#' @author Thibaut Jombart / Cyril Geismar
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
#' @param ... additional named vectors to append as extra columns to the linelist;
#'   each must be length 1 (recycled) or the number of contacts, and names must not clash 
#'   with existing columns
#'
#' @details
#' Individual-level inputs (`location`, `last_visit`, `infected`, `onset` and any
#' extra columns passed through `...`) describe the contact, not the exposure.
#' They may be supplied per exposure row for convenience, but must be constant
#' within a contact; `make_ctdata()` errors otherwise and stores a single value
#' per contact in `linelist`.
#'
#' @return A `ctdata` object: a `list` of two tibbles sharing the a `contact_id` column:
#'   - `linelist`: one row per contact (`location`, `last_visit`, `infected`,
#'     `onset`, plus any extra columns), ordered by `contact_id`;
#'   - `exposures`: one row per exposure (`date`, `type`, `infection_proba`),
#'     ordered by `contact_id` then `date`.
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
                        ...) {
  
  linelist <- tibble::tibble(
    contact_id = process_contact_id(contact_id),
    location   = process_location(location),
    last_visit = process_date(last_visit, na_ok = TRUE),
    infected   = process_infected(infected),
    onset      = process_date(onset, na_ok = TRUE)
  ) |>
    add_extra_columns(...)
  
  exposures <- tibble::tibble(contact_id = contact_id,
                              date = process_date(date),
                              type = process_type(type)) |>
    add_infection_proba(infection_proba)

  
  ## a symptom onset date implies the contact is infected
  process_onset_infected(linelist$onset, linelist$infected)
  
  ## order: linelist by contact_id, exposures by contact_id then date
  linelist  <- dplyr::arrange(linelist, contact_id)
  exposures <- dplyr::arrange(exposures, contact_id, date)
  
  new_ctdata(linelist = linelist, exposures = exposures)
}

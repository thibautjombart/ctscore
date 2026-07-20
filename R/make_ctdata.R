#' Build a ctdata object
#'
#' Builds a `ctdata` object from two tables: `exposures` (one row per exposure)
#' and an optional `linelist` (one row per contact). Both are keyed by
#' `contact_id`.
#'
#' @author Thibaut Jombart / Cyril Geismar
#'
#' @export
#'
#' @param exposures a `data.frame` of exposures, one row per exposure.
#'   Must contain `contact_id`, `date` and `type`; any extra columns are kept as
#'   exposure-level data. `date` may be `Date`, numeric, or character (converted
#'   with `as.Date`).
#'
#' @param linelist an optional `data.frame` of individual-level data.
#'   Must contain `contact_id` and may contain `location`, `last_visit_date`, `infected`,
#'   `onset_date`, plus any extra columns.
#'   `last_visit_date` and `onset_date` may be `Date` or numeric.
#'
#' @param infection_proba a named `list` giving the probability of infection for
#'   each exposure `type`; names must match the types present in `exposures`.
#'
#' @return A `ctdata` object: a `list` of two tibbles sharing a `contact_id`
#'   column — `linelist` (one row per contact) and `exposures` (one row per
#'   exposure, with `infection_proba` attached), ordered by contact and date.
#'
#' @seealso [sim_ctdata()] to simulate contact tracing data.
#'
#' @examples
#' x <- make_ctdata(
#'   exposures = tibble::tibble(
#'     contact_id = c(1, 1, 2, 3),
#'     date       = Sys.Date() - c(6, 4, 2, 2),
#'     type       = c("normal", "funeral", "normal", "normal")
#'   ),
#'   linelist = tibble::tibble(
#'     contact_id = c(1, 2, 3),
#'     location   = "some-town",
#'     last_visit_date = Sys.Date() - c(4, 1, NA)
#'   ),
#'   infection_proba = list(normal = 0.2, funeral = 0.9)
#' )
#' x
#' class(x)
make_ctdata <- function(exposures,
                        linelist = NULL,
                        infection_proba = list(default = 0)) {
  exposures <- process_exposures(exposures)
  linelist <- process_linelist(linelist, exposures)
  new_ctdata(linelist = linelist, exposures = exposures) |>
    add_infection_proba(infection_proba)
}

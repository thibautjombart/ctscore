#' Internal helpers and methods for `ctdata` objects
#'
#' A `ctdata` object is a `list` of two tibbles sharing a `contact_id` column:
#' - `linelist`: one row per contact (individual-level data such as `location`,
#'   `last_visit_date`, `infected`, `onset_date`, plus any extra columns).
#' - `exposures`: one row per exposure (`date`, `type`, `infection_proba`).
#'
#' @author Cyril Geismar
#' @name ctdata
#' @keywords internal
NULL


#' Low-level constructor for `ctdata` objects
#'
#' See [make_ctdata()] for the user-facing builder.
#'
#' @param linelist a tibble with one row per contact
#' @param exposures a tibble with one row per exposure
#' @noRd
new_ctdata <- function(linelist, exposures) {
  structure(list(linelist = linelist, exposures = exposures), class = "ctdata")
}


#' @importFrom tibble as_tibble
#' @export
tibble::as_tibble


#' Coerce a `ctdata` object to a tibble
#'
#' Two formats are available:
#' - `by_contact = FALSE` (default): one row per exposure, with contact-level
#'   `linelist` columns added to each row.
#' - `by_contact = TRUE`: one row per contact, with exposures stored in a nested
#'   `exposures` list-column containing `date`, `type`, and `infection_proba`.
#'
#' @param x a `ctdata` object
#' @param by_contact `logical`; return one row per contact with nested
#'   exposures (`TRUE`), or one row per exposure (`FALSE`, default)
#' @param ... ignored
#'
#' @return A tibble.
#'
#' @exportS3Method tibble::as_tibble
#'
#' @examples
#' x <- sim_ctdata(5)
#' as_tibble(x) # flat: one row per exposure
#' as_tibble(x, by_contact = TRUE) # nested: one row per contact
as_tibble.ctdata <- function(x, ..., by_contact = FALSE) {
  if (by_contact) {
    dplyr::left_join(
      x$linelist,
      tidyr::nest(x$exposures, exposures = -contact_id),
      by = "contact_id"
    )
  } else {
    dplyr::arrange(
      dplyr::left_join(x$exposures, x$linelist, by = "contact_id"),
      contact_id, date
    )
  }
}


#' Coerce a `ctdata` object to a flat data frame
#'
#' The base-R equivalent of `as_tibble(x, by_contact = FALSE)`: an
#' exposure-level `data.frame` with the `linelist` columns joined onto each
#' exposure row.
#'
#' @param x a `ctdata` object
#' @param ... ignored
#'
#' @return A `data.frame` with one row per exposure.
#'
#' @export
as.data.frame.ctdata <- function(x, ...) {
  as.data.frame(as_tibble(x, by_contact = FALSE))
}


#' Print a `ctdata` object
#'
#' @param x a `ctdata` object
#' @param ... passed to the print methods of the underlying tibbles
#'
#' @return `x`, invisibly.
#'
#' @export
print.ctdata <- function(x, ...) {
  cat(sprintf(
    "%s: %d contact(s), %d exposure(s)\n",
    "<ctdata>",
    nrow(x$linelist),
    nrow(x$exposures)
  ))
  cat("\n$linelist\n")
  print(x$linelist, ...)
  cat("\n$exposures\n")
  print(x$exposures, ...)
  invisible(x)
}

#' Internal helpers and methods for `ctdata` objects
#'
#' A `ctdata` object is a `list` of two tibbles sharing a `contact_id` column:
#' - `linelist`: one row per contact (individual-level data such as `location`,
#'   `last_visit`, `infected`, `onset`, plus any extra columns).
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


#' Coerce a `ctdata` object to a flat data frame
#'
#' Reconstructs a single "flat" data frame with one row per exposure, joining the
#' individual-level `linelist` columns onto the `exposures` table by
#' `contact_id`. This is the exposure-level view used internally (e.g. by
#' [plot.ctdata()]) and a convenient shape for users who want everything in one
#' table.
#'
#' @param x a `ctdata` object
#' @param ... ignored
#'
#' @return A `data.frame` (tibble) with one row per exposure.
#'
#' @export
as.data.frame.ctdata <- function(x, ...) {
  ## attach the single per-contact linelist row onto each exposure row
  out <- dplyr::left_join(x$exposures, x$linelist, by = "contact_id")
  dplyr::arrange(out, contact_id, date)
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

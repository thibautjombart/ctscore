#' Process inputs for ctdata object construction
#'
#' These functions are non-exported. They check the validity of inputs for
#' constructing a `ctdata` object, perform some trivial changes, and return
#' their inputs. They are used internally in the `ctdata` constructor.
#'
#' @author Thibaut Jombart
#'
#' @name process_ctdata_inputs
#'
#' @noRd
NULL



#' Coerce contact identifiers to character.
#' @noRd
#'
process_contact_id <- function(x) {
  as.character(x)
}


#' Coerce dates to `Date` and validate them.
#'
#' Character/POSIXct inputs are converted with `as.Date`; the result must be
#' `Date`, numeric, or integer. `NA` is allowed only when `na_ok = TRUE`.
#' @noRd
#'
process_date <- function(x, na_ok = FALSE) {
  if (inherits(x, c("character", "POSIXct"))) {
    x <- as.Date(x)
  }
  if (!inherits(x, c("Date", "numeric", "integer"))) {
    stop("dates must be Date, numeric, or character.", call. = FALSE)
  }
  if (!na_ok && any(is.na(x))) {
    stop("Dates cannot be NA", call. = FALSE)
  }
  x
}


#' Coerce exposure `type` to character.
#' @noRd
#'
process_type <- function(x) {
  as.character(x)
}


#' Coerce `location` to character.
#' @noRd
#'
process_location <- function(x) {
  as.character(x)
}


#' Validate the `infection_proba` list against the exposure types.
#'
#' `proba` must be a named list of probabilities (each in `[0, 1]`) whose names
#' are identical to the exposure types found in `x$type` (the exposures table).
#' @noRd
process_infection_proba <- function(proba, x) {
  if (!is.list(proba)) {
    stop("`infection_proba` must be a named list.", call. = FALSE)
  }
  if (!identical(sort(names(proba)), sort(unique(x$type)))) {
    stop("Names of infection_proba must be identical to the types in the ctdata object",
      call. = FALSE
    )
  }
  if (!all(vapply(proba, is.numeric, logical(1)))) {
    stop("All elements of infection_proba must be numeric", call. = FALSE)
  }
  if (!all(vapply(proba, function(y) all(y >= 0 & y <= 1), logical(1)))) {
    stop("All elements of infection_proba must be probabilities (between 0 and 1)",
      call. = FALSE
    )
  }
  proba
}


#' Validate that infection status is a logical vector (NAs allowed).
#' @noRd
process_infected <- function(x) {
  if (!is.logical(x)) {
    stop("'infected' must be a logical vector (TRUE/FALSE/NA)", call. = FALSE)
  }
  x
}


#' Validate that onset is consistent with infection status.
#'
#' A contact with a symptom onset date must be infected (`TRUE`). Takes and
#' returns the linelist unchanged; errors (naming the contacts) on any
#' inconsistency.
#' @noRd
process_onset_infected <- function(linelist) {
  ## onset_date present but infection not confirmed (TRUE)
  bad <- !is.na(linelist$onset_date) & !(linelist$infected %in% TRUE)
  if (any(bad)) {
    stop(
      sprintf(
        "onset_date implies infected = TRUE, check contact(s): %s",
        paste(linelist$contact_id[bad], collapse = ", ")
      ),
      call. = FALSE
    )
  }
  linelist
}


#' Validate and process the exposures table of a ctdata object.
#'
#' Checks that the required columns (`contact_id`, `date`, `type`) are present,
#' coerces their types, and orders the rows by contact then date. Extra columns
#' are preserved. Infection probabilities are attached separately, by
#' [add_infection_proba()].
#' @noRd
process_exposures <- function(exposures) {
  if (!is.data.frame(exposures)) {
    stop("`exposures` must be a data frame.",
      call. = FALSE
    )
  }
  missing_cols <- setdiff(c("contact_id", "date", "type"), names(exposures))
  if (length(missing_cols)) {
    stop("`exposures` is missing required column(s): ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
  exposures <- tibble::as_tibble(exposures)
  exposures$contact_id <- process_contact_id(exposures$contact_id)
  exposures$date <- process_date(exposures$date)
  exposures$type <- process_type(exposures$type)

  dplyr::arrange(exposures, contact_id, date)
}


#' Validate, derive and process the linelist table of a ctdata object.
#'
#' When `linelist` is `NULL`, an all-`NA` linelist is derived from the contact
#' ids found in `exposures`. Otherwise the supplied table is validated (a data
#' frame keyed by a unique `contact_id` covering every exposed contact) and
#' coerced. The recognised individual columns (`location`, `last_visit_date`,
#' `infected`, `onset_date`) are filled with `NA` when absent; extra columns are kept.
#' @noRd
process_linelist <- function(linelist, exposures) {
  ids <- unique(exposures$contact_id)

  if (is.null(linelist)) {
    linelist <- tibble::tibble(contact_id = ids)
  } else {
    if (!is.data.frame(linelist)) {
      stop("`linelist` must be a data frame (or NULL).", call. = FALSE)
    }
    if (!"contact_id" %in% names(linelist)) {
      stop("`linelist` must have a `contact_id` column.", call. = FALSE)
    }
    linelist <- tibble::as_tibble(linelist)
    linelist$contact_id <- process_contact_id(linelist$contact_id)
    if (anyDuplicated(linelist$contact_id)) {
      stop("`linelist` must have one row per contact (duplicated contact_id).",
        call. = FALSE
      )
    }
    missing_ids <- setdiff(ids, linelist$contact_id)
    if (length(missing_ids)) {
      stop("`linelist` is missing contact(s) present in `exposures`: ",
        paste(missing_ids, collapse = ", "),
        call. = FALSE
      )
    }
  }

  ## ensure the recognised individual columns exist (fill NA), then coerce
  na_day <- if (inherits(exposures$date, "Date")) as.Date(NA) else NA_real_
  if (!"location" %in% names(linelist)) linelist$location <- NA_character_
  if (!"last_visit_date" %in% names(linelist)) linelist$last_visit_date <- na_day
  if (!"infected" %in% names(linelist)) linelist$infected <- NA
  if (!"onset_date" %in% names(linelist)) linelist$onset_date <- na_day
  linelist$location <- process_location(linelist$location)
  linelist$last_visit_date <- process_date(linelist$last_visit_date, na_ok = TRUE)
  linelist$infected <- process_infected(linelist$infected)
  linelist$onset_date <- process_date(linelist$onset_date, na_ok = TRUE)

  ## a symptom onset date implies the contact is infected
  linelist <- process_onset_infected(linelist)

  ## stable column order: recognised columns first, then any extras
  recognised <- c("contact_id", "location", "last_visit_date", "infected", "onset_date")
  linelist <- linelist[c(recognised, setdiff(names(linelist), recognised))]

  dplyr::arrange(linelist, contact_id)
}

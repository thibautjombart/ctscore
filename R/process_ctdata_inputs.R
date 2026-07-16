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




#' This function checks that contact IDs are either characters or numeric values
#' @noRd
#'
process_contact_id <- function(x) {
  as.character(x)
}




#' This function checks that dates are either Date or numeric values
#' @noRd
#'
process_date <- function(x, na_ok = FALSE) {
  if (inherits(x, c("character", "POSIXct"))) {
    x <- as.Date(x)
  }
  stopifnot(inherits(x, c("Date", "numeric", "integer")))
  if (!na_ok && any(is.na(x))) {
    msg <- "Dates cannot be NA"
    stop(msg)
  }
  x
}




#' This function ensures 'type' is a character
#' @noRd
#'
process_type <- function(x) {
  as.character(x)
}




#' This function ensures 'location' is a character
#' @noRd
#'
process_location <- function(x) {
  as.character(x)
}



#' This function ensures the infection_proba is a list of named numeric values
#' with the correct names and that numeric values are all probabilities. Because
#' the 'type' argument of make_ctdata() is required, the input to this function
#' is the whole data.frame(). Names of the list must be identical to the types.
#' @noRd
process_infection_proba <- function(proba, x) {
  stopifnot(is.list(proba))
  if (!identical(sort(names(proba)), sort(unique(x$type)))) {
    msg <- "Names of infection_proba must be identical to the types in the ctdata object"
    stop(msg)
  }
  if (!all(vapply(proba, is.numeric, logical(1)))) {
    msg <- "All elements of infection_proba must be numeric"
    stop(msg)
  }
  if (!all(vapply(proba, function(y)
    all(y >= 0 & y <= 1), logical(1)))) {
    msg <- "All elements of infection_proba must be probabilities (between 0 and 1)"
    stop(msg)
  }
  proba
}


#' Checks the infection status is a logical vector.
#' NAs are allowed.
#' @noRd
process_infected <- function(x) {
  if (!is.logical(x)) {
    stop("'infected' must be a logical vector (TRUE/FALSE/NA)")
  }
  x
}


#' Checks that onset is consistent with infection status.
#' A contact with a symptom onset date must be infected (TRUE).
#' @noRd
process_onset_infected <- function(onset, infected) {
  #onset present and infection not confirmed.
  bad <- !is.na(onset) & !(infected %in% TRUE)
  if (any(bad)) {
    msg <- sprintf("onset implies infected = TRUE, check rows: %s",
                   paste(which(bad), collapse = ", "))
    stop(msg)
  }
  invisible(TRUE)
}



#' Validates optional user-supplied columns passed through `...`.
#' Checks that they are named, do not overwrite reserved ctdata columns,
#' and are either length 1 (recycled) or match the number of exposure rows.
#' `reserved` lists columns added downstream by ctscore()/sim_followup(); the
#' make_ctdata() formals are already protected by R's argument matching, so only
#' these non-formal names can slip in through `...`.
#' @noRd
process_extra_columns <- function(dots,
                                  n_rows,
                                  reserved = c("score", "detection_date")) {
  if (length(dots) == 0L)
    return(dots)
  
  nms <- names(dots)
  if (is.null(nms) || any(!nzchar(nms))) {
    msg <- "additional input(s) passed through '...' must be named"
    stop(msg)
  }
  if (anyDuplicated(nms)) {
    msg <- "additional input names passed through '...' must be unique"
    stop(msg)
  }
  clash <- intersect(nms, reserved)
  if (length(clash) > 0) {
    msg <- sprintf(
      "additional input name(s) clash with reserved ctdata columns: %s",
      paste(clash, collapse = ", ")
    )
    stop(msg)
  }
  bad_len <- vapply(dots, function(col)
    ! (length(col) %in% c(1L, n_rows)), logical(1))
  if (any(bad_len)) {
    msg <- sprintf("additional input(s) must be length 1 or %d: %s",
                   n_rows,
                   paste(nms[bad_len], collapse = ", "))
    stop(msg)
  }
  dots
}

#' Append validated extra columns to the linelist.
#'
#' Extra columns are passed through `...` in `make_ctdata()` and validated by
#' `process_extra_columns()`.
#'
#' @param x the linelist in a ctdata object
#' @param ... named vectors to append (each length 1 or nrow(x))
#' @noRd
add_extra_columns <- function(x, ...) {
  extra <- process_extra_columns(list(...), n_rows = nrow(x))
  for (nm in names(extra))
    x[[nm]] <- extra[[nm]]
  x
}

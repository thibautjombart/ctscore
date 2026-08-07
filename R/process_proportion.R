#' Check proportion input
#'
#' Internal. This function ensures that its input is numeric, finite, and
#' between 0 and 1. It is used to validate proportion inputs in other functions.
#'
#' @noRd
#' @author Thibaut Jombart
#' @param x the input to validate
#' @param txt the text to use to refer to the input

process_proportion <- function(x, txt = "x") {
  if (length(x) != 1L) {
    msg <- sprintf("'%s' must be a single value", txt)
    stop(msg)
  }
  if (!is.numeric(x)) {
    msg <- sprintf("'%s' must be numeric", txt)
    stop(msg)
  }
  if (!is.finite(x)) {
    msg <- sprintf("'%s' must be finite", txt)
    stop(msg)
  }
  if (x < 0) {
    msg <- sprintf("'%s' must be >= 0", txt)
    stop(msg)
  }
  if (x > 1) {
    msg <- sprintf("'%s' must be <= 1", txt)
    stop(msg)
  }
  x
}

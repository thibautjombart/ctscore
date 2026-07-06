#' Check duration input
#' 
#' Internal. This function ensures that its input is numeric, finite, and
#' non-negative. Optionally it can check that it is strictly positive. It is
#' used to validate duration inputs in other functions. It returns its own 
#' argument converted to `integer`.
#' 
#' @noRd
#' @author Thibaut Jombart
#' @param x the input to validate
#' @param txt the text to use to refer to the input
#' @param strictly_positive a `logical` indicating if the input should be >=0

process_duration <- function(x, txt = "x", strictly_positive = FALSE) {
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
    msg <- sprintf("'%s' must be positive", txt)
    stop(msg)
  }
  if (strictly_positive && x <= 0) {
    msg <- sprintf("'%s' must be strictly positive", txt)
    stop(msg)
  }
  as.integer(x)
}

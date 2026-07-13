#' Plot a contact-tracing timeline
#'
#' Produces a timeline plot of contact-tracing data, with one row per contact
#' along a time axis. Contacts are ordered by first exposure day.
#'
#' @author Cyril Geismar
#'
#' @param x a `ctdata` object returned by [make_ctdata()], or a `sim_ctdata`
#'   object returned by [sim_ctdata()].
#' @param ... currently ignored.
#'
#' @return A `ggplot` object.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' ## simulated data (also shows infection date and symptom onset)
#' plot(sim_ctdata())
#'
#' }
plot.ctdata <- function(x, ...) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required to plot ctdata objects. ",
         "Please install it with install.packages('ggplot2').",
         call. = FALSE)
  }

  x <- as.data.frame(x)

  ## order contacts on the y-axis by their first exposure day
  first_exp <- tapply(x$date, x$contact_id, min)
  x$contact <- factor(x$contact_id, levels = names(sort(first_exp)))
  pc <- x[!duplicated(x$contact_id), ]

  seg <- do.call(
    rbind,
    by(data = x, INDICES = x$contact, FUN = function(d) {
      days <- c(d$date, d$last_visit, d$onset, d$infection_date, d$detection_date)
      data.frame(
        contact = d$contact[1L],
        location = d$location[1L],
        x_start = min(days, na.rm = TRUE),
        x_end = max(days, na.rm = TRUE)
      )
    })
  )

  p <- ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = seg,
      ggplot2::aes(
        x = x_start, xend = x_end,
        y = contact, yend = contact
      ),
      colour = "grey80"
    ) +
    ## exposures, coloured by type
    ggplot2::geom_point(
      data = x,
      ggplot2::aes(
        x = date, y = contact, colour = type
      ),
      size = 3
    ) +
    ## last visit (cross)
    ggplot2::geom_point(
      data = pc[!is.na(pc$last_visit), ],
      ggplot2::aes(
        x = last_visit, y = contact, shape = "last visit"
      ),
      size = 3
    )

  ## symptom onset (triangle) (sim_ctdata only)
  if ("onset" %in% names(x)) {
    p <- p +
      ggplot2::geom_point(
        data = pc[!is.na(pc$onset), ],
        ggplot2::aes(
          x = onset, y = contact, shape = "onset"
        ),
        size = 3
      )
  }

  ## infection date (diamond) (sim_ctdata only): marks the infecting exposure
  if ("infection_date" %in% names(x)) {
    p <- p +
      ggplot2::geom_point(
        data = pc[!is.na(pc$infection_date), ],
        ggplot2::aes(
          x = infection_date, y = contact, shape = "infection"
        ),
        size = 3
      )
  }

  ## detection date (asterisk) (after sim_followup only)
  if ("detection_date" %in% names(x)) {
    p <- p +
      ggplot2::geom_point(
        data = pc[!is.na(pc$detection_date), ],
        ggplot2::aes(
          x = detection_date, y = contact, shape = "detection"
        ),
        size = 3
      )
  }

  p <- p +
    ggplot2::scale_shape_manual(
      values = c("infection" = 18, "onset" = 17, "last visit" = 15, "detection" = 8),
      name = NULL
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(x = "day", y = "ID", colour = NULL) +
    ggplot2::theme_classic() +
    ggplot2::theme(legend.position = "bottom")

  p
}

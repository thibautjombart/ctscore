#' Plot a contact-tracing timeline
#'
#' Produces a timeline plot of simulated contact-tracing data, with one row per contact along a time axis.
#' For each contact, it shows exposure events, symptom onset for infected individuals, and the last symptom-free visit (last_visit).
#' A vertical dashed line indicates the analysis date.
#' Contacts are ordered by first exposure date.
#'
#' @author Cyril Geismar
#'
#' @param x a `sim_ctdata` object returned by [simulate_ct()].
#' @param ... currently ignored.
#'
#' @return A `ggplot` object.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' incub <- distcrete::distcrete("gamma", shape = 4, scale = 1.5, w = 0.5, interval = 1)
#' sim <- simulate_ct(
#'   n_contacts = 20,
#'   incub = incub,
#'   p_inf = list(household = 0.2, funeral = 0.8)
#' )
#' plot(sim)
#' }
plot.sim_ctdata <- function(x, ...) {
  today <- attr(x, "today")

  ## order contacts on the y-axis by their first exposure day
  first_exp <- tapply(x$date, x$contact_id, min)
  x$contact <- factor(x$contact_id, levels = names(sort(first_exp)))

  ## onset and last visit are one value per contact
  pc <- x[!duplicated(x$contact_id), ]

  ## long form: key = exposure type for exposures, else the event's own name
  events <- rbind(
    data.frame(
      contact = x$contact,
      day = x$date,
      key = x$type,
      location = x$location
    ),
    data.frame(
      contact = pc$contact,
      day = pc$date_onset,
      key = "onset",
      location = pc$location
    ),
    data.frame(
      contact = pc$contact,
      day = pc$last_visit,
      key = "last visit",
      location = pc$location
    )
  )
  events <- events[!is.na(events$day), ]

  ## colour + shape both keyed off `key` so they share one legend; colours use
  ## ggplot2's default palette, shapes mark exposure vs onset vs last visit.
  types <- sort(unique(x$type))
  lvls <- c(types, "onset", "last visit")
  events$key <- factor(events$key, levels = lvls)
  shapes <- c(rep(16, length(types)), 17, 4)
  names(shapes) <- lvls

  ggplot2::ggplot(events, ggplot2::aes(x = day, y = contact)) +
    ## a light lifeline per contact, from first exposure to today
    ggplot2::geom_segment(
      data = pc,
      inherit.aes = FALSE,
      ggplot2::aes(x = date, y = contact, yend = contact),
      xend = today,
      colour = "grey80"
    ) +
    ggplot2::geom_vline(
      xintercept = today,
      linetype = "dashed",
      colour = "grey50"
    ) +
    ggplot2::geom_point(ggplot2::aes(shape = key, colour = key), size = 3) +
    ggplot2::scale_shape_manual(values = shapes) +
    ggplot2::scale_x_continuous(breaks = seq(0, max(events$day) + 1, by = 5)) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(
      x = "day",
      y = "ID",
      colour = NULL,
      shape = NULL
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      legend.position = "bottom",
      legend.box = "vertical",
      legend.margin = ggplot2::margin(1, 1, 1, 1),
      legend.box.margin = ggplot2::margin(-5, -5, -5, -5)
    )
}

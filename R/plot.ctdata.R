#' Plot a contact-tracing timeline
#'
#' Produces a timeline plot of contact-tracing data, with one row per contact
#' along a time axis. Contacts are ordered by first exposure day.
#'
#' @author Cyril Geismar
#'
#' @param x a `ctdata` object.
#' @param ... currently ignored.
#'
#' @return A `ggplot` object. Each contact's `linelist` columns (e.g.
#'   `location`) are carried in the plot data, so the result can be extended
#'   with, for example, `ggplot2::facet_wrap()` or `ggplot2::aes()` on them.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' ## simulated data (also shows infection date and symptom onset)
#' plot(sim_ctdata())
#'
#' ## facet by a linelist column
#' sim_ctdata(
#'   locations = list(cityA = 0.5, cityB = 0.5),
#'   n_exposures = list(cityA = 2, cityB = 3)
#' ) |>
#'   plot() +
#'   ggplot2::facet_wrap(~location, scales = "free_y")
#' }
plot.ctdata <- function(x, ...) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      "Package 'ggplot2' is required to plot ctdata objects. ",
      "Please install it with install.packages('ggplot2').",
      call. = FALSE
    )
  }

  linelist_shapes <- c(infection_date = 18, onset_date = 17, last_visit_date = 15, detection_date = 8)

  ## one row per event
  d <- dplyr::bind_rows(
    ## exposures:
    as_tibble(x) |>
      dplyr::select(-dplyr::any_of(names(linelist_shapes))) |>
      dplyr::mutate(event = "exposure"),
    
    ## linelist events:
    x$linelist |>
      tidyr::pivot_longer(dplyr::any_of(names(linelist_shapes)), names_to = "event", values_to = "date") |>
      dplyr::filter(!is.na(date))
  ) |>
    dplyr::mutate(contact_id = factor(contact_id, names(sort(tapply(date, contact_id, min)))))

  ggplot2::ggplot(d, ggplot2::aes(date, contact_id)) +
    ggplot2::geom_line(ggplot2::aes(group = contact_id), colour = "grey80") +
    ggplot2::geom_point(
      data = dplyr::filter(d, event == "exposure"),
      ggplot2::aes(fill = type), shape = 21, colour = "black", size = 3
    ) +
    ggplot2::geom_point(
      data = dplyr::filter(d, event != "exposure"),
      ggplot2::aes(shape = event), size = 2
    ) +
    ggplot2::scale_shape_manual(
      values = linelist_shapes,
      breaks = names(linelist_shapes),
      labels = c(infection_date = "infection", onset_date = "onset",
                 last_visit_date = "last visit", detection_date = "detection"),
      name = NULL
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(x = "day", y = "ID") +
    ggplot2::theme_classic() +
    ggplot2::theme(legend.position = "bottom")
}

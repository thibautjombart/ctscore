devtools::load_all()
library(ggplot2)
set.seed(123)


today <- 10
ctd <- make_ctdata(
  contact_id = c(1, 1, 2, 3),
  date = today - c(9, 6, 7, 8),
  type = c("normal", "funeral", "normal", "funeral"),
  location = c("townA", "townA", "townA", "townB"),
  infection_proba = list(normal = 0.2, funeral = 0.8),
  last_visit = today - c(2, 2, 1, 3)
)
ctd
ctd |> plot() + facet_wrap(~location, scales = "free_y")

incub <- dunif(1:7, min = 1, max = 7)
ctscore(ctd, incub, today)

sim <- sim_ctdata()
sim |> plot()


sim <- sim_ctdata(
  n_contacts = 10,
  duration = 30,
  incub = 1:10,
  n_exposures = list(townA = 1:2, townB = 3:4),
  infection_proba = list(funeral = 0.8, normal = 0.2),
  locations = list(townA = 0.7, townB = 0.3)
)

sim |> plot() + facet_wrap(~location, scales = "free_y")

ids <- sim |>
  dplyr::group_by(contact_id) |>
  dplyr::summarise(n_exposures = dplyr::n()) |>
  dplyr::filter(n_exposures > 1) |>
  dplyr::pull(contact_id)

sim |>
  dplyr::filter(contact_id %in% ids) |>
  head()

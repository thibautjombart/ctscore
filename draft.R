devtools::load_all()
incub <- distcrete::distcrete(
  "gamma",
  shape = 4,
  scale = 1.5,
  w = 0.5,
  interval = 1
)
today <- Sys.Date()
ctd <- make_ctdata(
  contact_id = c(1, 1, 2, 3),
  date = today - c(9, 6, 7, 8),
  type = c("normal", "funeral", "normal", "funeral"),
  location = c("townA", "townA", "townA", "townB"),
  infection_proba = list(normal = 0.2, funeral = 0.8),
  last_visit = today - c(2, 2, 1, 3)
)
ctd
ctscore(ctd, incub, today)


score_contact <- function(d, t) {
  calculate_ctscore(
    p_inf = d$p_infection,
    e = as.numeric(d$date),
    s = as.numeric(max(d$last_visit)), #fix here
    t = as.numeric(t),
    incub = process_incub(incub)
  )
}

scores <- vapply(
  split(ctd, ctd$contact_id),
  score_contact,
  numeric(1),
  t = today
)
scores


# ------------------------------------
#           TEST simulate_ct()
# ------------------------------------
library(ggplot2)
devtools::load_all()

sim <- simulate_ct(
  n_contacts = 20,
  duration = 30,
  n_exposures = 1L + rpois(1000L, 1),
  p_inf = list(default = 0.2, funeral = 0.8),
  incub = 1L + rpois(1000L, 15),
  locations = list(townA = 0.7, townB = 0.3),
  coverage = list(townA = 0.8, townB = 0.5),
  followup_delay = 1L + rpois(1000L, 3)
)

plot(sim)
plot(sim) + ggplot2::facet_wrap(~location, nrow = 2, scales = "free_y")


ids <- sim |>
  dplyr::group_by(contact_id) |>
  dplyr::summarise(n_exposures = dplyr::n()) |>
  dplyr::filter(n_exposures > 1) |>
  pull(contact_id)

sim |>
  dplyr::filter(contact_id %in% ids) |>
  head()

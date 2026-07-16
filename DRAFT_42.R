# Make ctdata a list of 2 data.frames :

# $exposures: exposure data
# $linelist: data on individuals
# use tibbles as we'll need to record vectors of dates of visits in followup simulations

devtools::load_all()
x <- make_ctdata(
  contact_id = c(1, 1, 2, 3),
  date = Sys.Date() - c(6, 4, 2, 2),
  type = c("normal", "funeral", "normal", "normal"),
  location = "some-town",
  infection_proba = list(normal = 0.2, funeral = 0.9),
  last_visit = Sys.Date() - c(4, 4, 1, NA)
)
x
class(x)
contact_id <- c(1, 1, 2, 3)
date <- Sys.Date() - c(6, 4, 2, 2)
type <- c("normal", "funeral", "normal", "normal")
location <- "some-town"
infection_proba <- list(normal = 0.2, funeral = 0.9)
last_visit <- Sys.Date() - c(4, 4, 1, NA)
infected <- NA
onset <- NA_real_
vaccinated <- c(TRUE, FALSE, FALSE)


# make_ctdata(
#   exposures,                       # contact_id, date, type (+ any extra exposure cols)
#   linelist = NULL,                 # contact_id, location, last_visit, infected, onset (+ extras)
#                                    #   default: one NA-filled row per contact_id in exposures
#   infection_proba = list(default = 0)
# )

# # minimal (linelist auto-derived, all-NA):
# make_ctdata(
#   exposures = tibble(contact_id = c(1,1,2,3), date = ..., type = ...),
#   infection_proba = list(normal = 0.2, funeral = 0.9)
# )
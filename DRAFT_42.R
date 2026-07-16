make_ctdata(
  exposures,                       # contact_id, date, type (+ any extra exposure cols)
  linelist = NULL,                 # contact_id, location, last_visit, infected, onset (+ extras)
                                   #   default: one NA-filled row per contact_id in exposures
  infection_proba = list(default = 0)
)

# # minimal (linelist auto-derived, all-NA):
# make_ctdata(
#   exposures = tibble(contact_id = c(1,1,2,3), date = ..., type = ...),
#   infection_proba = list(normal = 0.2, funeral = 0.9)
# )
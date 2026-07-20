## Generate the package's toy contact-tracing dataset.
##
## Produces two xlsx files under inst/ (loaded in examples/README via
## system.file(), and split to match make_ctdata()'s two-table input):
##   - toy_exposures.xlsx : one row per exposure  (contact_id, date, type)
##   - toy_linelist.xlsx  : one row per contact   (contact_id, location,
##                          last_visit_date, infected, onset_date)
##
## The data is simulated with sim_ctdata() + a random follow-up, tuned via a
## fixed seed to resemble the original hand-made toy_ctdata.xlsx: 30 contacts,
## 46 exposures over 30 days, ~half infected, ~half followed up, two exposure
## types (household / funeral) and three locations. Unlike the original, the
## simulated data is internally consistent (onset_date implies infected).
##
## Run from the package root:  source("data-raw/toy_data.R")

library(dplyr)
library(writexl)
devtools::load_all() # for sim_ctdata() and sim_followup()

## exposures per contact: mostly singletons, a few multi-exposure contacts
nexp <- c(rep(1, 9), 2, 2, 3, 4)

set.seed(47)
x <- sim_ctdata(
  n_contacts = 30,
  duration = 30,
  incub = 1:7,
  locations = list(hotspot = 0.4, local_town = 0.3, new_city = 0.3),
  n_exposures = list(hotspot = nexp, local_town = nexp, new_city = nexp),
  infection_proba = list(household = 0.2, funeral = 0.9),
  type_proba = list(household = 0.5, funeral = 0.5)
) |>
  sim_followup(coverage = 0.10, delay = 1, duration = 5, strategy = "random")

## keep only the columns of the original toy dataset
## (drop infection_proba, infection_date, detection_date)
exposures <- x$exposures |>
  transmute(contact_id = as.integer(contact_id), date, type) |>
  arrange(contact_id, date)

linelist <- x$linelist |>
  transmute(
    contact_id = as.integer(contact_id),
    location, last_visit_date, infected, onset_date
  ) |>
  arrange(contact_id)

write_xlsx(exposures, "inst/toy_exposures.xlsx")
write_xlsx(linelist, "inst/toy_linelist.xlsx")

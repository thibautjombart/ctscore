# Show that ctscore changes with last_visit dates.
# (exposures must be old enough that symptom onset could plausibly have happened)

devtools::load_all()
library(tibble)

# 3 contacts, each with one exposure ~7 days ago
exposures <- tibble(
  contact_id = c(1, 2, 3),
  date       = Sys.Date() - c(7, 6, 8),
  type       = c("normal", "funeral", "normal")
)

# Gamma with a mean of 5.5
incub <- distcrete::distcrete("gamma", interval = 1, shape = 3, scale = 2, w = 0)

# same exposures, two different last_visit histories
linelistA <- tibble(contact_id = c(1, 2, 3), last_visit = as.Date(NA))     # never visited
linelistB <- tibble(contact_id = c(1, 2, 3), last_visit = Sys.Date() - 1)  # seen yesterday

A <- make_ctdata(exposures, linelistA, infection_proba = list(normal = 0.2, funeral = 0.9))
B <- make_ctdata(exposures, linelistB, infection_proba = list(normal = 0.2, funeral = 0.9))

ctscore(A, incub)   # never visited  -> higher
ctscore(B, incub)   # seen yesterday -> lower

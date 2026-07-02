## =====================================================================
## simulate_ct() returns the latent truth (infection status and onset day)
## alongside the observed history used for scoring. We score every simulated
## contact with the SAME incubation period and infection probabilities
## used to simulate them, treat the score as a predicted detection probability,
## and compare it with the realised outcome.
## =====================================================================
devtools::load_all()
library(tidyverse)
set.seed(123)

## ---------------------------------------------------------------------
##  Simulation parameters
## ---------------------------------------------------------------------
n_contacts <- 1000
n_rep <- 100
duration <- 30
today <- duration + 1L # evaluation day t
p_inf <- list(household = 0.2, funeral = 0.8) # per-exposure infection proba
incub <- distcrete::distcrete("pois", lambda = 11, w = 0.5, interval = 1)

## ---------------------------------------------------------------------
##  Simulate, score, and record the realised outcome
## ---------------------------------------------------------------------
## Y = 1 if the contact was infected and its onset falls in (s, today]; i.e. a
## follow-up visit on `today` would detect it as a new case.
one_rep <- function(rep) {
  simulate_ct(
    n_contacts = n_contacts,
    duration = duration,
    p_inf = p_inf,
    incub = incub$r(1000L)
  ) |>
    mutate(rep = rep) |>
    summarise(
      score = calculate_ctscore(
        p_inf = p_infection,
        e = date,
        s = last_visit[1],
        t = today,
        incub = process_incub(incub)
      ),
      # the contact was infected and their onset falls in the interval (last_visit, today].
      y = infected[1] & date_onset[1] > last_visit[1] & date_onset[1] <= today,
      .by = c(rep, contact_id)
    )
}

res <- map_dfr(seq_len(n_rep), one_rep)

# library(furrr)
# plan(multisession, workers = availableCores() - 2)
# res <- furrr::future_map(
#   1:n_rep,
#   one_rep,
#   .progress = TRUE,
#   .options = furrr::furrr_options(seed = TRUE)
# ) |>
#   bind_rows() |>
#   pipetime::time_pipe("simulation")

## ---------------------------------------------------------------------
## Bias and calibration checks
## ---------------------------------------------------------------------
## The group score is the expected number of detections.
bias <- res |>
  summarise(pred = sum(score), obs = sum(y), .by = rep) |>
  summarise(
    mean_pred = mean(pred),
    mean_obs = mean(obs),
    mean_bias = mean(pred - obs),
    se_bias = sd(pred - obs) / sqrt(n()),
    rel_bias = mean(pred - obs) / mean(obs)
  )
print(bias)


# Sort every contact by its score and bin them into 10 groups of equal size.
# For each bin, calculate the mean predicted score and the observed detection rate,
# along with the standard error of the observed rate.
calib <- res |>
  mutate(bin = ntile(score, 10)) |>
  summarise(
    pred = mean(score),
    obs = mean(y),
    n = n(),
    se = sqrt(mean(y) * (1 - mean(y)) / n()),
    .by = bin
  ) |>
  arrange(bin)

p_calib <- ggplot(calib, aes(pred, obs)) +
  geom_abline(linetype = 2, colour = "grey50") +
  geom_errorbar(
    aes(ymin = obs - 1.96 * se, ymax = obs + 1.96 * se),
    width = 0
  ) +
  geom_point() +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  labs(
    x = "Mean predicted score",
    y = "Observed detection rate",
  ) +
  theme_classic()
p_calib

## ---------------------------------------------------------------------
## ROC curve
## ---------------------------------------------------------------------
# roc per rep
roc_rep <- res |>
  arrange(desc(score)) |>
  mutate(
    tpr = cumsum(y) / sum(y),
    fpr = cumsum(!y) / sum(!y),
    .by = rep
  )

p_roc_rep <- ggplot(roc_rep, aes(fpr, tpr, group = rep)) +
  geom_abline(linetype = 2, colour = "grey50") +
  geom_line(alpha = 0.5) +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  theme_classic()
p_roc_rep

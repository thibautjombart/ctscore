# Simulate contact tracing data

Simulate contact tracing data for a set of contacts. Each contact has
one or more exposures, each with a probability of causing infection.
Infected contacts develop symptoms after an incubation period.

## Usage

``` r
sim_ctdata(
  n_contacts = 100,
  duration = 30,
  incub = 1:7,
  n_exposures = list(default = 1),
  infection_proba = list(default = 0.1),
  locations = list(default = 1)
)
```

## Arguments

- n_contacts:

  Number of contacts to simulate.

- duration:

  Length of the exposure period (days).

- incub:

  Integer vector of incubation periods (days), sampled with replacement.

- n_exposures:

  Named list giving the number of exposures per contact for each
  location.

- infection_proba:

  Named list giving the probability of infection for each exposure type.

- locations:

  Named list giving the probability of each location being sampled for a
  contact.

## Value

An object of class `c("sim_ctdata", "ctdata", "data.frame")` with one
row per exposure. It carries the standard `ctdata` columns
(`contact_id`, `date`, `type`, `location`, `last_visit`, `p_infection`)
plus the simulation truth `infected` (logical, per contact) and `onset`
(symptom onset day, `NA` when not infected).

## See also

[`make_ctdata()`](thibautjombart.github.io/ctscore/reference/make_ctdata.md),
which builds the `ctdata` core, and
[`ctscore()`](thibautjombart.github.io/ctscore/reference/ctscore.md).

## Author

Cyril Geismar

# Simulate contact tracing data

Simulate contact tracing data for a set of contacts. A contact has one
or more exposures, each with a probability of causing infection.
Infected contacts develop symptoms after an incubation period.

## Usage

``` r
sim_ctdata(
  n_contacts = 100,
  duration = 30,
  incub = 1:7,
  locations = list(default = 1),
  n_exposures = list(default = 1),
  infection_proba = list(default = 0.1),
  type_proba = NULL
)
```

## Arguments

- n_contacts:

  Number of contacts to simulate.

- duration:

  Length of the exposure period (days).

- incub:

  Integer vector of incubation periods (days), sampled with replacement.

- locations:

  Named list giving the probability of each location being assigned to a
  contact. Names must match `n_exposures`.

- n_exposures:

  Named list giving the number of exposures per contact for each
  location. Names must match `locations`.

- infection_proba:

  Named list giving the probability of infection for each exposure type.
  Names must match `type_proba`.

- type_proba:

  Named list giving the relative probability of each exposure type.
  Names must match `infection_proba`. Defaults to uniform.

## Value

An object of class `c("sim_ctdata", "ctdata", "data.frame")` with one
row per exposure. Alongside the standard `ctdata` columns it carries the
simulation ground truth, constant within each contact: `infected`
(logical), `infection_date` (day of the infecting exposure, `NA` if not
infected), and `onset` (= `infection_date` + incubation, `NA` if not
infected).

## See also

[`make_ctdata()`](thibautjombart.github.io/ctscore/reference/make_ctdata.md)
to create a `ctdata` object from real data.

## Author

Cyril Geismar

## Examples

``` r
x <- sim_ctdata(
 n_contacts = 10,
duration = 30,
incub = 1:7,
locations = list(cityA = 0.8, cityB = 0.2),
n_exposures = list(cityA = 2, cityB = c(2,2,3,4,5,10)),
infection_proba = list(household = 0.2, funeral = 0.4),
type_proba = list(household = 0.7, funeral = 0.3)
)
head(x)
#>   contact_id date      type location last_visit infected onset infection_date
#> 1          1    3   funeral    cityA         NA    FALSE    NA             NA
#> 2          1   25 household    cityA         NA    FALSE    NA             NA
#> 3         10    2 household    cityA         NA     TRUE     6              2
#> 4         10   24   funeral    cityA         NA     TRUE     6              2
#> 5          2    6 household    cityA         NA     TRUE    16              9
#> 6          2    9   funeral    cityA         NA     TRUE    16              9
#>   infection_proba
#> 1             0.4
#> 2             0.2
#> 3             0.2
#> 4             0.4
#> 5             0.2
#> 6             0.4
class(x)
#> [1] "sim_ctdata" "ctdata"     "data.frame"
```

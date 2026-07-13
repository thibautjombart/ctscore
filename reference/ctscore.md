# Calculate contact tracing score

This function calculates the probability of detecting symptoms in a
contact on a given day given their exposure and follow-up history, as
described in Jombart et al. 2026.

## Usage

``` r
ctscore(
  x,
  incub,
  current_date = Sys.Date(),
  out_type = c("vector", "data.frame", "ctdata", "ctdata_full")
)
```

## Arguments

- x:

  a `ctdata` object as returned by
  [`make_ctdata()`](thibautjombart.github.io/ctscore/reference/make_ctdata.md)

- incub:

  the incubation period distribution; can be provided as a vector of
  probabilities giving p(0 day), p(1 day), p(2 days) ... or as a
  `distcrete` object as returned by distcrete::distcrete()

- current_date:

  the current date, provided either as a `numeric` value or as a `Date`;
  defaults to the current date as returned by
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html)

- out_type:

  a `character` indicating the type of output to return; can be either
  "vector" (default) to return a named vector of scores, "data.frame" to
  return a data frame with contact IDs and scores, "ctdata" to return a
  `ctdata` object with individual data and scores, or "ctdata_full" to
  append scores to the original `ctdata` of exposure data

## Value

A named numeric vector giving the probability of detecting symptoms for
each contact, with names corresponding to the contact IDs.

## Author

Thibaut Jombart

## Examples

``` r
## make dummy contact tracing data
x <- make_ctdata(
  contact_id = c(1, 1, 2, 3, 4), 
  date = Sys.Date() - c(6, 4, 5, 1, 5),
  type = c("normal", "funeral", "normal", "normal", "null"),
  location = "some-town",
  infection_proba = list(normal = 0.2, funeral = 0.9, null = 0),
  last_visit = Sys.Date() - c(4, 2, 1, 1, 3)
)

## make a dummy incubation time distribution, specifying the PMF from 0 to 
## 7 days here
incub <- c(0, 0, 1, 2, 4, 3, 2, 1)

## get results
res <- ctscore(x, incub)
res
#>         1         2         3         4 
#> 0.5266667 0.1000000 0.0000000 0.0000000 

## other useful shape for results: a ctdata object of individuals data with 
## scores appended
res <- ctscore(x, incub, out_type = "ctdata")
res
#>   contact_id  location last_visit infected onset     score
#> 1          1 some-town 2026-07-09       NA    NA 0.5266667
#> 3          2 some-town 2026-07-12       NA    NA 0.1000000
#> 4          3 some-town 2026-07-12       NA    NA 0.0000000
#> 5          4 some-town 2026-07-10       NA    NA 0.0000000

## other example using `distcrete` to build the incubation time distribution
incub <- distcrete::distcrete("gamma", interval = 1, shape = 2, scale = 2.5, w = 0)
res <- ctscore(x, incub)
res
#>          1          2          3          4 
#> 0.36501065 0.04806079 0.02763199 0.00000000 

## trying other output shapes
### data.frame with individual data
res_df <- ctscore(x, incub, out_type = "data.frame")
res_df
#>   contact_id      score
#> 1          1 0.36501065
#> 2          2 0.04806079
#> 3          3 0.02763199
#> 4          4 0.00000000

### ctdata object of individuals with scores appended
res_ctdata <- ctscore(x, incub, out_type = "ctdata")
res_ctdata
#>   contact_id  location last_visit infected onset      score
#> 1          1 some-town 2026-07-09       NA    NA 0.36501065
#> 3          2 some-town 2026-07-12       NA    NA 0.04806079
#> 4          3 some-town 2026-07-12       NA    NA 0.02763199
#> 5          4 some-town 2026-07-10       NA    NA 0.00000000


### same, with all original exposure data
res_ctdata_full <- ctscore(x, incub, out_type = "ctdata_full")
res_ctdata_full
#>   contact_id       date    type  location last_visit infected onset
#> 1          1 2026-07-07  normal some-town 2026-07-09       NA    NA
#> 2          1 2026-07-09 funeral some-town 2026-07-11       NA    NA
#> 3          2 2026-07-08  normal some-town 2026-07-12       NA    NA
#> 4          3 2026-07-12  normal some-town 2026-07-12       NA    NA
#> 5          4 2026-07-08    null some-town 2026-07-10       NA    NA
#>   infection_proba      score
#> 1             0.2 0.36501065
#> 2             0.9 0.36501065
#> 3             0.2 0.04806079
#> 4             0.2 0.02763199
#> 5             0.0 0.00000000
```

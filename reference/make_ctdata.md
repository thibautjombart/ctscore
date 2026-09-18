# Build a ctdata object

Builds a `ctdata` object from two tables: `exposures` (one row per
exposure) and an optional `linelist` (one row per contact). Both are
keyed by `contact_id`.

## Usage

``` r
make_ctdata(exposures, linelist = NULL, infection_proba = list(default = 0))
```

## Arguments

- exposures:

  a `data.frame` of exposures, one row per exposure. Must contain
  `contact_id`, `date` and `exposure_type`; any extra columns are kept
  as exposure-level data. `date` may be `Date`, numeric, or character
  (converted with `as.Date`).

- linelist:

  an optional `data.frame` of individual-level data. Must contain
  `contact_id` and may contain `location`, `last_visit_date`,
  `infected`, `onset_date`, plus any extra columns. `last_visit_date`
  and `onset_date` may be `Date` or numeric.

- infection_proba:

  a named `list` giving the probability of infection for each
  `exposure_type`; names must match the types present in `exposures`.

## Value

A `ctdata` object: a `list` of three tibbles :

- `linelist`: individual-level data.

- `exposures`: exposure-level data.

- `risk`: infection probabilities for each exposure type.

## See also

[`sim_ctdata()`](thibautjombart.github.io/ctscore/reference/sim_ctdata.md)
to simulate contact tracing data.

## Author

Thibaut Jombart / Cyril Geismar

## Examples

``` r
x <- make_ctdata(
  exposures = tibble::tibble(
    contact_id = c(1, 1, 2, 3),
    date = Sys.Date() - c(6, 4, 2, 2),
    exposure_type = c("normal", "funeral", "normal", "normal")
  ),
  linelist = tibble::tibble(
    contact_id = c(1, 2, 3),
    location = "some-town",
    last_visit_date = Sys.Date() - c(4, 1, NA)
  ),
  infection_proba = list(normal = 0.2, funeral = 0.9)
)
x
#> <ctdata>: 3 contact(s), 4 exposure(s), 2 exposure type(s)
#> 
#> $linelist
#> # A tibble: 3 × 5
#>   contact_id location  last_visit_date infected onset_date
#>   <chr>      <chr>     <date>          <lgl>    <date>    
#> 1 1          some-town 2026-09-14      NA       NA        
#> 2 2          some-town 2026-09-17      NA       NA        
#> 3 3          some-town NA              NA       NA        
#> 
#> $exposures
#> # A tibble: 4 × 3
#>   contact_id date       exposure_type
#>   <chr>      <date>     <chr>        
#> 1 1          2026-09-12 normal       
#> 2 1          2026-09-14 funeral      
#> 3 2          2026-09-16 normal       
#> 4 3          2026-09-16 normal       
#> 
#> $risk
#> # A tibble: 2 × 2
#>   exposure_type infection_proba
#>   <chr>                   <dbl>
#> 1 funeral                   0.9
#> 2 normal                    0.2
class(x)
#> [1] "ctdata"
```

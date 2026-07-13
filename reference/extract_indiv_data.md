# Extract individual data from a `ctdata` object

`ctdata` objects are used to store exposure data; as contacts may report
multiple exposures, the corresponding individual data (e.g. location,
data of last visit) are repeated. This function extracts individual data
so that the output has a single row for each individual, effectively
stripping exposure data.

## Usage

``` r
extract_indiv_data(x)
```

## Arguments

- x:

  a `ctdata` object as returned by
  [`make_ctdata()`](thibautjombart.github.io/ctscore/reference/make_ctdata.md)
  or
  [`sim_ctdata()`](thibautjombart.github.io/ctscore/reference/sim_ctdata.md)

## Author

Thibaut Jombart

## Examples

``` r
## with a simple ctdata
x <- make_ctdata(
  contact_id = c(1, 1, 2, 3, 3), 
  date = Sys.Date() - c(6, 4, 2, 2, 3),
  type = c("normal", "funeral", "normal", "normal", "funeral"),
  location = c("some-town", "some-town", "some-town", "sincity", "sincity"),
  infection_proba = list(normal = 0.2, funeral = 0.9),
  last_visit = Sys.Date() - c(4, 4, 1, NA, NA)
)
x
#>   contact_id       date    type  location last_visit infected onset
#> 1          1 2026-07-07  normal some-town 2026-07-09       NA    NA
#> 2          1 2026-07-09 funeral some-town 2026-07-09       NA    NA
#> 3          2 2026-07-11  normal some-town 2026-07-12       NA    NA
#> 4          3 2026-07-10 funeral   sincity       <NA>       NA    NA
#> 5          3 2026-07-11  normal   sincity       <NA>       NA    NA
#>   infection_proba
#> 1             0.2
#> 2             0.9
#> 3             0.2
#> 4             0.9
#> 5             0.2

extract_indiv_data(x)
#>   contact_id  location last_visit infected onset
#> 1          1 some-town 2026-07-09       NA    NA
#> 3          2 some-town 2026-07-12       NA    NA
#> 4          3   sincity       <NA>       NA    NA

## with a ctdata object containing scores (returned by ctscore())
scores <- ctscore(x, 
  incub = c(0, 0, 1, 2, 4, 3, 2, 1), 
  current_date = Sys.Date(), 
  out_type = "ctdata"
)

scores
#>   contact_id  location last_visit infected onset      score
#> 1          1 some-town 2026-07-09       NA    NA 0.57102564
#> 3          2 some-town 2026-07-12       NA    NA 0.01538462
#> 4          3   sincity       <NA>       NA    NA 0.20923077
extract_indiv_data(scores)
#>   contact_id  location last_visit infected onset      score
#> 1          1 some-town 2026-07-09       NA    NA 0.57102564
#> 3          2 some-town 2026-07-12       NA    NA 0.01538462
#> 4          3   sincity       <NA>       NA    NA 0.20923077
```

# Build a ctdata object

This constructor will build a `ctdata` object from different inputs
describing past exposures and follow-up history for different
individuals.

## Usage

``` r
make_ctdata(
  contact_id,
  date,
  type = "default",
  location = "default",
  infection_proba = list(default = 0),
  last_visit
)
```

## Arguments

- contact_id:

  a `character` or a `numeric` vector indicating identifiers for the
  contacts; will be converted to `character` if not already

- date:

  a `Date`, `numeric`, or `character` vector indicating dates of
  exposures; `character` will be converted to `Date` using `as.Date`,
  with expected formats "%Y-%m-%d" or "%Y/%m/%d"; fancier conversions
  should be done before creating a `ctdata` object

- type:

  a `character` used to describe the type of exposure; defaults to
  `default`

- location:

  a `character` used to describe the geographic location of the contact;
  defaults to `default`

- infection_proba:

  a `list` of named numeric values, each indicating the probability of
  infection for a given contact; defaults to a list with 'default'
  exposure having a probability of infection of 0

- last_visit:

  the date of the last visit to the contact, where they exhibited no
  symptoms; the type provided must match that of `date`; if the contact
  has not been visited yet, this should be `NA`

## Value

A `ctdata` object, which is a validated and ordered (by contact ID and
date of exposure) `data.frame` designed to be used in the
[ctscore](thibautjombart.github.io/ctscore/reference/ctscore.md)
function.

## Author

Thibaut Jombart

## Examples

``` r

x <- make_ctdata(
  contact_id = c(1, 1, 2, 3), 
  date = Sys.Date() - c(6, 4, 2, 2),
  type = c("normal", "funeral", "normal", "normal"),
  location = "some-town",
  infection_proba = list(normal = 0.2, funeral = 0.9),
  last_visit = Sys.Date() - c(4, 4, 1, NA)
)
x
#>   contact_id       date    type  location last_visit p_infection
#> 1          1 2026-07-01  normal some-town 2026-07-03         0.2
#> 2          1 2026-07-03 funeral some-town 2026-07-03         0.9
#> 3          2 2026-07-05  normal some-town 2026-07-06         0.2
#> 4          3 2026-07-05  normal some-town       <NA>         0.2
class(x)
#> [1] "ctdata"     "data.frame"
```

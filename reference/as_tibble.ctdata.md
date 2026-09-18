# Coerce a `ctdata` object to a tibble

Two formats are available:

- `by_contact = FALSE` (default): one row per exposure, with
  contact-level `linelist` columns added to each row.

- `by_contact = TRUE`: one row per contact, with exposures stored in a
  nested `exposures` list-column containing `date`, `exposure_type`, and
  `infection_proba`.

## Usage

``` r
# S3 method for class 'ctdata'
as_tibble(x, ..., by_contact = FALSE)
```

## Arguments

- x:

  a `ctdata` object

- ...:

  ignored

- by_contact:

  `logical`; return one row per contact with nested exposures (`TRUE`),
  or one row per exposure (`FALSE`, default)

## Value

A tibble.

## Examples

``` r
x <- sim_ctdata(5)
as_tibble(x) # flat: one row per exposure
#> # A tibble: 5 × 9
#>   contact_id  date exposure_type infection_proba location last_visit_date
#>   <chr>      <int> <chr>                   <dbl> <chr>              <dbl>
#> 1 1              5 default                   0.1 default               NA
#> 2 2              2 default                   0.1 default               NA
#> 3 3              5 default                   0.1 default               NA
#> 4 4              6 default                   0.1 default               NA
#> 5 5              3 default                   0.1 default               NA
#> # ℹ 3 more variables: infected <lgl>, onset_date <dbl>, infection_date <dbl>
as_tibble(x, by_contact = TRUE) # nested: one row per contact
#> # A tibble: 5 × 7
#>   contact_id location last_visit_date infected onset_date infection_date
#>   <chr>      <chr>              <dbl> <lgl>         <dbl>          <dbl>
#> 1 1          default               NA FALSE            NA             NA
#> 2 2          default               NA FALSE            NA             NA
#> 3 3          default               NA FALSE            NA             NA
#> 4 4          default               NA FALSE            NA             NA
#> 5 5          default               NA TRUE              8              3
#> # ℹ 1 more variable: exposures <list>
```

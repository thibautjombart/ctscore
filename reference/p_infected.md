# Calculate the probability of infection

This function calculates the probability of a contact having been
infected given prior exposures, as described in Jombart et al. 2026.
Unlike
[`ctscore()`](thibautjombart.github.io/ctscore/reference/ctscore.md), it
requires only exposure data, and no information on follow-up history or
incubation period.

## Usage

``` r
p_infected(x)
```

## Arguments

- x:

  a `ctdata` object as returned by
  [`make_ctdata()`](thibautjombart.github.io/ctscore/reference/make_ctdata.md)

## Value

A named numeric vector giving the probability of infection for each
contact, named by contact ID. Use
[`add_p_infected()`](thibautjombart.github.io/ctscore/reference/add_p_infected.md)
to attach these results to the `linelist` of the source `ctdata`.

## See also

[`add_p_infected()`](thibautjombart.github.io/ctscore/reference/add_p_infected.md)
to attach the results back onto the `ctdata`.

## Author

Thibaut Jombart

## Examples

``` r
## create ctdata
x <- make_ctdata(
  exposures = tibble::tibble(
    contact_id = c(1, 1, 2, 3, 4),
    date = Sys.Date() - c(6, 4, 5, 1, 5),
    exposure_type = c("normal", "funeral", "normal", "normal", "null")
  ),
  linelist = tibble::tibble(
    contact_id = c(1, 2, 3, 4),
    last_visit_date = Sys.Date() - c(2, 1, 1, 3)
  ),
  infection_proba = list(normal = 0.2, funeral = 0.9, null = 0)
)

## a named vector of proba of infection
p_inf <- p_infected(x)
p_inf
#>    1    2    3    4 
#> 0.92 0.20 0.20 0.00 

## attach the scores to the ctdata linelist
x <- add_p_infected(x, p_inf)
x
#> <ctdata>: 4 contact(s), 5 exposure(s), 3 exposure type(s)
#> 
#> $linelist
#> # A tibble: 4 × 6
#>   contact_id location last_visit_date infected onset_date p_infected
#>   <chr>      <chr>    <date>          <lgl>    <date>          <dbl>
#> 1 1          NA       2026-09-16      NA       NA               0.92
#> 2 2          NA       2026-09-17      NA       NA               0.2 
#> 3 3          NA       2026-09-17      NA       NA               0.2 
#> 4 4          NA       2026-09-15      NA       NA               0   
#> 
#> $exposures
#> # A tibble: 5 × 3
#>   contact_id date       exposure_type
#>   <chr>      <date>     <chr>        
#> 1 1          2026-09-12 normal       
#> 2 1          2026-09-14 funeral      
#> 3 2          2026-09-13 normal       
#> 4 3          2026-09-17 normal       
#> 5 4          2026-09-13 null         
#> 
#> $risk
#> # A tibble: 3 × 2
#>   exposure_type infection_proba
#>   <chr>                   <dbl>
#> 1 funeral                   0.9
#> 2 normal                    0.2
#> 3 null                      0  
```

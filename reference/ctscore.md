# Calculate contact tracing score

This function calculates the probability of detecting symptoms in a
contact on a given day given their exposure and follow-up history, as
described in Jombart et al. 2026.

## Usage

``` r
ctscore(x, incub, current_date = Sys.Date())
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

## Value

A named numeric vector giving the probability of detecting symptoms for
each contact, named by contact ID. Use
[`add_ctscore()`](thibautjombart.github.io/ctscore/reference/add_ctscore.md)
to attach these scores to the `linelist` of the source `ctdata`.

## See also

[`add_ctscore()`](thibautjombart.github.io/ctscore/reference/add_ctscore.md)
to attach the scores back onto the `ctdata`, and
[`p_infected()`](thibautjombart.github.io/ctscore/reference/p_infected.md)
and
[`add_p_infected()`](thibautjombart.github.io/ctscore/reference/add_p_infected.md)
to calculate the probability of infection for each contact.

## Author

Thibaut Jombart

## Examples

``` r
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

## incubation time PMF from day 0 to 7
incub <- c(0, 0, 1, 2, 4, 3, 2, 1)

## a named vector of scores
score <- ctscore(x, incub)
score
#>         1         2         3         4 
#> 0.5266667 0.1000000 0.0000000 0.0000000 

## attach the scores to the ctdata linelist
res <- add_ctscore(x, score)

## do the same with probabilities of infection for each contact
## this can be useful for informing post exposure prophylaxis (PEP)
p_inf <- p_infected(x)
res <- add_p_infected(x, res)
res
#> <ctdata>: 4 contact(s), 5 exposure(s), 3 exposure type(s)
#> 
#> $linelist
#> # A tibble: 4 × 6
#>   contact_id location last_visit_date infected onset_date p_infected
#>   <chr>      <chr>    <date>          <lgl>    <date>     <list>    
#> 1 1          NA       2026-09-16      NA       NA         <NULL>    
#> 2 2          NA       2026-09-17      NA       NA         <NULL>    
#> 3 3          NA       2026-09-17      NA       NA         <NULL>    
#> 4 4          NA       2026-09-15      NA       NA         <NULL>    
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

## incubation as a distcrete object
incub <- distcrete::distcrete("gamma", interval = 1, shape = 2, scale = 2.5, w = 0)
ctscore(x, incub)
#>          1          2          3          4 
#> 0.36501065 0.04806079 0.02763199 0.00000000 
```

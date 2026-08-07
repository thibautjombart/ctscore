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

A `ctdata` object.

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
  n_exposures = list(cityA = 2, cityB = c(2, 2, 3, 4, 5, 10)),
  infection_proba = list(household = 0.2, funeral = 0.4),
  type_proba = list(household = 0.7, funeral = 0.3)
)
head(x)
#> $linelist
#> # A tibble: 10 × 6
#>    contact_id location last_visit_date infected onset_date infection_date
#>    <chr>      <chr>              <dbl> <lgl>         <dbl>          <dbl>
#>  1 1          cityA                 NA TRUE              5              2
#>  2 10         cityA                 NA TRUE             22             20
#>  3 2          cityA                 NA FALSE            NA             NA
#>  4 3          cityA                 NA TRUE              6              1
#>  5 4          cityA                 NA FALSE            NA             NA
#>  6 5          cityA                 NA TRUE             23             22
#>  7 6          cityA                 NA TRUE             11              5
#>  8 7          cityA                 NA FALSE            NA             NA
#>  9 8          cityA                 NA TRUE              4              2
#> 10 9          cityA                 NA TRUE             35             30
#> 
#> $exposures
#> # A tibble: 20 × 3
#>    contact_id  date exposure_type
#>    <chr>      <int> <chr>        
#>  1 1              2 funeral      
#>  2 1             23 household    
#>  3 10            20 household    
#>  4 10            23 funeral      
#>  5 2              1 funeral      
#>  6 2              7 household    
#>  7 3              1 funeral      
#>  8 3              8 funeral      
#>  9 4              9 funeral      
#> 10 4             10 funeral      
#> 11 5             22 household    
#> 12 5             28 household    
#> 13 6              5 household    
#> 14 6             17 household    
#> 15 7              5 funeral      
#> 16 7             23 household    
#> 17 8              2 household    
#> 18 8             24 funeral      
#> 19 9             13 household    
#> 20 9             30 funeral      
#> 
#> $risk
#> # A tibble: 2 × 2
#>   exposure_type infection_proba
#>   <chr>                   <dbl>
#> 1 funeral                   0.4
#> 2 household                 0.2
#> 
class(x)
#> [1] "ctdata"
```

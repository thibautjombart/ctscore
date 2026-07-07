# Add/change infection probabilities in a ctdata object

This function can be used to add or change infection probabilities in a
`ctdata` object. It is useful for changing the probabilities of
infection for different types of exposures. Probabilities are provided
as a named `list` which must have one probability for each exposure type
in the `ctdata` object.

## Usage

``` r
add_infection_proba(x, proba)
```

## Arguments

- x:

  a `ctdata` object

- proba:

  a named `list` of probabilities for each exposure type

## Value

a `ctdata` object with updated infection probabilities

## Author

Thibaut Jombart

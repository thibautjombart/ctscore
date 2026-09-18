# Calculate the probability of infection from past exposures

Internal. Used to calculate the probability that an infection took place
at a given exposure, accounting for previous ones, for a single contact.
This function returns a vector of probabilities of infection for
different successive exposures, ordered by increasing date. To calculate
the overal probability that a contact has been infected given a series
of exposures, see the user-facing function
[`p_infected()`](thibautjombart.github.io/ctscore/reference/p_infected.md).

## Usage

``` r
calculate_p_infection(x)
```

## Arguments

- x:

  a vector of probabilities of infection for different successive
  exposures, ordered by increasing date

## Author

Thibaut Jombart

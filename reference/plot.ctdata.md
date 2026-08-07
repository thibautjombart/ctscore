# Plot a contact-tracing timeline

Produces a timeline plot of contact-tracing data, with one row per
contact along a time axis. Contacts are ordered by first exposure day.

## Usage

``` r
# S3 method for class 'ctdata'
plot(x, ...)
```

## Arguments

- x:

  a `ctdata` object.

- ...:

  currently ignored.

## Value

A `ggplot` object. Each contact's `linelist` columns (e.g. `location`)
are carried in the plot data, so the result can be extended with, for
example,
[`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
or [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html)
on them.

## Author

Cyril Geismar

## Examples

``` r
if (FALSE) { # \dontrun{
## simulated data (also shows infection date and symptom onset)
plot(sim_ctdata())

## facet by a linelist column
sim_ctdata(
  locations = list(cityA = 0.5, cityB = 0.5),
  n_exposures = list(cityA = 2, cityB = 3)
) |>
  plot() +
  ggplot2::facet_wrap(~location, scales = "free_y")
} # }
```

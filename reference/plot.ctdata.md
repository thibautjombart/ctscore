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

  a `ctdata` object returned by
  [`make_ctdata()`](thibautjombart.github.io/ctscore/reference/make_ctdata.md),
  or a `sim_ctdata` object returned by
  [`sim_ctdata()`](thibautjombart.github.io/ctscore/reference/sim_ctdata.md).

- ...:

  currently ignored.

## Value

A `ggplot` object.

## Author

Cyril Geismar

## Examples

``` r
if (FALSE) { # \dontrun{
## simulated data (also shows infection date and symptom onset)
plot(sim_ctdata())

} # }
```

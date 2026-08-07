# Coerce a `ctdata` object to a flat data frame

The base-R equivalent of `as_tibble(x, by_contact = FALSE)`: an
exposure-level `data.frame` with the `linelist` columns joined onto each
exposure row.

## Usage

``` r
# S3 method for class 'ctdata'
as.data.frame(x, ...)
```

## Arguments

- x:

  a `ctdata` object

- ...:

  ignored

## Value

A `data.frame` with one row per exposure.

# Attach ctscores to a ctdata linelist

Adds the per-contact scores returned by
[`ctscore()`](thibautjombart.github.io/ctscore/reference/ctscore.md) as
a `score` column of the `ctdata`'s `linelist`, matched by `contact_id`.

## Usage

``` r
add_ctscore(x, score)
```

## Arguments

- x:

  the `ctdata` object to which the scores should be added

- score:

  a named numeric vector of scores as returned by
  [`ctscore()`](thibautjombart.github.io/ctscore/reference/ctscore.md)

## Value

The `ctdata` object `x`, with a `score` column added to its `linelist`.

## See also

[`ctscore()`](thibautjombart.github.io/ctscore/reference/ctscore.md)

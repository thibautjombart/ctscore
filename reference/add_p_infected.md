# Attach probabilities of infections to a ctdata linelist

Adds the per-contact probabilities of infections returned by
[`p_infected()`](thibautjombart.github.io/ctscore/reference/p_infected.md)
as a `p_infected` column of the `ctdata`'s `linelist`, matched by

## Usage

``` r
add_p_infected(x, p_inf)
```

## Arguments

- x:

  the `ctdata` object to which the scores should be added

- p_inf:

  a named numeric vector of probabilities of infeciton as returned by
  [`p_infected()`](thibautjombart.github.io/ctscore/reference/p_infected.md)

## Value

The `ctdata` object `x`, with a `score` column added to its `linelist`.

## See also

[`p_infected()`](thibautjombart.github.io/ctscore/reference/p_infected.md)
to calculate the individual probabilities of infection, and
[`ctscore()`](thibautjombart.github.io/ctscore/reference/ctscore.md) and
[`add_ctscore()`](thibautjombart.github.io/ctscore/reference/add_ctscore.md)
for followup scores.

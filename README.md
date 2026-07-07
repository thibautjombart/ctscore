ctscore: Contact Tracing Scoring System
================

<!-- README.md is generated from README.Rmd. Please edit that file. -->
<!-- The code to render this README is stored in .github/workflows/render-readme.yaml -->
<!-- Variables marked with double curly braces will be transformed beforehand: -->
<!-- `packagename` is extracted from the DESCRIPTION file -->
<!-- `gh_repo` is extracted via a special environment variable in GitHub Actions -->

## Getting started

To install the package from github:

``` r
pak::pkg_install("thibautjombart/ctscore")
```

## Worked example

In the following, we read a toy dataset included in the package, which
contains simulated contact tracing data for 30 contacts. Each contact
has one or more exposures, some of which led to infection. Data are
stored inside an xlsx file distributed with the package, but in practice
you would read your own data from a csv or xlsx file.

``` r
library(ctscore)
library(rio)
library(magrittr)
library(tibble)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggplot2)

## use the path to your own file in practice 
path_to_file <- system.file("toy_ctdata.xlsx", package = "ctscore")

## read the data in
raw_data <- rio::import(path_to_file) %>% 
  tibble()

raw_data
#> # A tibble: 46 × 7
#>    contact_id  date type      location   last_visit infected onset
#>         <dbl> <dbl> <chr>     <chr>           <dbl> <lgl>    <dbl>
#>  1          1     5 household new_city           13 FALSE       NA
#>  2          2    13 funeral   new_city           27 FALSE       NA
#>  3          3     6 household local_town         NA FALSE       NA
#>  4          4     5 household new_city           NA FALSE       NA
#>  5          5    17 funeral   hotspot            22 TRUE        23
#>  6          5    18 household hotspot            22 TRUE        23
#>  7          5    21 household hotspot            22 TRUE        23
#>  8          6    15 funeral   local_town         NA FALSE       NA
#>  9          7     9 household local_town         NA FALSE       NA
#> 10          8    14 household hotspot            18 TRUE        24
#> # ℹ 36 more rows
```

Each row corresponds to a reported exposure. The file contains the
following information:

- `contact_id`: a unique identifier for each contact
- `date`: the date of exposure, indicated as an integer since the first
  exposure; in practice, this could be actual dates in the format
  YYYY-MM-DD
- `type`: the type of exposure; here, either “household” or “funeral”
- `location`: the location of the contact; here, either “new_city”,
  “local_town”, or “hotspot”; these would be actual names of places in
  practice
- `last_visit`: the date of the last visit to the contact, where they
  exhibited no symptoms; if the contact has not been visited yet, this
  is `NA`
- `infected`: the simulation truth, indicating whether the contact was
  infected or not; this is not known in practice, but is included here
  for demonstration purposes
- `onset`: the simulation truth, indicating the day of symptom onset for
  infected contacts; this may is not known in practice, but is included
  here for demonstration purposes

Now that we have imported the data into R, we need to convert them to a
`ctdata` object using `make_ctdata()` (see ?make_ctdata for details).

Infection probabilities (argument `infection_proba`) can be estimated
from previous contact tracing data, from the literature, or by expert
opinion. Here, we assume that household exposures have a 20% probability
of infection, while funeral exposures have a 90% probability of
infection.

``` r
x <- make_ctdata(
  contact_id = raw_data$contact_id,
  date = raw_data$date,
  type = raw_data$type,
  location = raw_data$location,
  infection_proba = list(household = 0.2, funeral = 0.9),
  last_visit = raw_data$last_visit
)

head(x)
#>   contact_id date      type   location last_visit p_infection
#> 1          1    5 household   new_city         13         0.2
#> 2         10   10 household local_town         NA         0.2
#> 3         11    2 household   new_city         NA         0.2
#> 4         12    7   funeral    hotspot          9         0.9
#> 5         13    9   funeral local_town          9         0.9
#> 6         13   15 household local_town          9         0.2
class(x)
#> [1] "ctdata"     "data.frame"
```

Smaller datasets can be visualised using `plot()`:

``` r
plot(x)
```

<img src="man/figures/README-unnamed-chunk-5-1.png" alt="" width="100%" />

Next, we need to specify incubation time distribution, which can be
provided either as a vector of probabilities (giving p(0 day), p(1 day),
p(2 days) …) or as a `distcrete` object as returned by
distcrete::distcrete(). Here, we generate a dummy incubation time
distribution as a discretized Gamma:

``` r
incub <- distcrete::distcrete(
  "gamma", 
  interval = 1, 
  shape = 3.5, 
  scale = 2.5, w = 0
)
plot(
  incub$d(0:30), type = "h", lwd = 6, lend = 1, 
  xlab = "Days since infection", 
  ylab = "Probability of symptom onset",
  main = "Incubation time distribution",
  col = 2
)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" alt="" width="100%" />

We can now calculate the `ctscore` using the `ctscore()` function, the
current date is day 31 (again, this could be a real date in practice, in
YYYY-MM-DD format):

``` r
score <- ctscore(x, incub, current_date = 31)
score
#>          1         10         11         12         13         14         15 
#> 0.19854218 0.19772316 0.20028407 0.89463558 0.90958819 0.97174690 0.19870824 
#>         16         17         18         19          2         20         21 
#> 0.22232470 0.19754793 0.74628901 0.10752694 0.60000140 0.01314619 0.14895995 
#>         22         23         24         25         26         27         28 
#> 0.79589928 0.28480854 0.88870951 0.19158821 0.82388155 0.62067571 0.18872827 
#>         29          3         30          4          5          6          7 
#> 0.05915784 0.19969489 0.89728078 0.19991568 0.79604599 0.84927722 0.19844927 
#>          8          9 
#> 0.83344774 0.19871356
```

`score` indicates, for each contact, the probability that a visit today
will lead to detecting a new case.

For convenience, we can ask `ctscore` to return results in two different
shapes:

- as a `data.frame` with contact IDs and scores, which is simpler to
  handle to prioritise individuals
- as a `ctdata` object with an additional column for the scores appended
  to the exposure database

``` r
## data.frame of individual scores, sorted by score
res <- ctscore(x, incub, current_date = 31, out_type = "data.frame") %>% 
    arrange(desc(score))
res
#>    contact_id      score
#> 14         14 0.97174690
#> 13         13 0.90958819
#> 30         30 0.89728078
#> 12         12 0.89463558
#> 24         24 0.88870951
#> 6           6 0.84927722
#> 8           8 0.83344774
#> 26         26 0.82388155
#> 5           5 0.79604599
#> 22         22 0.79589928
#> 18         18 0.74628901
#> 27         27 0.62067571
#> 2           2 0.60000140
#> 23         23 0.28480854
#> 16         16 0.22232470
#> 11         11 0.20028407
#> 4           4 0.19991568
#> 3           3 0.19969489
#> 9           9 0.19871356
#> 15         15 0.19870824
#> 1           1 0.19854218
#> 7           7 0.19844927
#> 10         10 0.19772316
#> 17         17 0.19754793
#> 25         25 0.19158821
#> 28         28 0.18872827
#> 21         21 0.14895995
#> 19         19 0.10752694
#> 29         29 0.05915784
#> 20         20 0.01314619

## ctdata object with scores appended, sorted by score
res_ctdata <- ctscore(x, incub, current_date = 31, out_type = "ctdata") %>% 
  arrange(desc(score))
res_ctdata
#>    contact_id date      type   location last_visit p_infection      score
#> 1          14    1 household    hotspot         15         0.2 0.97174690
#> 2          14   11   funeral    hotspot         15         0.9 0.97174690
#> 3          14   13   funeral    hotspot         15         0.9 0.97174690
#> 4          14   20 household    hotspot         15         0.2 0.97174690
#> 5          13    9   funeral local_town          9         0.9 0.90958819
#> 6          13   15 household local_town          9         0.2 0.90958819
#> 7          30    7   funeral local_town         NA         0.9 0.89728078
#> 8          12    7   funeral    hotspot          9         0.9 0.89463558
#> 9          24    8 household    hotspot         NA         0.2 0.88870951
#> 10         24   14   funeral    hotspot         NA         0.9 0.88870951
#> 11          6   15   funeral local_town         NA         0.9 0.84927722
#> 12          8   12 household    hotspot         18         0.2 0.83344774
#> 13          8   14 household    hotspot         18         0.2 0.83344774
#> 14          8   19   funeral    hotspot         18         0.9 0.83344774
#> 15          8   20 household    hotspot         18         0.2 0.83344774
#> 16         26   18 household   new_city         NA         0.2 0.82388155
#> 17         26   19   funeral   new_city         NA         0.9 0.82388155
#> 18         26   22   funeral   new_city         NA         0.9 0.82388155
#> 19          5   17   funeral    hotspot         22         0.9 0.79604599
#> 20          5   18 household    hotspot         22         0.2 0.79604599
#> 21          5   21 household    hotspot         22         0.2 0.79604599
#> 22         22    4   funeral   new_city         24         0.9 0.79589928
#> 23         18   17   funeral   new_city         23         0.9 0.74628901
#> 24         18   30 household   new_city         23         0.2 0.74628901
#> 25         27   20   funeral    hotspot         25         0.9 0.62067571
#> 26          2   13   funeral   new_city         27         0.9 0.60000140
#> 27         23   26   funeral local_town         NA         0.9 0.28480854
#> 28         16   25   funeral local_town         29         0.9 0.22232470
#> 29         11    2 household   new_city         NA         0.2 0.20028407
#> 30          4    5 household   new_city         NA         0.2 0.19991568
#> 31          3    6 household local_town         NA         0.2 0.19969489
#> 32          9    7 household    hotspot         10         0.2 0.19871356
#> 33         15   27   funeral    hotspot         NA         0.9 0.19870824
#> 34          1    5 household   new_city         13         0.2 0.19854218
#> 35          7    9 household local_town         NA         0.2 0.19844927
#> 36         10   10 household local_town         NA         0.2 0.19772316
#> 37         17    6 household   new_city         15         0.2 0.19754793
#> 38         25   14 household    hotspot         NA         0.2 0.19158821
#> 39         28   15 household   new_city         NA         0.2 0.18872827
#> 40         21   27   funeral    hotspot         29         0.9 0.14895995
#> 41         19    6 household    hotspot         30         0.2 0.10752694
#> 42         19   17 household    hotspot         30         0.2 0.10752694
#> 43         19   26 household    hotspot         30         0.2 0.10752694
#> 44         19   30 household    hotspot         30         0.2 0.10752694
#> 45         29   29   funeral local_town         NA         0.9 0.05915784
#> 46         20   29 household    hotspot         NA         0.2 0.01314619

## some wrangling needed to keep the order of contacts in the plot
res %>% 
  mutate(contact_id = factor(contact_id, levels = unique(contact_id))) %>% 
ggplot(aes(x = score, y = contact_id)) + 
  geom_col() + 
  theme_bw() + 
  labs(x = "ctscore (probability of detecting symptoms)", 
       y = "Contact ID", 
       title = "Contact tracing scoring")
```

<img src="man/figures/README-unnamed-chunk-8-1.png" alt="" width="100%" />

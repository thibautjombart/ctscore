# Internal helpers and methods for `ctdata` objects

A `ctdata` object is a `list` of three tibbles:

- `linelist`: one row per contact (individual-level data such as
  `location`, `last_visit_date`, `infected`, `onset_date`, plus any
  extra columns).

- `exposures`: one row per exposure (`contact_id`, `date`,
  `exposure_type`).

- `risk`: one row per exposure type (`exposure_type`,
  `infection_proba`).

## Details

`linelist` and `exposures` share a `contact_id` column; `exposures` and
`risk` share an `exposure_type` column.

## Author

Cyril Geismar

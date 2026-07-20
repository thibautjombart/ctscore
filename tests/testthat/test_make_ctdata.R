test_that("make_ctdata() issues correct errors", {
  exp <- tibble::tibble(contact_id = 1, date = Sys.Date(), type = "normal")

  ## exposures missing a required column
  expect_error(make_ctdata(exp[c("contact_id", "date")]), "missing required column")

  ## linelist missing a contact present in exposures
  expect_error(
    make_ctdata(exp,
      linelist = tibble::tibble(contact_id = 99),
      infection_proba = list(normal = 0.2)
    ),
    "missing contact"
  )
})


test_that("make_ctdata() builds a two-table ctdata (linelist derived from exposures)", {
  x <- make_ctdata(
    exposures = tibble::tibble(contact_id = 1, date = Sys.Date(), type = "normal"),
    infection_proba = list(normal = 0.2)
  )
  expect_s3_class(x, "ctdata")
  expect_identical(names(x), c("linelist", "exposures"))
  expect_s3_class(x$exposures, "tbl_df")

  ## with no linelist, one all-NA row per contact is derived
  expect_identical(x$linelist$contact_id, "1")
  expect_identical(names(x$linelist), c("contact_id", "location", "last_visit_date", "infected", "onset_date"))
  expect_true(all(is.na(x$linelist[, -1])))
})


test_that("make_ctdata() processes and orders exposures, mapping infection_proba", {
  x <- make_ctdata(
    exposures = tibble::tibble(
      contact_id = c(1, 1, 2),
      date       = as.character(as.Date("2026-06-19") - 1:3), # character dates
      type       = factor(c("normal", "funeral", "funeral")) # factor type
    ),
    infection_proba = list(normal = 0.1, funeral = 0.5)
  )
  e <- x$exposures
  expect_identical(e$contact_id, c("1", "1", "2")) # coerced, ordered by contact then date
  expect_identical(e$date, as.Date(c("2026-06-17", "2026-06-18", "2026-06-16")))
  expect_identical(e$type, c("funeral", "normal", "funeral"))
  expect_equal(e$infection_proba, c(0.5, 0.1, 0.5)) # attached by type
})


test_that("make_ctdata() validates and keeps a supplied linelist", {
  x <- make_ctdata(
    exposures = tibble::tibble(contact_id = c(1, 2), date = Sys.Date(), type = "normal"),
    linelist = tibble::tibble(
      contact_id = c(1, 2),
      last_visit_date = c(as.Date(NA), as.Date("2026-06-18")),
      ward       = "A" # extra column, recycled and kept
    ),
    infection_proba = list(normal = 0.2)
  )
  expect_identical(x$linelist$contact_id, c("1", "2"))
  expect_identical(x$linelist$last_visit_date, c(as.Date(NA), as.Date("2026-06-18"))) # NA preserved
  expect_identical(x$linelist$ward, c("A", "A"))
})


test_that("make_ctdata() rejects an onset without infection", {
  expect_error(
    make_ctdata(
      exposures = tibble::tibble(contact_id = 1, date = Sys.Date(), type = "normal"),
      linelist = tibble::tibble(contact_id = 1, infected = FALSE, onset_date = Sys.Date()),
      infection_proba = list(normal = 0.2)
    ),
    "onset_date implies infected = TRUE"
  )
})

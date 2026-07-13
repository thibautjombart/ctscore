test_that(
  "Constructor issues correct errors", 
  {
    msg <- 'argument "contact_id" is missing, with no default'
    expect_error(make_ctdata(), msg)
    
    msg <- 'argument "date" is missing, with no default'
    expect_error(make_ctdata(contact_id = 1), msg)
      
  }
)




test_that(
  "Constructor works with basic input", 
  {
  res <- make_ctdata(contact_id = "toto", date = Sys.Date())
  expect_identical(
    dim(res),
    c(1L, 8L)
  )
  expect_identical(
    names(res),
    c("contact_id", "date", "type", "location", "last_visit", "infected", "onset", "infection_proba")
  )
  
  expect_true(inherits(res, "ctdata"))
  expect_true(inherits(res, "data.frame"))
  
  }
)




test_that(
  "Constructor does basic input processing and reordering",
  {
    id <- c(1, 1, 2)
    date <- as.Date("2026-06-19") - 1:3
    type <- c("normal", "funeral", "funeral")
    location <- factor("town")
    date_txt <- as.character(date)
    res <- make_ctdata(
      contact_id = id, 
      date = date_txt, 
      type = type, 
      location = location, 
      infection_proba = list(normal = 0.1, funeral = 0.5),
      last_visit = date_txt
    )
    
    expect_true(inherits(res, "ctdata"))
    expect_true(inherits(res, "data.frame"))
    expect_identical(res$contact_id, as.character(id))
    expect_identical(res$date, as.Date(c("2026-06-17", "2026-06-18", "2026-06-16")))
    expect_identical(res$type, c("funeral", "normal", "funeral"))
    expect_identical(res$location, rep("town", 3))
    expect_equal(res$infection_proba, c(0.5, 0.1, 0.5))
    expect_identical(res$date, res$last_visit)
    
  } 
)



test_that(
  "make_ctdata() handles NA in last_visit",
  {
    id <- c(1, 1, 2)
    date <- as.Date("2026-06-19") - 1:3
    type <- c("normal", "funeral", "funeral")
    location <- factor("town")
    date_txt <- as.character(date)
    res <- make_ctdata(
      contact_id = id, 
      date = date_txt, 
      type = type, 
      location = location, 
      infection_proba = list(normal = 0.1, funeral = 0.5),
      last_visit = c(as.Date(NA), as.Date(NA), as.Date("2026-06-19")- 1)
    )
    
    expect_true(inherits(res, "ctdata"))
    expect_true(inherits(res, "data.frame"))
    expect_identical(res$contact_id, as.character(id))
    expect_identical(res$date, as.Date(c("2026-06-17", "2026-06-18", "2026-06-16")))
    expect_identical(res$type, c("funeral", "normal", "funeral"))
    expect_identical(res$location, rep("town", 3))
    expect_equal(res$infection_proba, c(0.5, 0.1, 0.5))
    expect_identical(res$last_visit, as.Date(c(NA, NA, "2026-06-18")))
  }
)


test_that("make_ctdata() rejects an onset without infection", {
  expect_error(
    make_ctdata(contact_id = 1, date = Sys.Date(),
                infected = FALSE, onset = Sys.Date()),
    "onset implies infected = TRUE"
  )
})

test_that("make_ctdata() appends and recycles extra columns via ...", {
  res <- make_ctdata(contact_id = c(1, 2), date = Sys.Date() - c(2, 2),
                     vaccinated = c(TRUE, FALSE), ward = "A")
  expect_true(all(c("vaccinated", "ward") %in% names(res)))
  expect_identical(res$ward, c("A", "A"))          # length-1 recycled
})

test_that("make_ctdata() rejects a duplicated formal argument", {
  ## duplicating a formal is caught by R's argument matching, before the body runs
  expect_error(
    make_ctdata(contact_id = 1, date = Sys.Date(), contact_id = "Paul"),
    "matched by multiple actual arguments"
  )
})

test_that("make_ctdata() blocks ... names that collide with downstream columns", {
  ## 'score' is added later by ctscore(); it is not a formal, so it reaches ...
  expect_error(
    make_ctdata(contact_id = 1, date = Sys.Date(), score = 5),
    "clash with reserved"
  )
})

test_that("make_ctdata() no longer requires last_visit", {
  res <- make_ctdata(contact_id = 1, date = Sys.Date())
  expect_true(all(is.na(res$last_visit)))
})
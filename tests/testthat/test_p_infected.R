x <- make_ctdata(
  exposures = tibble::tibble(
    contact_id = c(1, 1, 2, 3, 3, 3, 4),
    date = Sys.Date() - c(6, 4, 
                          5, 
                          1, 2, 4, 
                          5),
    exposure_type = c("normal", "funeral", 
                      "normal", 
                      "normal", "normal", "normal", 
                      "null")
  ),
  linelist = tibble::tibble(
    contact_id = c(1, 2, 3, 4),
    last_visit_date = Sys.Date() - c(2, 1, 1, 3)
  ),
  infection_proba = list(normal = 0.2, funeral = 0.9, null = 0)
)




test_that(
  "p_infected() issues expected errors", 
  {
    
    msg <- "'x' should be a ctdata object as returned by make_ctdata()"
    expect_error(p_infected(NULL), msg)
    
  }
)



test_that(
  "p_infected() returns the correct results", 
  {
    res <- p_infected(x)
    
    expect_identical(names(res), unique(x$linelist$contact_id))
    expect_true(is.numeric(res))
    expect_equal(unname(res[1]), 0.2 + (0.8*0.9))
    expect_equal(unname(res[2]), 0.2)
    expect_equal(unname(res[3]), 0.2 + 0.8*0.2 + 0.8*0.8*0.2)
    expect_equal(unname(res[4]), 0)
    
  }
)



test_that(
  "add_p_infected() outputs the correct results", 
  {
    p_inf <- p_infected(x)
    res <- add_p_infected(x, p_inf)
    expect_equal(res$linelist$p_infected, unname(p_inf))
  }
)
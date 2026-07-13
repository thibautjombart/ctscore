test_that(
  "ctscore issues correct errors", 
  {
    msg <- "'x' should be a ctdata object as returned by make_ctdata\\(\\)"
    expect_error(ctscore("pmspodf"), msg)
      
    msg <- "'x' should be a numeric vector or a distcrete object"
    expect_error(
      ctscore(make_ctdata(
        contact_id = 1, 
        date = Sys.Date(), 
        last_visit = Sys.Date()-3
        ), incub = "pmspodf"), 
      msg
    )
    
  }
)




test_that(
  "ctscore gives expected results", 
  {
    ## We first make a ctdata object
    ## 
    ## 'null' exposure is used as a sanity check to ensure that the function
    ## correctly handles zero probabilities of infection
    ## We also make an incubation time distribution with zero mass at day 1,
    ## where the score should be zero.
    x <- make_ctdata(
      contact_id = c(1, 1, 2, 3, 4), 
      date = Sys.Date() - c(6, 4, 5, 1, 5),
      type = c("normal", "funeral", "normal", "normal", "null"),
      location = "some-town",
      infection_proba = list(normal = 0.2, funeral = 0.9, null = 0),
      last_visit = Sys.Date() - c(4, 2, 1, 1, 3)
    )
   
    ## Incub gives the pmf of the incubation time from time 0 to length(incub) -
    ## 1
    incub <- c(0, 0, 1, 2, 4, 3, 2, 1)

    res <- ctscore(x, incub)
    
    
    ## Test dimensions, names etc.
    expect_equal(length(res), 4)
    expect_equal(names(res), as.character(1:4))
    
    
    ## Expected results:
    ## contact 1: a non-trivial positive value
    ## contact 2: incub[6]/sum(incub[6:8]) * 0.2
    ## contact 3: 0 because exposure is too recent
    ## contact 4: 0 because null exposure
    expect_true(res[1] > 0)
    expect_true(res[2] > 0)
    expect_equal(unname(res[3]), 0)
    expect_equal(unname(res[4]), 0)
    
  }
)



test_that(
  "ctscore gives identical results for distcrete and numeric incubation", {
    x <- make_ctdata(
      contact_id = c(1, 1, 2, 3, 4), 
      date = Sys.Date() - c(6, 4, 5, 1, 5),
      type = c("normal", "funeral", "normal", "normal", "null"),
      location = "some-town",
      infection_proba = list(normal = 0.2, funeral = 0.9, null = 0),
      last_visit = Sys.Date() - c(4, 2, 1, 1, 3)
    )
    
    incub <- distcrete::distcrete("gamma", interval = 1, shape = 2, scale = 2.5, w = 0)
    incub_num <- incub$d(0:1000)
    res_1 <- ctscore(x, incub_num)
    res_2 <- ctscore(x, incub)
    expect_equal(res_1, res_2)
    
  }  
)



test_that(
  "ctscore() handles NA in last_visit correctly", 
  {
    incub <- distcrete::distcrete("gamma", interval = 1, shape = 2, scale = 2.5, w = 0)
    
    x_1 <- make_ctdata(
      contact_id = c("a", "a", "b", "c", "d"), 
      date = Sys.Date() - c(6, 4, 5, 1, 5),
      type = c("normal", "funeral", "normal", "normal", "null"),
      location = "some-town",
      infection_proba = list(normal = 0.2, funeral = 0.9, null = 0),
      last_visit = c(Sys.Date() - c(4, 4, NA, NA, NA))
    )
    
    x_2 <- x_1
    x_2$last_visit[3:5] <- as.Date("2000-12-02")
    
    expect_identical(
      ctscore(x_1, incub), 
      ctscore(x_2, incub)
    )
   
  }
)  



test_that(
  "ctscore() shapes results correctly", 
  {
    x <- make_ctdata(
      contact_id = c(1, 1, 2, 3, 4), 
      date = Sys.Date() - c(6, 4, 5, 1, 5),
      type = c("normal", "funeral", "normal", "normal", "null"),
      location = "some-town",
      infection_proba = list(normal = 0.2, funeral = 0.9, null = 0),
      last_visit = Sys.Date() - c(4, 2, 1, 1, 3)
    )
    
    incub <- distcrete::distcrete(
      "gamma", interval = 1, shape = 3.123, scale = 2.5, w = 0
    )
    
    res_1 <- ctscore(x, incub)
    res_2 <- ctscore(x, incub, out_type = "data.frame")
    res_3 <- ctscore(x, incub, out_type = "ctdata")
    res_4 <- ctscore(x, incub, out_type = "ctdata_full")
    
    expect_true(is.numeric(res_1))
    expect_true(is.data.frame(res_2))
    expect_true(inherits(res_3, "ctdata"))
    expect_true(inherits(res_4, "ctdata"))
    
    expect_equal(unname(res_1), res_2$score)
    expect_equal(unname(res_1), res_3$score)
    expect_equal(unname(res_1), res_4$score[-2])
    expect_equal(nrow(x), nrow(res_4))
    
    expect_identical(
      names(res_2) , 
      c("contact_id", "score")
    )
    expect_identical(
      names(res_3) , 
      c("contact_id", "location", "last_visit", "infected", "onset", "score")
    )
    expect_identical(
      names(res_4) , 
      c(names(x), "score")
    )
    
  }
)
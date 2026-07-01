## We make a dummy incubation time distribution with no mass on days 0-1
w <- c(0, 0, 1, 2, 3, 2, 1, 1)
w <- w / sum(w)
incub <- process_incub(w)


test_that(
  "calculate_p_symptoms gives expected results", 
  {
    
    ## single exposure
    ### these should be zero
    expect_equal(
      calculate_p_symptoms(e = 0, s = -1, t = 0, incub), 
      0
    )
    expect_equal(
      calculate_p_symptoms(e = 0, s = -1, t = 1, incub), 
      0
    )
    expect_equal(
      calculate_p_symptoms(e = 0, s = 5, t = 3, incub), 
      0
    )
    expect_equal(
      calculate_p_symptoms(e = 5, s = -1, t = 3, incub), 
      0
    )
    
    ### These should be NaN because no symptom until the incubation PMF reaches 
    ### 0 mass
    expect_true(
      is.nan(calculate_p_symptoms(e = 0, s = 7, t = 10, incub))
    )
    
    ### non-zero values, no followup
    expect_equal(
      calculate_p_symptoms(e = 0, s = -1, t = 2, incub), 
      w[3]
    )
    expect_equal(
      calculate_p_symptoms(e = 10, s = -1, t = 15, incub), 
      sum(w[0:6])
    )
    expect_equal(
      calculate_p_symptoms(e = 22, s = -1, t = 50, incub), 
      1
    )
    
    ### non-zero values, with followup ; we use the "+" to have dates not start 
    ### at 0
    expect_equal(
      calculate_p_symptoms(e = 0+5, s = 4+5, t = 5+5, incub),
      w[6] / sum(w[6:8])
    )
    expect_equal(
      calculate_p_symptoms(e = 0+3, s = 3+3, t = 6+3, incub),
      sum(w[5:7]) / sum(w[5:8])
    )
    
    
    ### corner-case: follow-up reaches into 0 mass of the incubation PMF
    ### this should never happen
    res <- calculate_p_symptoms(e = 0, s = 10, t = 100, incub)
    expect_true(is.na(res))
    
  }
)



test_that(
  "calculate_p_symptoms gives identical results with numeric or Date", 
  {
    ref_date <- Sys.Date() - 100
    
    expect_equal(
      calculate_p_symptoms(e = 0+ref_date, s = 3+ref_date, t = 6+ref_date, incub),
      calculate_p_symptoms(e = 0, s = 3, t = 6, incub)
    )
    
    expect_equal(
      calculate_p_symptoms(e = 0+ref_date, s = 3+ref_date, t = 2+ref_date, incub),
      calculate_p_symptoms(e = 0, s = 3, t = 2, incub)
    )
    
    expect_equal(
      calculate_p_symptoms(e = 0+ref_date, s = 5+ref_date, t = 10+ref_date, incub),
      calculate_p_symptoms(e = 0, s = 5, t = 10, incub)
    )
    
  }
)

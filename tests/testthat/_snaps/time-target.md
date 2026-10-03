# logistics_census_time_target_raw() requires a valid year

    Code
      logistics_census_time_target_raw("x")
    Condition
      Error in `logistics_census_time_target_raw()`:
      ! `year` is absent but must be supplied.
    Code
      logistics_census_time_target_raw("x", year = 2020)
    Condition
      Error in `logistics_census_time_target_raw()`:
      ! `year` must be one of "2005", "2010", "2015", or "2021", not "2020".
      i Did you mean "2010"?


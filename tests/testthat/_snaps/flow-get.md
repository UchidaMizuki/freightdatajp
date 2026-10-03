# logistics_census_flow_get() requires a valid year and breakdown

    Code
      logistics_census_flow_get(by = "mode")
    Condition
      Error in `logistics_census_flow_get()`:
      ! `year` is absent but must be supplied.
    Code
      logistics_census_flow_get(2021)
    Condition
      Error in `logistics_census_flow_get()`:
      ! `by` is absent but must be supplied.
    Code
      logistics_census_flow_get(2020, by = "mode")
    Condition
      Error in `logistics_census_flow_get()`:
      ! `year` must be one of "2005", "2010", "2015", or "2021", not "2020".
      i Did you mean "2010"?
    Code
      logistics_census_flow_get(2021, by = c("commodity", "mode"))
    Condition
      Error in `logistics_census_flow_get()`:
      ! `by` must be one of the breakdowns of the published tables:
      * `"commodity"`
      * `"commodity_class"`
      * `"mode"`
      * `c("mode", "expressway")`
      * `c("mode", "commodity_class")`


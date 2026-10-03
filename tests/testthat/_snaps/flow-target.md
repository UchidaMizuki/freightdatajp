# logistics_census_flow_target_raw() requires a valid breakdown

    Code
      logistics_census_flow_target_raw("x", year = 2010)
    Condition
      Error in `logistics_census_flow_target_raw()`:
      ! `by` is absent but must be supplied.
    Code
      logistics_census_flow_target_raw("x", year = 2010, by = "expressway")
    Condition
      Error in `logistics_census_flow_target_raw()`:
      ! `by` must be one of the breakdowns of the published tables:
      * `"commodity"`
      * `"commodity_class"`
      * `"mode"`
      * `c("mode", "expressway")`
      * `c("mode", "commodity_class")`


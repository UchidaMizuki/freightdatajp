# logistics_census_pipeline() rejects invalid years

    Code
      logistics_census_pipeline(2020)
    Condition
      Error:
      ! `year` must be one of "2005", "2010", "2015", or "2021", not "2020".
      i Did you mean "2010"?
    Code
      logistics_census_pipeline("2021")
    Condition
      Error:
      ! `year` must be a whole number, not the string "2021".
    Code
      logistics_census_pipeline(c(2005, 2010))
    Condition
      Error:
      ! `year` must be a whole number, not a double vector.

# logistics_census_flow_name() names the target of each breakdown

    Code
      logistics_census_flow_name(c("mode", "mode"))
    Condition
      Error:
      ! `by` must be one of the breakdowns of the published tables:
      * `"commodity"`
      * `"commodity_class"`
      * `"mode"`
      * `c("mode", "expressway")`
      * `c("mode", "commodity_class")`
    Code
      logistics_census_flow_name(NA_character_)
    Condition
      Error:
      ! `by` must be one of the breakdowns of the published tables:
      * `"commodity"`
      * `"commodity_class"`
      * `"mode"`
      * `c("mode", "expressway")`
      * `c("mode", "commodity_class")`


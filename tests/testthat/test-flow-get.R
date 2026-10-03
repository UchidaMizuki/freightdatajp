test_that("logistics_census_flow_get() reads the flow target of the breakdown", {
  local_mocked_bindings(tar_get_archive_raw = function(...) list(...))
  expect_equal(
    logistics_census_flow_get(2015, by = c("commodity_class", "mode")),
    list(
      name = "flow_mode_commodity_class",
      package = "freightdatajp",
      pipeline = "logistics-census-pref-2015"
    )
  )
})

test_that("logistics_census_flow_get() requires a valid year and breakdown", {
  expect_snapshot(error = TRUE, {
    logistics_census_flow_get(by = "mode")
    logistics_census_flow_get(2021)
    logistics_census_flow_get(2020, by = "mode")
    logistics_census_flow_get(2021, by = c("commodity", "mode"))
  })
})

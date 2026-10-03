test_that("logistics_census_flow_target() declares a target for the year", {
  local_mocked_bindings(tar_target_archive_raw = function(...) list(...))
  expected <- list(
    name = "x",
    package = "freightdatajp",
    pipeline = "logistics-census-pref-2010",
    name_archive = "flow_mode_expressway"
  )
  expect_equal(
    logistics_census_flow_target(x, year = 2010, by = c("mode", "expressway")),
    expected
  )
  expect_equal(
    logistics_census_flow_target_raw(
      "x",
      year = 2010,
      by = c("expressway", "mode")
    ),
    expected
  )
})

test_that("logistics_census_flow_target_raw() requires a valid breakdown", {
  expect_snapshot(error = TRUE, {
    logistics_census_flow_target_raw("x", year = 2010)
    logistics_census_flow_target_raw("x", year = 2010, by = "expressway")
  })
})

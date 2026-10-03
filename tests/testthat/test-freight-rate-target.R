test_that("logistics_census_freight_rate_target() declares a target for the year", {
  local_mocked_bindings(tar_target_archive_raw = function(...) list(...))
  expected <- list(
    name = "x",
    package = "freightdatajp",
    pipeline = "logistics-census-pref-2010",
    name_archive = "freight_rate"
  )
  expect_equal(logistics_census_freight_rate_target(x, year = 2010), expected)
  expect_equal(
    logistics_census_freight_rate_target_raw("x", year = 2010),
    expected
  )
})

test_that("logistics_census_freight_rate_target_raw() requires a valid year", {
  expect_snapshot(error = TRUE, {
    logistics_census_freight_rate_target_raw("x")
    logistics_census_freight_rate_target_raw("x", year = 2020)
  })
})

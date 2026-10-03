test_that("logistics_census_time_get() reads the time target of the year", {
  local_mocked_bindings(tar_get_archive_raw = function(...) list(...))
  expect_equal(
    logistics_census_time_get(2021),
    list(
      name = "time",
      package = "freightdatajp",
      pipeline = "logistics-census-pref-2021"
    )
  )
})

test_that("logistics_census_time_get() requires a valid year", {
  expect_snapshot(error = TRUE, {
    logistics_census_time_get()
    logistics_census_time_get(2020)
  })
})

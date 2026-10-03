test_that("logistics_census_years() lists the years of the pipelines", {
  expect_equal(logistics_census_years(), c("2005", "2010", "2015", "2021"))
})

test_that("logistics_census_pipeline() maps years to pipelines", {
  expect_equal(logistics_census_pipeline(2021), "logistics-census-pref-2021")
  expect_equal(logistics_census_pipeline(2005L), "logistics-census-pref-2005")
})

test_that("logistics_census_pipeline() rejects invalid years", {
  expect_snapshot(error = TRUE, {
    logistics_census_pipeline(2020)
    logistics_census_pipeline("2021")
    logistics_census_pipeline(c(2005, 2010))
  })
})

test_that("logistics_census_flow_name() names the target of each breakdown", {
  expect_equal(
    purrr::map_chr(logistics_census_flow_by, logistics_census_flow_name),
    c(
      "flow_commodity",
      "flow_commodity_class",
      "flow_mode",
      "flow_mode_expressway",
      "flow_mode_commodity_class"
    )
  )
  expect_equal(
    logistics_census_flow_name(c("expressway", "mode")),
    "flow_mode_expressway"
  )
  expect_snapshot(error = TRUE, {
    logistics_census_flow_name(c("mode", "mode"))
    logistics_census_flow_name(NA_character_)
  })
})

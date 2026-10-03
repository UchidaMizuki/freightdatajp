test_that("parse_cells_logistics_census_zone() reads decimal degrees", {
  expect_equal(
    fixture_zone(),
    tibble::tibble(
      zone_code = c("01", "13", "26"),
      zone_name = c("北海道", "東京都", "京都府"),
      longitude = c(141.1, 139.6, 135.6),
      latitude = c(35, 35, 35)
    )
  )
})

test_that("parse_cells_logistics_census_zone() reads the census year in DMS", {
  zone <- read_fixture_cells("zone-dms.csv") |>
    parse_cells_logistics_census_zone(angle = "dms")
  expect_equal(zone$zone_code, c("01", "13", "26"))
  expect_equal(zone$zone_name, c("北海道", "東京都", "京都府"))
  expect_equal(zone$longitude, rep(141.5, 3))
  expect_equal(zone$latitude, rep(35.5, 3))
})

test_that("tidy_logistics_census_zone() adds the survey year", {
  zone <- tidy_logistics_census_zone(fixture_zone(), year = 2021)
  expect_equal(
    names(zone),
    c("year", "zone_code", "zone_name", "longitude", "latitude")
  )
  expect_equal(unique(zone$year), 2021L)
})

test_that("zone_name_to_code() accepts full and abbreviated names", {
  zone <- fixture_zone()
  expect_equal(
    zone_name_to_code(c("北海道", "東京都", "東京", "京都"), zone),
    c("01", "13", "13", "26")
  )
  expect_snapshot(error = TRUE, zone_name_to_code(c("東京", "江戸"), zone))
})

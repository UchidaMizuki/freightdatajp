tarchives::tar_source_archive("freightdatajp", envir = environment())

read_fixture_cells <- function(file) {
  readr::read_csv(
    test_path("fixtures", file),
    col_names = FALSE,
    col_types = readr::cols(.default = "c"),
    na = "",
    trim_ws = FALSE
  ) |>
    as_label_cells()
}

fixture_zone <- function() {
  read_fixture_cells("zone.csv") |>
    parse_cells_logistics_census_zone(angle = "decimal")
}

test_that("the block layout is parsed into one table per label", {
  data <- parse_cells_logistics_census(
    read_fixture_cells("logistics-census-block.csv"),
    zone = fixture_zone(),
    labels = c(commodity = "品目名")
  )
  expect_equal(unique(data$commodity), c("麦", "染料･顔料･塗料"))
  expect_equal(nrow(data), 2 * 3^2)

  wheat <- data[data$commodity == "麦", ]
  expect_equal(wheat$origin_code, rep(c("01", "13", "26"), each = 3))
  expect_equal(wheat$destination_code, rep(c("01", "13", "26"), times = 3))
  expect_equal(wheat$value, c(1, NA, 0, 10, 2, 0, 0, 20, 3))
})

test_that("the sheet layout is parsed like the block layout", {
  zone <- fixture_zone()
  block <- parse_cells_logistics_census(
    read_fixture_cells("logistics-census-block.csv"),
    zone = zone,
    labels = c(commodity = "品目名")
  )
  sheet <- parse_cells_logistics_census(
    read_fixture_cells("logistics-census-sheet.csv"),
    zone = zone,
    labels = c(commodity = "品目")
  )
  expect_equal(sheet, block[block$commodity == "麦", ])
})

test_that("tables with two labels are parsed alike in both layouts", {
  zone <- fixture_zone()
  block <- read_fixture_cells("logistics-census-block-two-labels.csv") |>
    parse_cells_logistics_census(
      zone = zone,
      labels = c(mode = "代表輸送機関", commodity_class = "品類名")
    ) |>
    tidy_logistics_census(year = 2015, value = "weight", unit = "t")
  sheet <- read_fixture_cells("logistics-census-sheet-two-labels.csv") |>
    parse_cells_logistics_census(
      zone = zone,
      labels = c(mode = "代表輸送機関", commodity_class = "品類")
    ) |>
    tidy_logistics_census(year = 2021, value = "weight", unit = "t")

  expect_equal(unique(block$mode_name), "鉄道（小計）")
  expect_equal(unique(block$commodity_class_name), c("農水産品", "林産品"))
  expect_equal(
    sheet[-1],
    block[block$commodity_class_name == "農水産品", -1]
  )
})

test_that("a table without its labels is an error", {
  expect_snapshot(error = TRUE, {
    parse_cells_logistics_census(
      read_fixture_cells("logistics-census-block.csv"),
      zone = fixture_zone(),
      labels = c(mode = "代表輸送機関")
    )
  })
})

test_that("labels are read from the titles of 2021", {
  cells <- tibble::tibble(
    x = "表Ⅴ－１－２（１）代表輸送機関：営業用トラック（小計）、高速道路：利用しない［３日間調査］"
  ) |>
    as_label_cells()
  expect_equal(
    parse_cells_logistics_census_labels(
      cells,
      labels = c(mode = "代表輸送機関", expressway = "高速道路")
    ),
    tibble::tibble(
      row = 1L,
      dimension = c("mode", "expressway"),
      value = c("営業用トラック（小計）", "利用しない")
    )
  )
})

test_that("a table that lacks a zone is an error", {
  zone <- tibble::add_row(
    fixture_zone(),
    zone_code = "47",
    zone_name = "沖縄県"
  )
  expect_snapshot(error = TRUE, {
    parse_cells_logistics_census(
      read_fixture_cells("logistics-census-sheet.csv"),
      zone = zone,
      labels = c(commodity = "品目")
    )
  })
})

test_that("tables have the same columns and types in both layouts", {
  zone <- fixture_zone()
  block <- read_fixture_cells("logistics-census-block.csv") |>
    parse_cells_logistics_census(
      zone = zone,
      labels = c(commodity = "品目名")
    ) |>
    tidy_logistics_census(year = 2015, value = "weight", unit = "t")
  sheet <- read_fixture_cells("logistics-census-sheet.csv") |>
    parse_cells_logistics_census(zone = zone, labels = c(commodity = "品目")) |>
    tidy_logistics_census(year = 2021, value = "weight", unit = "t")

  expect_identical(block[0, ], sheet[0, ])
  expect_equal(
    names(block),
    c("year", "commodity_name", "origin_code", "destination_code", "weight")
  )
  expect_equal(units::deparse_unit(block$weight), "t")
  expect_equal(unique(block$commodity_name), c("麦", "染料・顔料・塗料"))
})

test_that("tidy_logistics_census() keeps values without units as numbers", {
  data <- read_fixture_cells("logistics-census-block-two-labels.csv") |>
    parse_cells_logistics_census(
      zone = fixture_zone(),
      labels = c(mode = "代表輸送機関", commodity_class = "品類名")
    ) |>
    tidy_logistics_census(
      year = 2005,
      value = "freight_rate_jpy_per_tonne_km",
      unit = NULL
    )
  expect_equal(
    names(data),
    c(
      "year",
      "mode_name",
      "commodity_class_name",
      "origin_code",
      "destination_code",
      "freight_rate_jpy_per_tonne_km"
    )
  )
  expect_type(data$freight_rate_jpy_per_tonne_km, "double")
})

test_that("join_logistics_census() joins two values of the same tables", {
  data <- read_fixture_cells("logistics-census-block.csv") |>
    parse_cells_logistics_census(
      zone = fixture_zone(),
      labels = c(commodity = "品目名")
    )
  weight <- tidy_logistics_census(data, 2005, value = "weight", unit = "t")
  n_shipments <- tidy_logistics_census(
    data,
    2005,
    value = "n_shipments",
    unit = NULL
  )
  joined <- join_logistics_census(weight, n_shipments)
  expect_equal(nrow(joined), nrow(weight))
  expect_equal(joined$n_shipments, data$value)
  expect_snapshot(
    error = TRUE,
    join_logistics_census(weight, n_shipments[-1, ])
  )
})

test_that("parse_expressway() reads the use of expressways in every year", {
  expect_equal(
    parse_expressway(c("利用あり", "利用なし", "利用する", "利用しない")),
    c(TRUE, FALSE, TRUE, FALSE)
  )
  expect_snapshot(error = TRUE, parse_expressway("不明"))
})

test_that("normalize_mode_name() spells subtotals as in 2021", {
  expect_equal(
    normalize_mode_name(c("鉄道計", "トラック計", "海運計", "合計", "航空")),
    c("鉄道（小計）", "トラック（小計）", "海運（小計）", "合計", "航空")
  )
})

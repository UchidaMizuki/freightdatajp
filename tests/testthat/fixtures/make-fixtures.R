# Synthetic cells that mimic the layouts of the source workbooks, for a zone
# system of three prefectures. Run from the package root with
# `source("tests/testthat/fixtures/make-fixtures.R")`.

ideographic_space <- intToUtf8(0x3000)

zone_code <- c("01", "13", "26")
zone_name <- c("北海道", "東京都", "京都府")
zone_name_short <- c("北海道", "東京", "京都")

write_cells <- function(rows, file) {
  rows |>
    purrr::map_chr(function(row) {
      stringr::str_c(stringr::str_replace_na(row, ""), collapse = ",")
    }) |>
    readr::write_lines(fs::path("tests/testthat/fixtures", file))
}

# Spaces out names as in the 2005 to 2015 workbooks (`北　海　道`).
spaced <- function(name) {
  name |>
    stringr::str_split("") |>
    purrr::map_chr(\(x) stringr::str_c(x, collapse = ideographic_space))
}

# Rows of origins, columns of destinations. The cell from 北海道 to 東京都 is
# blank, and the cell from 北海道 to 京都府 is a published zero.
values <- list(
  c("1", NA, "0"),
  c("10", "2", "0"),
  c("0", "20", "3")
)

total <- "999"
empty <- rep(NA_character_, 5)

# 2005 to 2015: one sheet, one table per label row of keys and values, with
# abbreviated and spaced names.
block <- function(label_row) {
  c(
    list(
      label_row,
      empty,
      c("着都道府県", NA, NA, NA, NA),
      c(NA, spaced(zone_name_short), spaced("合計")),
      c("発都道府県", NA, NA, NA, NA)
    ),
    purrr::map2(spaced(zone_name_short), values, function(name, value) {
      c(name, value, total)
    }),
    list(c(spaced("合計"), rep(total, 4)), empty)
  )
}

# 2021: one table per sheet, labeled in the title, with full names.
sheet <- function(title) {
  c(
    list(
      c(title, NA, NA, NA, NA),
      c("着都道府県", zone_name, "合計"),
      c("発都道府県", rep("（トン）", 4))
    ),
    purrr::map2(zone_name, values, \(name, value) c(name, value, total)),
    list(c("合計", rep(total, 4)))
  )
}

title <- stringr::str_c("表Ⅳ－２", ideographic_space, "都道府県間流動量")

write_cells(
  c(
    list(c(title, NA, NA, NA, NA), empty),
    block(c(spaced("品目名"), "麦", NA, NA, NA)),
    block(c(spaced("品目名"), "染料･顔料･塗料", NA, NA, NA))
  ),
  "logistics-census-block.csv"
)

write_cells(
  sheet(stringr::str_c(title, "（１）品目：麦［３日間調査］")),
  "logistics-census-sheet.csv"
)

write_cells(
  c(
    list(c(title, NA, NA, NA, NA), empty),
    block(c("代表輸送機関", "鉄道計", NA, "品類名", "農水産品")),
    block(c("代表輸送機関", "鉄道計", NA, "品類名", "林産品"))
  ),
  "logistics-census-block-two-labels.csv"
)

write_cells(
  sheet(stringr::str_c(
    title,
    "（３）代表輸送機関：鉄道（小計）－（１）品類：農水産品［３日間調査］"
  )),
  "logistics-census-sheet-two-labels.csv"
)

write_cells(
  c(
    list(
      c("都道府県・市区町村", NA, "人口重心", NA),
      c("コード", "名称", "10進経度", "10進緯度"),
      c("00000", "全国", "137.055679", "35.567677")
    ),
    purrr::pmap(
      list(zone_code, zone_name, c("141.1", "139.6", "135.6")),
      function(code, name, longitude) {
        c(stringr::str_c(code, "000"), name, longitude, "35.0")
      }
    )
  ),
  "zone.csv"
)

# The 2005 and 2010 tables: degrees, minutes, and seconds packed into one
# number, with the census year first and the previous census after it.
write_cells(
  c(
    list(
      c(NA, "地域", NA, NA, "2010", NA, "2005", NA),
      c(NA, NA, NA, NA, "東経", "北緯", "東経", "北緯"),
      c(
        "全国",
        NA,
        NA,
        NA,
        "1370145.46",
        "353535.31",
        "1370027.43",
        "353620.65"
      )
    ),
    purrr::map2(zone_code, zone_name, function(code, name) {
      c(NA, NA, code, name, "1413000", "353000", "1400000", "350000")
    })
  ),
  "zone-dms.csv"
)

# The population centroids published by the Statistics Bureau for each census.
# The layout differs by census, so `sheets` and `angle` (`"dms"` for
# `DDDMMSS.ss`, `"decimal"` for decimal degrees) are given by each pipeline.
read_file_logistics_census_zone <- function(file, year, sheets, angle) {
  sheets |>
    purrr::map(function(sheet) {
      read_cells(file, sheet) |>
        parse_cells_logistics_census_zone(angle = angle)
    }) |>
    purrr::list_rbind() |>
    tidy_logistics_census_zone(year = year)
}

tidy_logistics_census_zone <- function(data, year) {
  tibble::tibble(
    year = as.integer(year),
    zone_code = data$zone_code,
    zone_name = data$zone_name,
    longitude = data$longitude,
    latitude = data$latitude
  )
}

# Finds the columns by their headers: the first longitude and latitude columns
# are those of the census year (later ones are earlier censuses), and the code
# column holds prefecture codes (`01` or `01000`) followed by the name.
parse_cells_logistics_census_zone <- function(cells, angle) {
  code <- first_column(cells, is_zone_code)
  zones <- cells |>
    dplyr::filter(.data$col == code, is_zone_code(.data$chr))
  cell_at <- function(col) {
    i <- vctrs::vec_match(
      tibble::tibble(row = zones$row, col = col),
      cells[c("row", "col")]
    )
    cells$chr[i]
  }

  tibble::tibble(
    zone_code = stringr::str_sub(zones$chr, 1, 2),
    zone_name = cell_at(code + 1L),
    longitude = parse_longitude(
      cell_at(first_column(cells, is_longitude_label)),
      angle = angle
    ),
    latitude = parse_latitude(
      cell_at(first_column(cells, is_latitude_label)),
      angle = angle
    )
  )
}

# The first column with a cell for which `predicate` is `TRUE`.
first_column <- function(cells, predicate) {
  min(cells$col[which(predicate(cells$chr))])
}

is_longitude_label <- function(x) {
  vctrs::vec_in(x, c("東経", "10進経度"))
}

is_latitude_label <- function(x) {
  vctrs::vec_in(x, c("北緯", "10進緯度"))
}

# A prefecture code (`01` or `01000`), not Japan as a whole (`00` or `00000`).
is_zone_code <- function(x) {
  stringr::str_detect(x, "^\\d{2}(000)?$") & !stringr::str_detect(x, "^00")
}

parse_longitude <- function(x, angle) {
  parzer::parse_lon(format_angle(x, angle = angle))
}

parse_latitude <- function(x, angle) {
  parzer::parse_lat(format_angle(x, angle = angle))
}

# `"dms"` packs degrees, minutes, and seconds into one number, which parzer
# can't read (`1370027.43` is 137°00'27.43"), so it is written out first.
format_angle <- function(x, angle) {
  switch(
    angle,
    decimal = x,
    dms = stringr::str_replace(
      x,
      "^(\\d+)(\\d{2})(\\d{2}(?:\\.\\d+)?)$",
      "\\1°\\2'\\3\""
    )
  )
}

# The 2005 to 2015 workbooks abbreviate names by dropping the trailing `都`,
# `府`, or `県` (`東京`, `京都`).
zone_name_short <- function(zone_name) {
  stringr::str_remove(zone_name, "[都府県]$")
}

# Full names come first, so that a name that is both full and short (`北海道`)
# matches its full name.
zone_name_lookup <- function(zone) {
  tibble::tibble(
    zone_name = vctrs::vec_c(zone$zone_name, zone_name_short(zone$zone_name)),
    zone_code = vctrs::vec_c(zone$zone_code, zone$zone_code)
  )
}

is_zone_name <- function(name, zone) {
  vctrs::vec_in(name, zone_name_lookup(zone)$zone_name)
}

zone_name_to_code <- function(name, zone) {
  lookup <- zone_name_lookup(zone)
  i <- vctrs::vec_match(name, lookup$zone_name)
  if (anyNA(i)) {
    unknown <- vctrs::vec_unique(name[is.na(i)])
    cli::cli_abort(c(
      "Can't find zone names.",
      x = "Unknown name{?s}: {.val {unknown}}."
    ))
  }
  lookup$zone_code[i]
}

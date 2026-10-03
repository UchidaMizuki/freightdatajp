#' Get interprefectural freight rates of the logistics census
#'
#' Returns the freight rate between prefectures by representative transport
#' mode and commodity class, from table VI-2 (都道府県間輸送単価
#' （代表輸送機関・品類別）) of the Net Freight Flow Census (全国貨物純流動調査, the
#' logistics census). The first call for a year downloads the published
#' workbooks and builds the table, which is then cached.
#'
#' @inheritParams logistics_census_flow_get
#'
#' @return A tibble with one row per mode, commodity class, origin, and
#'   destination:
#'
#'   * `year`: The survey year (integer).
#'   * `mode_name`: The representative transport mode.
#'   * `commodity_class_name`: The commodity class.
#'   * `origin_code`, `destination_code`: Two-digit prefecture codes (`"01"` to
#'     `"47"`). See [logistics_census_zone_get()].
#'   * `freight_rate_jpy_per_tonne_km`: The freight rate in yen per tonne-km.
#'     A blank cell, where there were no shipments, is `NA`.
#'
#'   Labels are kept as published, so subtotals and totals (`合計`) of modes
#'   and commodity classes remain rows. Rows and columns that total over
#'   prefectures are dropped, and intra-prefecture rows are kept. The mode
#'   subtotals of 2005 to 2015 (`鉄道計`) are spelled as in 2021
#'   (`鉄道（小計）`).
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, Net Freight
#'   Flow Census, table VI-2. The workbooks of 2005 and 2010 are on
#'   <https://www.mlit.go.jp/>, and those of 2015 and 2021 on e-Stat
#'   (<https://www.e-stat.go.jp/stat-search/files?toukei=00600620>).
#'
#' @seealso [logistics_census_flow_get()] for freight flows and
#'   [logistics_census_time_get()] for travel times between prefectures.
#'
#' @examplesIf interactive()
#' logistics_census_freight_rate_get(2021)
#'
#' @export
logistics_census_freight_rate_get <- function(year) {
  rlang::check_required(year)
  logistics_census_get("freight_rate", year = year)
}

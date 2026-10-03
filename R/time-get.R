#' Get interprefectural travel times of the logistics census
#'
#' Returns the average time from shipment to delivery between prefectures by
#' representative transport mode, from table VI-1
#' (都道府県間物流時間（代表輸送機関別）) of the Net Freight Flow Census
#' (全国貨物純流動調査, the logistics census). The first call for a year
#' downloads the published workbook and builds the table, which is then cached.
#'
#' @inheritParams logistics_census_flow_get
#'
#' @return A tibble with one row per mode, origin, and destination:
#'
#'   * `year`: The survey year (integer).
#'   * `mode_name`: The representative transport mode, as labeled in the
#'     workbook. Subtotals (for example `鉄道（小計）`) and the total over all
#'     modes (`合計`) are kept as published.
#'   * `origin_code`, `destination_code`: Two-digit prefecture codes (`"01"` to
#'     `"47"`). See [logistics_census_zone_get()].
#'   * `travel_time`: Hours per shipment (`units`). A blank cell, where there
#'     were no shipments, is `NA`.
#'
#'   Intra-prefecture rows are kept, and total rows and columns are dropped.
#'   The subtotals of 2005 to 2015 (for example `鉄道計`) are spelled as in 2021
#'   (`鉄道（小計）`).
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, Net Freight
#'   Flow Census:
#'
#'   * 2005: <https://www.mlit.go.jp/sogoseisaku/transport/content/T8-060100.xls>
#'   * 2010: <https://www.mlit.go.jp/sogoseisaku/transport/content/T9-060100.xls>
#'   * 2015: <https://www.e-stat.go.jp/stat-search/file-download?statInfId=000031597067&fileKind=0>
#'   * 2021: <https://www.e-stat.go.jp/stat-search/file-download?statInfId=000040041343&fileKind=0>
#'
#' @seealso [logistics_census_flow_get()] for freight flows and
#'   [logistics_census_freight_rate_get()] for freight rates between
#'   prefectures.
#'
#' @examplesIf interactive()
#' logistics_census_time_get(2021)
#'
#' @export
logistics_census_time_get <- function(year) {
  rlang::check_required(year)
  logistics_census_get("time", year = year)
}

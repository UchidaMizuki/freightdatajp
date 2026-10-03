#' Get interprefectural freight flows of the logistics census
#'
#' Returns the freight shipped between prefectures, broken down as in one of
#' the interprefectural flow tables of the Net Freight Flow Census
#' (全国貨物純流動調査, the logistics census). The first call for a year
#' downloads the published workbooks and builds the table, which is then
#' cached.
#'
#' The census surveys shipments over three days, so `weight` and `n_shipments`
#' are totals for those three days, not annual totals.
#'
#' @param year The survey year: 2005, 2010, 2015, or 2021.
#' @param by The breakdown, which selects the published table:
#'
#'   * `"commodity"`: by commodity (品目), table IV-2.
#'   * `"commodity_class"`: by commodity class (品類), tables IV-1-1 (weight)
#'     and IV-1-2 (number of shipments).
#'   * `"mode"`: by representative transport mode (代表輸送機関), table V-1-1.
#'   * `c("mode", "expressway")`: by truck mode and the use of expressways,
#'     table V-1-2. The weights with and without expressways don't add up to
#'     the weight by mode: they come to 47% to 88% of it, depending on the
#'     mode and year, and never exceed it.
#'   * `c("mode", "commodity_class")`: by mode and commodity class, table V-2.
#'
#'   The order of the elements doesn't matter.
#'
#' @return A tibble with one row per breakdown, origin, and destination:
#'
#'   * `year`: The survey year (integer).
#'   * `mode_name`: The representative transport mode, if `by` includes
#'     `"mode"`.
#'   * `expressway`: `TRUE` for shipments that used an expressway, if `by`
#'     includes `"expressway"`.
#'   * `commodity_class_name`: The commodity class, if `by` includes
#'     `"commodity_class"`.
#'   * `commodity_name`: The commodity, if `by` is `"commodity"`.
#'   * `origin_code`, `destination_code`: Two-digit prefecture codes (`"01"` to
#'     `"47"`). See [logistics_census_zone_get()].
#'   * `weight`: Weight in metric tonnes (`units`).
#'   * `n_shipments`: The number of shipments, if `by` is `"commodity_class"`.
#'
#'   Labels are kept as published, so subtotals (for example `鉄道（小計）`)
#'   and totals (`合計`) of modes and commodity classes remain rows. Rows and
#'   columns that total over prefectures are dropped, and intra-prefecture rows
#'   are kept. A published zero is `0`, and a blank cell is `NA`.
#'
#'   Notation that differs by year is spelled as in 2021: the mode subtotals of
#'   2005 to 2015 (`鉄道計`) as `鉄道（小計）`, and the commodity `染料･顔料･塗料`
#'   as `染料・顔料・塗料`.
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, Net Freight
#'   Flow Census, tables IV-1-1, IV-1-2, IV-2, V-1-1, V-1-2, and V-2. The
#'   workbooks of 2005 and 2010 are on <https://www.mlit.go.jp/>, and those of
#'   2015 and 2021 on e-Stat
#'   (<https://www.e-stat.go.jp/stat-search/files?toukei=00600620>).
#'
#' @seealso [logistics_census_time_get()] for travel times and
#'   [logistics_census_freight_rate_get()] for freight rates between
#'   prefectures.
#'
#' @examplesIf interactive()
#' logistics_census_flow_get(2021, by = "commodity")
#' logistics_census_flow_get(2021, by = c("mode", "commodity_class"))
#'
#' @export
logistics_census_flow_get <- function(year, by) {
  rlang::check_required(year)
  rlang::check_required(by)
  logistics_census_get(logistics_census_flow_name(by), year = year)
}

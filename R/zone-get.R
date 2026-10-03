#' Get the zones of the logistics census
#'
#' Returns the 47 prefectures used as zones by the interprefectural tables of
#' the logistics census, with a representative point for each. The first call
#' for a year downloads the source workbook and builds the table, which is then
#' cached.
#'
#' The representative point is the population centroid published by the
#' Statistics Bureau for the census of the survey year, or the latest census
#' before it: 2005, 2010, and 2015 use the census of the same year, and 2021
#' uses the 2020 census. Great-circle distances between population centroids
#' explain the published travel times by truck better than those between
#' prefectural government offices or geometric centroids. A population
#' centroid can lie in the sea, as in Nagasaki, Oita, and Okinawa.
#'
#' @inheritParams logistics_census_flow_get
#'
#' @return A tibble with one row per prefecture:
#'
#'   * `year`: The survey year (integer).
#'   * `zone_code`: Two-digit prefecture code (`"01"` to `"47"`).
#'   * `zone_name`: Prefecture name (for example `"東京都"`).
#'   * `longitude`, `latitude`: Population centroid in decimal degrees, in the
#'     Japanese Geodetic Datum 2000 (世界測地系).
#'
#' @source Statistics Bureau of Japan, the population centroids of each
#'   census:
#'
#'   * 2005: 2005 census, final report, table 14
#'     (<https://www.e-stat.go.jp/stat-search/files?layout=dataset&stat_infid=000007375683>)
#'   * 2010: 2010 census, final report, table 14
#'     (<https://www.e-stat.go.jp/stat-search/files?layout=dataset&stat_infid=000025518687>)
#'   * 2015: Statistical Topics No. 102
#'     (<https://www.stat.go.jp/data/kokusei/topics/topi102.html>)
#'   * 2021: Statistical Topics No. 135, 2020 census
#'     (<https://www.stat.go.jp/data/kokusei/topics/topi135.html>)
#'
#' @examplesIf interactive()
#' logistics_census_zone_get(2021)
#'
#' @export
logistics_census_zone_get <- function(year) {
  rlang::check_required(year)
  logistics_census_get("zone", year = year)
}

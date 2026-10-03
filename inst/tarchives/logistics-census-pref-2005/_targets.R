library(targets)
library(tarchetypes)
library(tarchives)

tar_source_archive("freightdatajp")

year <- 2005

tar_plan(
  tar_download_file(
    file_zone,
    url = estat_file_url(7375683),
    file = "zone.xls"
  ),
  zone = read_file_logistics_census_zone(
    file_zone,
    year = year,
    sheets = 1,
    angle = "dms"
  ),

  # IV-1-1 and IV-1-2
  tar_download_file(
    file_flow_commodity_class_weight,
    url = "https://www.mlit.go.jp/sogoseisaku/transport/content/T8-040101.xls",
    file = "flow_commodity_class_weight.xls"
  ),
  tar_download_file(
    file_flow_commodity_class_n_shipments,
    url = "https://www.mlit.go.jp/sogoseisaku/transport/content/T8-040102.xls",
    file = "flow_commodity_class_n_shipments.xls"
  ),
  flow_commodity_class = join_logistics_census(
    read_file_logistics_census(
      file_flow_commodity_class_weight,
      year = year,
      zone = zone,
      labels = c(commodity_class = "品類名"),
      value = "weight",
      unit = "t"
    ),
    read_file_logistics_census(
      file_flow_commodity_class_n_shipments,
      year = year,
      zone = zone,
      labels = c(commodity_class = "品類名"),
      value = "n_shipments",
      unit = NULL
    )
  ),

  # IV-2
  tar_download_file(
    file_flow_commodity,
    url = "https://www.mlit.go.jp/sogoseisaku/transport/content/T8-040200.xls",
    file = "flow_commodity.xls"
  ),
  flow_commodity = read_file_logistics_census(
    file_flow_commodity,
    year = year,
    zone = zone,
    labels = c(commodity = "品目名"),
    value = "weight",
    unit = "t"
  ),

  # V-1-1
  tar_download_file(
    file_flow_mode,
    url = "https://www.mlit.go.jp/sogoseisaku/transport/content/T8-050101.xls",
    file = "flow_mode.xls"
  ),
  flow_mode = read_file_logistics_census(
    file_flow_mode,
    year = year,
    zone = zone,
    labels = c(mode = "代表輸送機関"),
    value = "weight",
    unit = "t"
  ),

  # V-1-2
  tar_download_file(
    file_flow_mode_expressway,
    url = "https://www.mlit.go.jp/sogoseisaku/transport/content/T8-050102.xls",
    file = "flow_mode_expressway.xls"
  ),
  flow_mode_expressway = read_file_logistics_census(
    file_flow_mode_expressway,
    year = year,
    zone = zone,
    labels = c(mode = "代表輸送機関", expressway = "高速道路利用の有無"),
    value = "weight",
    unit = "t"
  ),

  # V-2
  tar_download_file(
    file_flow_mode_commodity_class,
    url = "https://www.mlit.go.jp/sogoseisaku/transport/content/T8-050200.xls",
    file = "flow_mode_commodity_class.xls"
  ),
  flow_mode_commodity_class = read_file_logistics_census(
    file_flow_mode_commodity_class,
    year = year,
    zone = zone,
    labels = c(mode = "代表輸送機関", commodity_class = "品類名"),
    value = "weight",
    unit = "t"
  ),

  # VI-1
  tar_download_file(
    file_time,
    url = "https://www.mlit.go.jp/sogoseisaku/transport/content/T8-060100.xls",
    file = "time.xls"
  ),
  time = read_file_logistics_census(
    file_time,
    year = year,
    zone = zone,
    labels = c(mode = "代表輸送機関"),
    value = "travel_time",
    unit = "h"
  ),

  # VI-2
  tar_download_file(
    file_freight_rate,
    url = "https://www.mlit.go.jp/sogoseisaku/transport/content/T8-060200.xls",
    file = "freight_rate.xls"
  ),
  freight_rate = read_file_logistics_census(
    file_freight_rate,
    year = year,
    zone = zone,
    labels = c(mode = "代表輸送機関", commodity_class = "品類名"),
    value = "freight_rate_jpy_per_tonne_km",
    unit = NULL
  ),
)

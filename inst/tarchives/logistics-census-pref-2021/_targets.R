library(targets)
library(tarchetypes)
library(tarchives)

tar_source_archive("freightdatajp")

year <- 2021

tar_plan(
  tar_download_file(
    file_zone,
    url = "https://www.stat.go.jp/data/kokusei/topics/zuhyou/topics135_10.xlsx",
    file = "zone.xlsx"
  ),
  zone = read_file_logistics_census_zone(
    file_zone,
    year = year,
    sheets = "全国",
    angle = "decimal"
  ),

  # IV-1-1 and IV-1-2
  tar_download_file(
    file_flow_commodity_class_weight,
    url = estat_file_url(40041151),
    file = "flow_commodity_class_weight.xlsx"
  ),
  tar_download_file(
    file_flow_commodity_class_n_shipments,
    url = estat_file_url(40041152),
    file = "flow_commodity_class_n_shipments.xlsx"
  ),
  flow_commodity_class = join_logistics_census(
    read_file_logistics_census(
      file_flow_commodity_class_weight,
      year = year,
      zone = zone,
      labels = c(commodity_class = "品類"),
      value = "weight",
      unit = "t"
    ),
    read_file_logistics_census(
      file_flow_commodity_class_n_shipments,
      year = year,
      zone = zone,
      labels = c(commodity_class = "品類"),
      value = "n_shipments",
      unit = NULL
    )
  ),

  # IV-2
  tar_download_file(
    file_flow_commodity,
    url = estat_file_url(40041153),
    file = "flow_commodity.xlsx"
  ),
  flow_commodity = read_file_logistics_census(
    file_flow_commodity,
    year = year,
    zone = zone,
    labels = c(commodity = "品目"),
    value = "weight",
    unit = "t"
  ),

  # V-1-1
  tar_download_file(
    file_flow_mode,
    url = estat_file_url(40041500),
    file = "flow_mode.xlsx"
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
    url = estat_file_url(40041501),
    file = "flow_mode_expressway.xlsx"
  ),
  flow_mode_expressway = read_file_logistics_census(
    file_flow_mode_expressway,
    year = year,
    zone = zone,
    labels = c(mode = "代表輸送機関", expressway = "高速道路"),
    value = "weight",
    unit = "t"
  ),

  # V-2
  tar_download_file(
    file_flow_mode_commodity_class,
    url = estat_file_url(40041502:40041518),
    file = stringr::str_c("flow_mode_commodity_class_", 1:17, ".xlsx")
  ),
  flow_mode_commodity_class = read_file_logistics_census(
    file_flow_mode_commodity_class,
    year = year,
    zone = zone,
    labels = c(mode = "代表輸送機関", commodity_class = "品類"),
    value = "weight",
    unit = "t"
  ),

  # VI-1
  tar_download_file(
    file_time,
    url = estat_file_url(40041343),
    file = "time.xlsx"
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
    url = estat_file_url(40041344:40041360),
    file = stringr::str_c("freight_rate_", 1:17, ".xlsx")
  ),
  freight_rate = read_file_logistics_census(
    file_freight_rate,
    year = year,
    zone = zone,
    labels = c(mode = "代表輸送機関", commodity_class = "品類"),
    value = "freight_rate_jpy_per_tonne_km",
    unit = NULL
  ),
)

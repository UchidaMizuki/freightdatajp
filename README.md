

<!-- README.md is generated from README.qmd. Please edit that file -->

# freightdatajp

<!-- badges: start -->

[![R-CMD-check](https://github.com/UchidaMizuki/freightdatajp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UchidaMizuki/freightdatajp/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

freightdatajp provides ready-to-use interregional freight flow data for
Japan, starting with the interprefectural tables (都道府県間流動表) of
the Net Freight Flow Census (全国貨物純流動調査, the logistics census)
for 2005, 2010, 2015, and 2021.

The tables are built from the published workbooks by
[targets](https://docs.ropensci.org/targets/) pipelines bundled with the
package. The first call for a year downloads the sources and builds the
tables; later calls read them from the cache managed by
[tarchives](https://github.com/UchidaMizuki/tarchives).

## Installation

``` r
# install.packages("pak")
pak::pak("UchidaMizuki/freightdatajp")
```

## Usage

Each function takes the survey year. `logistics_census_flow_get()` also
takes the breakdown of the published table to return, here the
representative transport mode:

``` r
library(freightdatajp)

logistics_census_flow_get(2021, by = "mode")
#> # A tibble: 37,553 × 5
#>     year mode_name    origin_code destination_code weight
#>    <int> <chr>        <chr>       <chr>               [t]
#>  1  2021 鉄道コンテナ 01          01                622. 
#>  2  2021 鉄道コンテナ 01          02                171. 
#>  3  2021 鉄道コンテナ 01          03                 30.7
#>  4  2021 鉄道コンテナ 01          04                657. 
#>  5  2021 鉄道コンテナ 01          05                 28.9
#>  6  2021 鉄道コンテナ 01          06                167. 
#>  7  2021 鉄道コンテナ 01          07                176. 
#>  8  2021 鉄道コンテナ 01          08                487. 
#>  9  2021 鉄道コンテナ 01          09                498. 
#> 10  2021 鉄道コンテナ 01          10                375. 
#> # ℹ 37,543 more rows
```

Origins and destinations are two-digit prefecture codes (`"01"` to
`"47"`), whose names and representative points (population centroids)
are in the zone table:

``` r
logistics_census_zone_get(2021)
#> # A tibble: 47 × 5
#>     year zone_code zone_name longitude latitude
#>    <int> <chr>     <chr>         <dbl>    <dbl>
#>  1  2021 01        北海道         142.     43.1
#>  2  2021 02        青森県         141.     40.7
#>  3  2021 03        岩手県         141.     39.5
#>  4  2021 04        宮城県         141.     38.3
#>  5  2021 05        秋田県         140.     39.7
#>  6  2021 06        山形県         140.     38.4
#>  7  2021 07        福島県         140.     37.4
#>  8  2021 08        茨城県         140.     36.2
#>  9  2021 09        栃木県         140.     36.5
#> 10  2021 10        群馬県         139.     36.4
#> # ℹ 37 more rows
```

The other tables are:

``` r
# Weight (t) between prefectures, by the breakdown of a published table
logistics_census_flow_get(2021, by = "commodity")
logistics_census_flow_get(2021, by = "commodity_class") # with n_shipments
logistics_census_flow_get(2021, by = c("mode", "expressway"))
logistics_census_flow_get(2021, by = c("mode", "commodity_class"))

# Travel time (h per shipment) by mode
logistics_census_time_get(2021)

# Freight rate (yen per tonne-km) by mode and commodity class
logistics_census_freight_rate_get(2021)
```

Every year returns the same columns, types, and units, so tables for
several years can be bound together.

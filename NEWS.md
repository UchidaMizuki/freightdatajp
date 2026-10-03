# freightdatajp (development version)

* Initial version, with the interprefectural tables (都道府県間流動表) of the logistics census (全国貨物純流動調査) for 2005, 2010, 2015, and 2021.
* `logistics_census_flow_get()` returns freight flows between prefectures, with `by` choosing the breakdown of the published table: by commodity, commodity class (with the number of shipments), mode, mode and the use of expressways, or mode and commodity class. `logistics_census_flow_target()` declares a target that reads them.
* `logistics_census_freight_rate_get()` returns freight rates by mode and commodity class, and `logistics_census_freight_rate_target()` declares a target that reads them.
* `logistics_census_time_get()` returns travel times by mode, and `logistics_census_time_target()` declares a target that reads them.
* `logistics_census_zone_get()` returns the prefectures of a survey year, with the population centroids of the census of that year (2020 for the 2021 survey) as representative points, and `logistics_census_zone_target()` declares a target that reads them.

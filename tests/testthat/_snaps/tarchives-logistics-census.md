# a table without its labels is an error

    Code
      parse_cells_logistics_census(read_fixture_cells("logistics-census-block.csv"),
      zone = fixture_zone(), labels = c(mode = "代表輸送機関"))
    Condition
      Error in `parse_cells_logistics_census()`:
      ! Can't find the labels of every table.
      i Labels: "代表輸送機関".
      i Found labels for 0 of 2 tables.

# a table that lacks a zone is an error

    Code
      parse_cells_logistics_census(read_fixture_cells("logistics-census-sheet.csv"),
      zone = zone, labels = c(commodity = "品目"))
    Condition
      Error in `dplyr::mutate()`:
      i In argument: `data = purrr::map(...)`.
      Caused by error in `purrr::map()`:
      i In index: 1.
      Caused by error in `parse_cells_logistics_census_table()`:
      ! Can't find every zone in a table.
      i Found 3 origins and 3 destinations for 4 zones.

# join_logistics_census() joins two values of the same tables

    Code
      join_logistics_census(weight, n_shipments[-1, ])
    Condition
      Error in `dplyr::inner_join()`:
      ! Each row of `x` must have a match in `y`.
      i Row 1 of `x` does not have a match.

# parse_expressway() reads the use of expressways in every year

    Code
      parse_expressway("不明")
    Condition
      Error in `parse_expressway()`:
      ! Can't read the use of expressways.
      x Unknown label: "不明".


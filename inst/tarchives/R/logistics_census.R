# Reads one published table, which can span several files and sheets.
# `labels` names the dimensions of the table and gives the key that labels
# each of them in the workbooks of that year, for example
# `c(mode = "代表輸送機関", commodity_class = "品類名")`. `value` names the
# value column, and `unit` is its unit, or `NULL` for counts and money.
read_file_logistics_census <- function(file, year, zone, labels, value, unit) {
  file |>
    purrr::map(function(file) {
      readxl::excel_sheets(file) |>
        purrr::map(function(sheet) {
          read_cells(file, sheet) |>
            parse_cells_logistics_census(zone = zone, labels = labels)
        }) |>
        purrr::list_rbind()
    }) |>
    purrr::list_rbind() |>
    tidy_logistics_census(year = year, value = value, unit = unit)
}

# Joins the tables of two values with the same dimensions, such as the weight
# and the number of shipments by commodity class.
join_logistics_census <- function(x, y) {
  dplyr::inner_join(
    x,
    y,
    by = intersect(names(x), names(y)),
    unmatched = "error",
    relationship = "one-to-one"
  )
}

tidy_logistics_census <- function(data, year, value, unit) {
  dimensions <- setdiff(
    names(data),
    c("origin_code", "destination_code", "value")
  )
  data <- data |>
    dplyr::mutate(
      year = as.integer(year),
      dplyr::across(dplyr::any_of("mode"), normalize_mode_name),
      dplyr::across(dplyr::any_of("commodity"), normalize_commodity_name),
      dplyr::across(dplyr::any_of("expressway"), parse_expressway),
      value = if (is.null(unit)) {
        .data$value
      } else {
        units::set_units(.data$value, unit, mode = "standard")
      }
    ) |>
    dplyr::select(
      "year",
      dplyr::all_of(dimensions),
      "origin_code",
      "destination_code",
      "value"
    )
  data |>
    dplyr::rename(
      dplyr::any_of(c(
        mode_name = "mode",
        commodity_name = "commodity",
        commodity_class_name = "commodity_class"
      )),
      !!value := "value"
    )
}

# 2005 to 2015 use `･` (U+FF65) in `染料･顔料･塗料`; 2021 uses `・` (U+30FB).
normalize_commodity_name <- function(name) {
  stringr::str_replace_all(name, stringr::fixed("･"), "・")
}

# 2005 to 2015 name subtotals `<mode>計` (`鉄道計`); 2021 names them
# `<mode>（小計）`. The total over all modes, `合計`, is not a subtotal.
normalize_mode_name <- function(name) {
  stringr::str_replace(name, "(?<!^合)計$", "（小計）")
}

# 2005 to 2015 label the use of expressways `利用あり` or `利用なし`; 2021 labels
# it `利用する` or `利用しない`.
parse_expressway <- function(x) {
  used <- dplyr::case_when(
    stringr::str_detect(x, "(なし|しない)$") ~ FALSE,
    stringr::str_detect(x, "(あり|する)$") ~ TRUE
  )
  if (anyNA(used)) {
    unknown <- vctrs::vec_unique(x[is.na(used)])
    cli::cli_abort(c(
      "Can't read the use of expressways.",
      x = "Unknown label{?s}: {.val {unknown}}."
    ))
  }
  used
}

# Handles both layouts, following the unpivotr way for several tables on one
# sheet: the sheet is split into tables at their top-left corners
# (`unpivotr::partition()`), and each table is then read on its own. A table
# starts at its row of labels: a row of keys and values in 2005 to 2015, and
# the title of the sheet in 2021.
parse_cells_logistics_census <- function(cells, zone, labels) {
  label_rows <- parse_cells_logistics_census_labels(cells, labels = labels)$row
  corners <- cells |>
    dplyr::filter(.data$col == 1, vctrs::vec_in(.data$row, label_rows))
  tables <- unpivotr::partition(cells, corners)

  # A table without labels would be dropped silently, so every header row
  # must start a table of its own.
  n_tables <- cells |>
    dplyr::filter(.data$col == 2, is_zone_name(.data$chr, zone)) |>
    nrow()
  if (nrow(tables) != n_tables) {
    cli::cli_abort(c(
      "Can't find the labels of every table.",
      i = "Labels: {.val {labels}}.",
      i = "Found labels for {nrow(tables)} of {n_tables} tables."
    ))
  }

  tables |>
    dplyr::mutate(
      labels = purrr::map(.data$cells, function(cells) {
        parse_cells_logistics_census_table_labels(cells, labels = labels)
      }),
      data = purrr::map(.data$cells, function(cells) {
        parse_cells_logistics_census_table(cells, zone = zone)
      })
    ) |>
    dplyr::select("labels", "data") |>
    tidyr::unnest("labels") |>
    tidyr::unnest("data")
}

# Label keys and values, as a tibble of `row`, `dimension`, and `value`. A key
# is either a cell followed by its value in the same row (2005 to 2015), or
# `<key>：<value>` within a cell (the titles of 2021, for example
# `（１）代表輸送機関：鉄道コンテナ－（１）品類：農水産品［３日間調査］`).
parse_cells_logistics_census_labels <- function(cells, labels) {
  cells <- cells |>
    dplyr::filter(!is.na(.data$chr)) |>
    dplyr::arrange(.data$row, .data$col)
  in_cells <- cells |>
    dplyr::mutate(value = dplyr::lead(.data$chr), .by = "row") |>
    dplyr::select("row", key = "chr", "value")
  # A value within a cell runs to the next label (`－（１）品類：` or
  # `、高速道路：`) or to the note on the survey (`［３日間調査］`). It can't
  # end at a single character: `－` is also used in the title (`－重量－`), and
  # `（` in values (`鉄道（小計）`).
  pattern <- stringr::str_c(
    "(",
    stringr::str_flatten(stringr::str_escape(labels), "|"),
    ")：(.+?)(?=－（|、|［|$)"
  )
  texts <- cells |>
    dplyr::filter(stringr::str_detect(.data$chr, pattern))
  in_text <- purrr::map2(
    texts$row,
    stringr::str_match_all(texts$chr, pattern),
    function(row, match) {
      tibble::tibble(row = row, key = match[, 2], value = match[, 3])
    }
  ) |>
    purrr::list_rbind()

  dplyr::bind_rows(in_cells, in_text) |>
    dplyr::inner_join(
      tibble::tibble(dimension = names(labels), key = unname(labels)),
      by = "key"
    ) |>
    dplyr::filter(!is.na(.data$value)) |>
    dplyr::select("row", "dimension", "value")
}

# The labels of one table, as a one-row tibble with a column per dimension.
parse_cells_logistics_census_table_labels <- function(cells, labels) {
  values <- parse_cells_logistics_census_labels(cells, labels = labels)
  if (
    !setequal(values$dimension, names(labels)) ||
      vctrs::vec_duplicate_any(values$dimension)
  ) {
    cli::cli_abort(c(
      "Can't find each label of a table exactly once.",
      i = "Labels: {.val {labels}}.",
      i = "Found: {.val {values$value}}."
    ))
  }
  values |>
    dplyr::select(!"row") |>
    tidyr::pivot_wider(names_from = "dimension", values_from = "value") |>
    dplyr::select(dplyr::all_of(names(labels)))
}

# The header row is the row whose second cell is a zone. Only rows and columns
# labeled with a zone are kept, which drops the totals (`合計`). Blank cells
# are kept as `NA`.
parse_cells_logistics_census_table <- function(cells, zone) {
  header_row <- cells |>
    dplyr::filter(.data$col == 2, is_zone_name(.data$chr, zone)) |>
    dplyr::pull("row")
  if (length(header_row) != 1) {
    cli::cli_abort(c(
      "Can't find exactly one header row in a table.",
      i = "Found {length(header_row)}."
    ))
  }

  table <- cells |>
    dplyr::filter(.data$row >= header_row) |>
    unpivotr::behead("up", "destination_name", drop_na = FALSE) |>
    unpivotr::behead("left", "origin_name", drop_na = FALSE) |>
    dplyr::filter(
      is_zone_name(.data$origin_name, zone),
      is_zone_name(.data$destination_name, zone)
    ) |>
    dplyr::arrange(.data$row, .data$col)

  n_origins <- dplyr::n_distinct(table$origin_name)
  n_destinations <- dplyr::n_distinct(table$destination_name)
  if (n_origins != nrow(zone) || n_destinations != nrow(zone)) {
    cli::cli_abort(c(
      "Can't find every zone in a table.",
      i = stringr::str_c(
        "Found {n_origins} origins and {n_destinations} destinations for ",
        "{nrow(zone)} zones."
      )
    ))
  }

  tibble::tibble(
    origin_code = zone_name_to_code(table$origin_name, zone),
    destination_code = zone_name_to_code(table$destination_name, zone),
    value = as.numeric(table$chr)
  )
}

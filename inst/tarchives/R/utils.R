# Downloads into the store, so that source files are cached with the targets
# instead of being written into the installed package. `url` and `file` can
# have several elements, for a table published as several files.
download_file <- function(url, file) {
  path <- fs::path(targets::tar_path_store(), "user", file)
  fs::dir_create(fs::path_dir(path))
  purrr::walk2(url, path, \(url, path) curl::curl_download(url, path))
  path
}

# A target that downloads `url` into `file` and tracks it as a file.
tar_download_file <- function(name, url, file) {
  targets::tar_target_raw(
    rlang::as_name(rlang::ensym(name)),
    rlang::call2("download_file", url = url, file = file),
    format = "file"
  )
}

estat_file_url <- function(id) {
  stringr::str_c(
    "https://www.e-stat.go.jp/stat-search/file-download?statInfId=",
    stringr::str_pad(id, width = 12, pad = "0"),
    "&fileKind=0"
  )
}

# Cells in the long format of tidyxl and unpivotr (`row`, `col`, `data_type`,
# `chr`), with blank cells kept as `NA`. tidyxl can't read the `.xls`
# workbooks of 2005 to 2015, so every workbook is read with readxl and
# converted with `unpivotr::as_cells()`.
read_cells <- function(file, sheet) {
  readxl::read_excel(
    file,
    sheet = sheet,
    col_names = FALSE,
    col_types = "text",
    .name_repair = "minimal"
  ) |>
    as_label_cells()
}

as_label_cells <- function(data) {
  unpivotr::as_cells(data) |>
    dplyr::mutate(chr = squish_label(.data$chr))
}

# Removes all whitespace, including the full-width spaces used to align
# labels in the 2005 to 2015 workbooks (for example `北　 海 　道`).
squish_label <- function(x) {
  stringr::str_remove_all(x, "\\s")
}

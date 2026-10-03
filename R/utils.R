logistics_census_package <- "freightdatajp"

# The survey years are those of the bundled `logistics-census-pref-<year>`
# pipelines.
logistics_census_years <- function() {
  pipelines <- tarchives::tar_archive_pipelines(
    package = logistics_census_package
  )
  years <- stringr::str_match(pipelines, "^logistics-census-pref-(\\d+)$")[, 2]
  sort(years[!is.na(years)])
}

logistics_census_pipeline <- function(year, error_call = rlang::caller_env()) {
  rlang::check_number_whole(year, call = error_call)
  year <- rlang::arg_match0(
    as.character(year),
    logistics_census_years(),
    arg_nm = "year",
    error_call = error_call
  )
  stringr::str_c("logistics-census-pref-", year)
}

# The breakdowns of the published flow tables, which `by` chooses from.
logistics_census_flow_by <- list(
  "commodity",
  "commodity_class",
  "mode",
  c("mode", "expressway"),
  c("mode", "commodity_class")
)

# The name of the flow target for `by`, in any order (`flow_mode_expressway`).
logistics_census_flow_name <- function(by, error_call = rlang::caller_env()) {
  i <- if (is.character(by) && !anyNA(by)) {
    purrr::detect_index(logistics_census_flow_by, function(option) {
      setequal(by, option) && length(by) == length(option)
    })
  } else {
    0
  }
  if (i == 0) {
    options <- purrr::map_chr(logistics_census_flow_by, function(option) {
      quoted <- stringr::str_c('"', option, '"', collapse = ", ")
      if (length(option) == 1) quoted else stringr::str_c("c(", quoted, ")")
    })
    cli::cli_abort(
      c(
        "{.arg by} must be one of the breakdowns of the published tables:",
        rlang::set_names(stringr::str_c("{.code ", options, "}"), "*")
      ),
      call = error_call
    )
  }
  stringr::str_c(
    "flow_",
    stringr::str_c(logistics_census_flow_by[[i]], collapse = "_")
  )
}

logistics_census_get <- function(
  name,
  year,
  error_call = rlang::caller_env()
) {
  tar_get_archive_raw(
    name = name,
    package = logistics_census_package,
    pipeline = logistics_census_pipeline(year, error_call = error_call)
  )
}

logistics_census_target_raw <- function(
  name,
  name_archive,
  year,
  ...,
  error_call = rlang::caller_env()
) {
  tar_target_archive_raw(
    name = name,
    package = logistics_census_package,
    pipeline = logistics_census_pipeline(year, error_call = error_call),
    name_archive = name_archive,
    ...
  )
}

#' Declare a target that reads interprefectural travel times
#'
#' For use inside a `_targets.R` pipeline, for example
#' `tar_plan(logistics_census_time_target(time, year = 2021))`. The
#' target reads the same table as [logistics_census_time_get()].
#' `logistics_census_time_target()` captures `name` with non-standard
#' evaluation, like [tarchives::tar_target_archive()];
#' `logistics_census_time_target_raw()` takes it as a string, like
#' [tarchives::tar_target_archive_raw()].
#'
#' @param name Symbol (`logistics_census_time_target()`) or string
#'   (`logistics_census_time_target_raw()`), the name of the target.
#' @inheritParams logistics_census_flow_get
#' @param ... Arguments passed to [tarchives::tar_target_archive_raw()].
#'
#' @inherit tarchives::tar_target_archive return
#'
#' @export
logistics_census_time_target <- function(name, year, ...) {
  logistics_census_time_target_raw(
    name = targets::tar_deparse_language(substitute(name)),
    year = year,
    ...
  )
}

#' @rdname logistics_census_time_target
#' @export
logistics_census_time_target_raw <- function(name, year, ...) {
  rlang::check_required(name)
  rlang::check_required(year)
  logistics_census_target_raw(
    name = name,
    name_archive = "time",
    year = year,
    ...
  )
}

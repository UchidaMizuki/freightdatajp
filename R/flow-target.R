#' Declare a target that reads interprefectural freight flows
#'
#' For use inside a `_targets.R` pipeline, for example
#' `tar_plan(logistics_census_flow_target(flow, year = 2021, by = "mode"))`.
#' The target reads the same table as [logistics_census_flow_get()].
#' `logistics_census_flow_target()` captures `name` with non-standard
#' evaluation, like [tarchives::tar_target_archive()];
#' `logistics_census_flow_target_raw()` takes it as a string, like
#' [tarchives::tar_target_archive_raw()].
#'
#' @param name Symbol (`logistics_census_flow_target()`) or string
#'   (`logistics_census_flow_target_raw()`), the name of the target.
#' @inheritParams logistics_census_flow_get
#' @param ... Arguments passed to [tarchives::tar_target_archive_raw()].
#'
#' @inherit tarchives::tar_target_archive return
#'
#' @export
logistics_census_flow_target <- function(name, year, by, ...) {
  logistics_census_flow_target_raw(
    name = targets::tar_deparse_language(substitute(name)),
    year = year,
    by = by,
    ...
  )
}

#' @rdname logistics_census_flow_target
#' @export
logistics_census_flow_target_raw <- function(name, year, by, ...) {
  rlang::check_required(name)
  rlang::check_required(year)
  rlang::check_required(by)
  logistics_census_target_raw(
    name = name,
    name_archive = logistics_census_flow_name(by),
    year = year,
    ...
  )
}

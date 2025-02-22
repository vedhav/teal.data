#' Include `JS` files from `/inst/js/` package directory to application header
#'
#' `system.file` should not be used to access files in other packages, it does
#' not work with `devtools`. Therefore, we redefine this method in each package
#' as needed. Thus, we do not export this method
#'
#' @param pattern (`character`) pattern of files to be included, passed to `system.file`
#' @param except (`character`) vector of basename filenames to be excluded
#'
#' @return HTML code that includes `JS` files
#' @keywords internal
include_js_files <- function(pattern = NULL, except = NULL) {
  checkmate::assert_character(except, min.len = 1, any.missing = FALSE, null.ok = TRUE)
  js_files <- list.files(
    system.file("js", package = "teal.data", mustWork = TRUE),
    pattern = pattern, full.names = TRUE
  )
  js_files <- js_files[!(basename(js_files) %in% except)] # no-op if except is NULL
  if (length(js_files) == 0) {
    return(NULL)
  }
  return(singleton(lapply(js_files, includeScript)))
}

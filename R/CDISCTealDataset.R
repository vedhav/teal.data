## CDISCTealDataset ====
#'
#' @title R6 Class representing a dataset with parent attribute
#'
#' @description `r lifecycle::badge("stable")`
#' Any `data.frame` object can be stored inside this object.
#'
#' The difference compared to `TealDataset` class is a parent field that
#' indicates name of the parent dataset. Note that the parent field might
#' be empty (i.e. `character(0)`).
#'
#' @param dataname (`character`)\cr
#'  A given name for the dataset it may not contain spaces
#'
#' @param x (`data.frame`)\cr
#'
#' @param keys (`character`)\cr
#'   vector with primary keys
#'
#' @param parent optional, (`character`) \cr
#'   parent dataset name
#'
#' @param code (`character`)\cr
#'   A character string defining the code needed to produce the data set in `x`
#'
#' @param label (`character`)\cr
#'   Label to describe the dataset
#'
#' @param vars (named `list`)) \cr
#'   In case when this object code depends on other `TealDataset` object(s) or
#'   other constant value, this/these object(s) should be included as named
#'   element(s) of the list. For example if this object code needs `ADSL`
#'   object we should specify `vars = list(ADSL = <adsl object>)`.
#'   It is recommended to include `TealDataset` or `TealDatasetConnector` objects to
#'   the `vars` list to preserve reproducibility. Please note that `vars`
#'   are included to this object as local `vars` and they cannot be modified
#'   within another dataset.
#'
#' @param metadata (named `list` or `NULL`) \cr
#'   Field containing metadata about the dataset. Each element of the list
#'   should be atomic and length one.
#'
#' @examples
#' x <- cdisc_dataset(
#'   dataname = "XYZ",
#'   x = data.frame(x = c(1, 2), y = c("a", "b"), stringsAsFactors = FALSE),
#'   keys = "y",
#'   parent = "ABC",
#'   code = "XYZ <- data.frame(x = c(1, 2), y = c('aa', 'bb'),
#'                             stringsAsFactors = FALSE)",
#'   metadata = list(type = "example")
#' )
#'
#' x$ncol
#' x$get_code()
#' x$get_dataname()
#' x$get_keys()
#' x$get_parent()
CDISCTealDataset <- R6::R6Class( # nolint
  "CDISCTealDataset",
  inherit = TealDataset,
  ## __Public Methods ====
  public = list(
    #' @description
    #' Create a new object of `CDISCTealDataset` class
    initialize = function(dataname, x, keys, parent, code = character(0),
                          label = character(0), vars = list(), metadata = NULL) {
      checkmate::assert_character(parent, max.len = 1, any.missing = FALSE)
      super$initialize(
        dataname = dataname, x = x, keys = keys, code = code,
        label = label, vars = vars, metadata = metadata
      )

      self$set_parent(parent)
      logger::log_trace("CDISCTealDataset initialized for dataset: { deparse1(self$get_dataname()) }.")
      return(invisible(self))
    },
    #' @description
    #' Recreate a dataset with its current attributes
    #' This is useful way to have access to class initialize method basing on class object
    #'
    #' @return a new object of `CDISCTealDataset` class
    recreate = function(dataname = self$get_dataname(),
                        x = self$get_raw_data(),
                        keys = self$get_keys(),
                        parent = self$get_parent(),
                        code = private$code,
                        label = self$get_dataset_label(),
                        vars = list(),
                        metadata = self$get_metadata()) {
      res <- self$initialize(
        dataname = dataname,
        x = x,
        keys = keys,
        parent = parent,
        code = code,
        label = label,
        vars = vars,
        metadata = metadata
      )
      logger::log_trace("CDISCTealDataset$recreate recreated dataset: { deparse1(self$get_dataname()) }.")
      return(res)
    },
    #' @description
    #' Get all dataset attributes
    #' @return (named `list`) with dataset attributes
    get_attrs = function() {
      x <- super$get_attrs()
      x <- append(
        x,
        list(
          parent = self$get_parent()
        )
      )
      return(x)
    },
    #' @description
    #' Get parent dataset name
    #' @return (`character`) indicating parent `dataname`
    get_parent = function() {
      return(private$parent)
    },
    #' @description
    #' Set parent dataset name
    #' @param parent (`character`) indicating parent `dataname`
    #' @return (`self`) invisibly for chaining
    set_parent = function(parent) {
      checkmate::assert_character(parent, max.len = 1, any.missing = FALSE)
      private$parent <- parent

      logger::log_trace("CDISCTealDataset$set_parent parent set for dataset: { deparse1(self$get_dataname()) }.")
      return(invisible(self))
    }
  ),
  ## __Private Fields ====
  private = list(
    parent = character(0)
  )
)

# constructors ====
#' Create a new object of `CDISCTealDataset` class
#'
#' @description `r lifecycle::badge("stable")`
#' Function that creates `CDISCTealDataset` object
#'
#' @inheritParams dataset
#' @param parent (`character`, optional) parent dataset name
#'
#' @return (`CDISCTealDataset`) a dataset with connected metadata
#'
#' @export
#'
#' @examples
#' ADSL <- example_cdisc_data("ADSL")
#'
#' cdisc_dataset("ADSL", ADSL, metadata = list(type = "teal.data"))
cdisc_dataset <- function(dataname,
                          x,
                          keys = get_cdisc_keys(dataname),
                          parent = `if`(identical(dataname, "ADSL"), character(0), "ADSL"),
                          label = data_label(x),
                          code = character(0),
                          vars = list(),
                          metadata = NULL) {
  CDISCTealDataset$new(
    dataname = dataname,
    x = x,
    keys = keys,
    parent = parent,
    label = label,
    code = code,
    vars = vars,
    metadata = metadata
  )
}

#' Load `CDISCTealDataset` object from a file
#'
#' @description `r lifecycle::badge("experimental")`
#' Please note that the script has to end with a call creating desired object. The error will be raised otherwise.
#'
#' @inheritParams dataset_file
#'
#' @return (`CDISCTealDataset`) object
#'
#' @export
#'
#' @examples
#' # simple example
#' file_example <- tempfile(fileext = ".R")
#' writeLines(
#'   text = c(
#'     "library(teal.data)
#'      cdisc_dataset(dataname = \"ADSL\",
#'                    x = teal.data::example_cdisc_data(\"ADSL\"),
#'                    code = \"ADSL <- teal.data::example_cdisc_data('ADSL')\")"
#'   ),
#'   con = file_example
#' )
#' x <- cdisc_dataset_file(file_example, code = character(0))
#' get_code(x)
cdisc_dataset_file <- function(path, code = get_code(path)) {
  object <- object_file(path, "CDISCTealDataset")
  object$set_code(code)
  return(object)
}

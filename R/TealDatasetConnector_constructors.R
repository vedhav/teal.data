#' Create a new `TealDatasetConnector` object
#'
#' `r lifecycle::badge("stable")`
#'
#' Create `TealDatasetConnector` from [callable_function].
#'
#' @param dataname (`character`)\cr
#'  A given name for the dataset it may not contain spaces
#'
#' @param pull_callable (`CallableFunction`)\cr
#'   function with necessary arguments set to fetch data from connection.
#'
#' @param keys optional, (`character`)\cr
#'  vector of dataset primary keys column names
#'
#' @param label (`character`)\cr
#'  Label to describe the dataset.
#'
#' @param code (`character`)\cr
#'  A character string defining code to modify `raw_data` from this dataset. To modify
#'  current dataset code should contain at least one assignment to object defined in `dataname`
#'  argument. For example if `dataname = ADSL` example code should contain
#'  `ADSL <- <some R code>`. Can't be used simultaneously with `script`
#'
#' @param script (`character`)\cr
#'   Alternatively to `code` - location of the file containing modification code.
#'   Can't be used simultaneously with `script`.
#'
#' @param vars (named `list`)) \cr
#'   In case when this object code depends on other `TealDataset` object(s) or
#'   other constant value, this/these object(s) should be included as named
#'   element(s) of the list. For example if this object code needs `ADSL`
#'   object we should specify `vars = list(ADSL = <adsl object>)`.
#'   It's recommended to include `TealDataset` or `TealDatasetConnector` objects to
#'   the `vars` list to preserve reproducibility. Please note that `vars`
#'   are included to this object as local `vars` and they cannot be modified
#'   within another dataset.
#'
#' @param metadata (named `list`, `NULL` or `CallableFunction`) \cr
#'   Field containing either the metadata about the dataset (each element of the list
#'   should be atomic and length one) or a `CallableFuntion` to pull the metadata
#'   from a connection. This should return a `list` or an object which can be
#'   converted to a list with `as.list`.
#' @return new `TealDatasetConnector` object
#'
#' @examples
#' library(MultiAssayExperiment)
#' # data.frame example
#' pull_fun2 <- callable_function(data.frame)
#' pull_fun2$set_args(args = list(a = c(1, 2, 3)))
#' dataset_connector("test", pull_fun2)
#'
#' # MultiAssayExperiment example
#' pull_fun <- callable_function(
#'   function() {
#'     library("MultiAssayExperiment")
#'     data("miniACC")
#'     return(miniACC)
#'   }
#' )
#' dataset_connector(
#'   "miniacc",
#'   pull_fun,
#'   code = 'library("MultiAssayExperiment"); data("miniACC"); return(miniACC)'
#' )
#' @export
dataset_connector <- function(dataname,
                              pull_callable,
                              keys = character(0),
                              label = character(0),
                              code = character(0),
                              script = character(0),
                              vars = list(),
                              metadata = NULL) {
  checkmate::assert_string(dataname)
  stopifnot(inherits(pull_callable, "Callable"))
  checkmate::assert_character(keys, any.missing = FALSE)
  checkmate::assert_character(code, any.missing = FALSE)
  checkmate::assert_character(label, any.missing = FALSE)

  if (!checkmate::test_class(metadata, "Callable", null.ok = TRUE)) {
    validate_metadata(metadata)
  }

  x <- TealDatasetConnector$new(
    dataname = dataname,
    pull_callable = pull_callable,
    keys = keys,
    code = code_from_script(code, script),
    label = label,
    vars = vars,
    metadata = metadata
  )

  return(x)
}

#' Create a new `CDISCTealDatasetConnector` object
#'
#' `r lifecycle::badge("stable")`
#'
#' Create `CDISCTealDatasetConnector` from [callable_function].
#'
#' @inheritParams dataset_connector
#' @inheritParams cdisc_dataset
#'
#' @return new `CDISCTealDatasetConnector` object
#'
#' @export
cdisc_dataset_connector <- function(dataname,
                                    pull_callable,
                                    keys,
                                    parent = `if`(identical(dataname, "ADSL"), character(0), "ADSL"),
                                    label = character(0),
                                    code = character(0),
                                    script = character(0),
                                    vars = list(),
                                    metadata = NULL) {
  checkmate::assert_string(dataname)
  stopifnot(inherits(pull_callable, "Callable"))
  checkmate::assert_character(keys, any.missing = FALSE)
  checkmate::assert_character(parent, max.len = 1, any.missing = FALSE)
  checkmate::assert_character(code, max.len = 1, any.missing = FALSE)
  checkmate::assert_character(label, max.len = 1, any.missing = FALSE)

  if (!checkmate::test_class(metadata, "Callable", null.ok = TRUE)) {
    validate_metadata(metadata)
  }

  x <- CDISCTealDatasetConnector$new(
    dataname = dataname,
    pull_callable = pull_callable,
    keys = keys,
    parent = parent,
    code = code_from_script(code, script),
    label = label,
    vars = vars,
    metadata = metadata
  )

  return(x)
}


#' Load `TealDatasetConnector` object from a file
#'
#' `r lifecycle::badge("stable")`
#'
#' Please note that the script has to end with a call creating desired object. The error will
#' be raised otherwise.
#'
#' @inheritParams dataset_file
#'
#' @return `TealDatasetConnector` object
#'
#' @rdname dataset_connector_file
#'
#' @export
#'
#' @examples
#' # simple example
#' library(magrittr)
#' file_example <- tempfile(fileext = ".R")
#' writeLines(
#'   text = c(
#'     "library(teal.data)
#'
#'      pull_callable <- callable_function(teal.data::example_cdisc_data) %>%
#'        set_args(list(dataname = \"ADSL\"))
#'      dataset_connector(\"ADSL\", pull_callable, get_cdisc_keys(\"ADSL\"))"
#'   ),
#'   con = file_example
#' )
#' x <- dataset_connector_file(file_example)
#' get_code(x)
dataset_connector_file <- function(path) { # nolint
  object <- object_file(path, "TealDatasetConnector")
  return(object)
}

#' Load `CDISCTealDatasetConnector` object from a file
#'
#' `r lifecycle::badge("stable")`
#'
#' Please note that the script has to end with a call creating desired object. The error will
#' be raised otherwise.
#'
#' @inheritParams dataset_connector_file
#'
#' @return `CDISCTealDatasetConnector` object
#'
#' @rdname dataset_connector_file
#'
#' @export
#'
#' @examples
#' # simple example
#' library(magrittr)
#' file_example <- tempfile(fileext = ".R")
#' writeLines(
#'   text = c(
#'     "library(teal.data)
#'
#'      pull_callable <- callable_function(teal.data::example_cdisc_data) %>%
#'        set_args(list(dataname = \"ADSL\"))
#'      cdisc_dataset_connector(\"ADSL\", pull_callable, get_cdisc_keys(\"ADSL\"))"
#'   ),
#'   con = file_example
#' )
#' x <- cdisc_dataset_connector_file(file_example)
#' get_code(x)
cdisc_dataset_connector_file <- function(path) { # nolint
  object <- object_file(path, "CDISCTealDatasetConnector")
  return(object)
}

# RDS ====
#' `RDS` `TealDatasetConnector`
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `TealDatasetConnector` from `RDS` file.
#'
#' @inheritParams dataset_connector
#' @inheritParams fun_dataset_connector
#' @param file (`character`)\cr
#'   path to (`.rds` or `.R`) that contains `data.frame` object or
#'   code to `source`
#'
#' @param ... (`optional`)\cr
#'   additional arguments applied to [base::readRDS()] function
#'
#' @export
#'
#' @rdname rds_dataset_connector
#'
#' @examples
#' \dontrun{
#' x <- rds_dataset_connector(
#'   dataname = "ADSL",
#'   file = "path/to/file.RDS"
#' )
#' x$get_code()
#' }
rds_dataset_connector <- function(dataname,
                                  file,
                                  keys = character(0),
                                  label = character(0),
                                  code = character(0),
                                  script = character(0),
                                  metadata = list(type = "rds", file = file),
                                  ...) {
  dot_args <- list(...)
  checkmate::assert_list(dot_args, min.len = 0, names = "unique")
  checkmate::assert_string(file)
  if (!file.exists(file)) {
    stop("File ", file, " does not exist.", call. = FALSE)
  }

  x_fun <- callable_function(readRDS) # nolint
  args <- c(list(file = file), dot_args)
  x_fun$set_args(args)

  x <- dataset_connector(
    dataname = dataname,
    pull_callable = x_fun,
    keys = keys,
    label = label,
    code = code_from_script(code, script),
    metadata = metadata
  )

  return(x)
}

#' `RDS` `CDSICTealDatasetConnector`
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `CDSICTealDatasetConnector` from `RDS` file with keys automatically
#' assigned by `dataname`
#'
#' @inheritParams rds_dataset_connector
#' @inheritParams cdisc_dataset_connector
#'
#' @rdname rds_dataset_connector
#'
#' @export
rds_cdisc_dataset_connector <- function(dataname,
                                        file,
                                        keys = get_cdisc_keys(dataname),
                                        parent = `if`(identical(dataname, "ADSL"), character(0L), "ADSL"),
                                        label = character(0),
                                        code = character(0),
                                        script = character(0),
                                        metadata = list(type = "rds", file = file),
                                        ...) {
  x <- rds_dataset_connector(
    dataname = dataname,
    file = file,
    keys = keys,
    code = code_from_script(code, script),
    label = label,
    metadata = metadata,
    ...
  )

  res <- as_cdisc(
    x,
    parent = parent
  )

  return(res)
}


# SCRIPT ====
#' Script `TealDatasetConnector`
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `TealDatasetConnector` from `.R` file.
#'
#' @inheritParams dataset_connector
#' @inheritParams fun_dataset_connector
#' @param file (`character`)\cr
#'   file location containing code to be evaluated in connector. Object obtained in the last
#'   call from file will be returned to the connector - same as `source(file = file)$value`
#'
#' @export
#'
#' @rdname script_dataset_connector
#'
#' @examples
#' \dontrun{
#' x <- script_dataset_connector(
#'   dataname = "ADSL",
#'   file = "path/to/script.R",
#'   keys = get_cdisc_keys("ADSL")
#' )
#' x$get_code()
#' }
script_dataset_connector <- function(dataname,
                                     file,
                                     keys = character(0),
                                     label = character(0),
                                     code = character(0),
                                     script = character(0),
                                     metadata = NULL,
                                     ...) {
  vars <- list(...)
  checkmate::assert_list(vars, min.len = 0, names = "unique")
  checkmate::assert_string(file)
  if (!file.exists(file)) {
    stop("File ", file, " does not exist.", call. = FALSE)
  }

  x_fun <- callable_function(source) # nolint
  x_fun$set_args(list(file = file, local = TRUE))

  x <- dataset_connector(
    dataname = dataname,
    pull_callable = x_fun,
    keys = keys,
    label = label,
    code = code_from_script(code, script),
    vars = vars,
    metadata = metadata
  )

  return(x)
}

#' Script `CDISCTealDatasetConnector`
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `CDISCTealDatasetConnector` from `script` file with keys assigned
#' automatically by `dataname`.
#'
#' @inheritParams script_dataset_connector
#' @inheritParams cdisc_dataset_connector
#'
#' @rdname script_dataset_connector
#'
#' @export
script_cdisc_dataset_connector <- function(dataname,
                                           file,
                                           keys = get_cdisc_keys(dataname),
                                           parent = `if`(identical(dataname, "ADSL"), character(0L), "ADSL"),
                                           label = character(0),
                                           code = character(0),
                                           script = character(0),
                                           metadata = NULL,
                                           ...) {
  x <- script_dataset_connector(
    dataname = dataname,
    file = file,
    keys = keys,
    code = code_from_script(code, script),
    script = script,
    label = label,
    metadata = metadata,
    ...
  )

  res <- as_cdisc(
    x,
    parent = parent
  )

  return(res)
}


# CODE ====
#' Code `TealDatasetConnector`
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `TealDatasetConnector` from a string of code.
#'
#' @inheritParams dataset_connector
#' @inheritParams fun_dataset_connector
#'
#' @param code (`character`)\cr
#'   String containing the code to produce the object.
#'   The code must end in a call to the object.
#' @param mutate_code (`character`)\cr
#'   String containing the code used to mutate the object
#'   after it is produced.
#' @param mutate_script (`character`)\cr
#'   Alternatively to `mutate_code` - location of the file containing modification code.
#'   Can't be used simultaneously with `mutate_script`.
#'
#' @export
#'
#' @rdname code_dataset_connector
#'
#' @examples
#' x <- code_dataset_connector(
#'   dataname = "ADSL",
#'   keys = get_cdisc_keys("ADSL"),
#'   code = "ADSL <- teal.data::example_cdisc_data(\"ADSL\"); ADSL"
#' )
#'
#' x$get_code()
#'
#' mutate_dataset(x, code = "ADSL$new_variable <- 1")
#' x$get_code()
#'
#' file_example <- tempfile(fileext = ".R")
#' writeLines(
#'   text = c(
#'     "seed <- 1; ADSL <- radsl(cached = TRUE, seed = seed)\nADSL"
#'   ),
#'   con = file_example
#' )
#'
#' y <- code_dataset_connector(
#'   dataname = "ADSL",
#'   keys = get_cdisc_keys("ADSL"),
#'   code = paste0(readLines(file_example), collapse = "\n")
#' )
code_dataset_connector <- function(dataname,
                                   code,
                                   keys = character(0),
                                   label = character(0),
                                   mutate_code = character(0),
                                   mutate_script = character(0),
                                   metadata = NULL,
                                   ...) {
  vars <- list(...)
  checkmate::assert_list(vars, min.len = 0, names = "unique")
  checkmate::assert_string(code)
  checkmate::assert_character(label, max.len = 1, any.missing = FALSE)

  call <- callable_code(code = code)

  x <- dataset_connector(
    dataname = dataname,
    pull_callable = call,
    keys = keys,
    label = label,
    code = code_from_script(mutate_code, mutate_script),
    vars = vars,
    metadata = metadata
  )

  return(x)
}

#' Code `CDISCTealDatasetConnector`
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `CDISCTealDatasetConnector` from a string of code with keys
#' assigned automatically by `dataname`.
#'
#' @inheritParams code_dataset_connector
#' @inheritParams cdisc_dataset_connector
#'
#' @rdname code_dataset_connector
#'
#' @export
code_cdisc_dataset_connector <- function(dataname,
                                         code,
                                         keys = get_cdisc_keys(dataname),
                                         parent = `if`(identical(dataname, "ADSL"), character(0L), "ADSL"),
                                         label = character(0),
                                         mutate_code = character(0),
                                         metadata = NULL,
                                         ...) {
  x <- code_dataset_connector(
    dataname = dataname,
    code = code,
    keys = keys,
    mutate_code = mutate_code,
    label = label,
    metadata = metadata,
    ...
  )

  res <- as_cdisc(
    x,
    parent = parent
  )

  return(res)
}

# CSV ====
#' `csv` `TealDatasetConnector`
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `TealDatasetConnector` from `csv` (or general delimited file).
#'
#'
#' @inheritParams dataset_connector
#' @inheritParams fun_dataset_connector
#'
#' @param file (`character`)\cr
#'   path to (`.csv)` (or general delimited) file that contains `data.frame` object
#'
#' @param ... (`optional`)\cr
#'   additional arguments applied to pull function (`readr::read_delim`) by default
#'   `delim = ","`.
#'
#' @export
#'
#' @rdname csv_dataset_connector
#'
#' @examples
#' \dontrun{
#' x <- csv_dataset_connector(
#'   dataname = "ADSL",
#'   file = "path/to/file.csv",
#'   delim = ",",
#'   col_types = quote(readr::cols(AGE = "i"))
#' )
#' x$get_code()
#' }
csv_dataset_connector <- function(dataname,
                                  file,
                                  keys = character(0),
                                  label = character(0),
                                  code = character(0),
                                  script = character(0),
                                  metadata = list(type = "csv", file = file),
                                  ...) {
  dot_args <- list(...)
  checkmate::assert_list(dot_args, min.len = 0, names = "unique")

  check_pkg_quietly(
    "readr",
    "library readr is required to use csv connectors please install it."
  )

  # add default delim as ","
  if (!"delim" %in% names(dot_args)) {
    dot_args$delim <- ","
  }

  checkmate::assert_string(file)
  if (!file.exists(file)) {
    stop("File ", file, " does not exist.", call. = FALSE)
  }

  x_fun <- callable_function("readr::read_delim") # using read_delim as preserves dates (read.csv does not)
  args <- c(list(file = file), dot_args)
  x_fun$set_args(args)

  x <- dataset_connector(
    dataname = dataname,
    pull_callable = x_fun,
    keys = keys,
    label = label,
    code = code_from_script(code, script),
    metadata = metadata
  )

  return(x)
}

#' `csv` `CDISCTealDatasetConnector`
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `CDISCTealDatasetConnector` from `csv` (or general delimited) file
#' with keys and parent name assigned automatically by `dataname`.
#'
#' @inheritParams csv_dataset_connector
#' @inheritParams cdisc_dataset_connector
#'
#' @rdname csv_dataset_connector
#'
#' @export
csv_cdisc_dataset_connector <- function(dataname,
                                        file,
                                        keys = get_cdisc_keys(dataname),
                                        parent = `if`(identical(dataname, "ADSL"), character(0L), "ADSL"),
                                        label = character(0),
                                        code = character(0),
                                        script = character(0),
                                        metadata = list(type = "csv", file = file),
                                        ...) {
  x <- csv_dataset_connector(
    dataname = dataname,
    file = file,
    keys = keys,
    code = code_from_script(code, script),
    label = label,
    metadata = metadata,
    ...
  )

  res <- as_cdisc(
    x,
    parent = parent
  )

  return(res)
}

# FUN ====
#' Function Dataset Connector
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `TealDatasetConnector` from `function` and its arguments.
#'
#' @inheritParams dataset_connector
#'
#' @param fun (`function`)\cr
#'   a custom function to obtain dataset.
#' @param fun_args (`list`)\cr
#'   additional arguments for (`func`).
#' @param func_name (`name`)\cr
#'   for internal purposes, please keep it default
#' @param ... Additional arguments applied to pull function.
#'   In case when this object code depends on the `raw_data` from the other
#'   `TealDataset`, `TealDatasetConnector` object(s) or other constant value,
#'   this/these object(s) should be included. Please note that `vars`
#'   are included to this object as local `vars` and they cannot be modified
#'   within another dataset.
#' @export
#'
#' @rdname fun_dataset_connector
#'
#' @examples
#' my_data <- function(...) {
#'   data.frame(
#'     ID = paste0("ABC_", seq_len(10)),
#'     var1 = rnorm(n = 10),
#'     var2 = rnorm(n = 10),
#'     var3 = rnorm(n = 10)
#'   )
#' }
#' y <- fun_dataset_connector(
#'   dataname = "XYZ",
#'   fun = my_data
#' )
#'
#' y$get_code()
#'
#' y$pull()
#'
#' get_raw_data(y)
fun_dataset_connector <- function(dataname,
                                  fun,
                                  fun_args = NULL,
                                  keys = character(0),
                                  label = character(0),
                                  code = character(0),
                                  script = character(0),
                                  func_name = substitute(fun),
                                  metadata = NULL,
                                  ...) {
  vars <- list(...)
  checkmate::assert_list(vars, min.len = 0, names = "unique")

  stopifnot(is.function(fun))

  stopifnot(is.list(fun_args) || is.null(fun_args))

  cal <- if (!is.symbol(func_name)) as.call(func_name) else NULL

  is_pak <- FALSE
  is_locked <- TRUE
  if ((!is.null(cal)) && identical(cal[[1]], as.symbol("::"))) {
    pak <- cal[[2]]
    pak_char <- as.character(pak) # nolint
    library(pak_char, character.only = TRUE)
    func_name <- cal[[3]]
    is_pak <- TRUE
    is_locked <- TRUE
  } else {
    is_locked <- environmentIsLocked(environment(fun))
  }

  func_char <- as.character(func_name)

  ee <- new.env(parent = parent.env(globalenv()))

  ee$library <- function(...) {
    mc <- match.call()
    mc[[1]] <- quote(base::library)
    eval(mc, envir = globalenv())
    this_env <- parent.frame()
    if (!identical(this_env, globalenv())) {
      parent.env(this_env) <- parent.env(globalenv())
    }
  }


  if (!is_pak && !is_locked) {
    eval(bquote(.(func_name) <- get(.(func_char), .(environment(fun)))), envir = ee)
    eval(bquote(.(func_name) <- rlang::set_env(.(func_name), .(ee))), envir = ee)
  }

  x_fun <- CallableFunction$new(fun, env = ee)
  x_fun$set_args(fun_args)

  vars[[func_char]] <- ee[[func_char]]

  x <- dataset_connector(
    dataname = dataname,
    pull_callable = x_fun,
    keys = keys,
    code = code_from_script(code, script),
    label = label,
    vars = vars,
    metadata = metadata
  )

  return(x)
}

#' Function `CDISCTealDatasetConnector`
#'
#' `r lifecycle::badge("stable")`
#'
#' Create a `CDISCTealDatasetConnector` from `function` and its arguments
#' with keys and parent name assigned automatically by `dataname`.
#'
#' @inheritParams fun_dataset_connector
#' @inheritParams cdisc_dataset_connector
#'
#' @rdname fun_dataset_connector
#'
#' @export
fun_cdisc_dataset_connector <- function(dataname,
                                        fun,
                                        fun_args = NULL,
                                        keys = get_cdisc_keys(dataname),
                                        parent = `if`(identical(dataname, "ADSL"), character(0L), "ADSL"),
                                        label = character(0),
                                        code = character(0),
                                        script = character(0),
                                        func_name = substitute(fun),
                                        metadata = NULL,
                                        ...) {
  x <- fun_dataset_connector(
    dataname = dataname,
    fun = fun,
    fun_args = fun_args,
    func_name = func_name,
    keys = keys,
    label = label,
    code = code,
    script = script,
    metadata = metadata,
    ...
  )

  res <- as_cdisc(
    x,
    parent = parent
  )

  return(res)
}


# PYTHON ====
#' `Python` `TealDatasetConnector`
#'
#' `r lifecycle::badge("experimental")`
#' Create a `TealDatasetConnector` from `.py` file or through python code supplied directly.
#'
#' @details
#'   Note that in addition to the `reticulate` package, support for python requires an
#'   existing python installation. By default, `reticulate` will attempt to use the
#'   location `Sys.which("python")`, however the path to the python installation can be
#'   supplied directly via `reticulate::use_python`.
#'
#'   The `teal` API for delayed data requires the python code or script to return a
#'   data.frame object. For this, the `pandas` package is required. This can be installed
#'   using `reticulate::py_install("pandas")`.
#'
#'   Please see the package documentation for more details.
#'
#' @inheritParams dataset_connector
#' @inheritParams code_dataset_connector
#' @param file (`character`)\cr
#'   Path to the file location containing the python script used to generate the object.
#' @param code (`character`)\cr
#'   string containing the python code to be run using `reticulate`. Carefully consider
#'   indentation to follow proper python syntax.
#' @param object (`character`)\cr
#'   name of the object from the python script that is assigned to the dataset to be used.
#'
#' @note
#'   Raises an error when passed `code` and `file` are passed at the same time.
#'
#'   When using `code`, keep in mind that when using `reticulate` with delayed data, python
#'   functions do not have access to other objects in the `code` and must be self contained.
#'   In the following example, the function `makedata()` doesn't have access to variable `x`:
#'
#' \preformatted{import pandas as pd
#'
#' x = 1
#' def makedata():
#'   return pd.DataFrame({'x': [x, 2], 'y': [3, 4]})
#'
#' data = makedata()}
#'
#'   When using custom functions, the function environment must be entirely self contained:
#'
#' \preformatted{def makedata():
#'   import pandas as pd
#'   x = 1
#'   return pd.DataFrame({'x': [x, 2], 'y': [3, 4]})
#'
#' data = makedata()
#'   }
#'
#'   **Additional `reticulate` considerations:**
#'   1. Note that when using pull `vars`, `R` objects  referenced in the python
#'   code or script have to be prefixed with `r.`.
#'   2. `reticulate` isn't able to convert `POSIXct` objects. Please take extra
#'   care when working with `datetime` variables.
#'
#'   Please read the official documentation for the `reticulate` package for additional
#'   features and current limitations.
#'
#' @export
#'
#' @rdname python_dataset_connector
#'
#' @examples
#' \dontrun{
#' library(reticulate)
#'
#' # supply python code directly in R
#'
#' x <- python_dataset_connector(
#'   "ADSL",
#'   code = "import pandas as pd
#' data = pd.DataFrame({'STUDYID':  [1, 2], 'USUBJID': [3, 4]})",
#'   object = "data"
#' )
#'
#' x$pull()
#' x$get_raw_data()
#'
#' # supply an external python script
#'
#' python_file <- tempfile(fileext = ".py")
#' writeLines(
#'   text = "import pandas as pd
#' data = pd.DataFrame({'STUDYID':  [1, 2], 'USUBJID': [3, 4]})",
#'   con = python_file
#' )
#'
#' x <- python_dataset_connector(
#'   "ADSL",
#'   file = python_file,
#'   object = "data",
#' )
#'
#' x$pull()
#' x$get_raw_data()
#'
#' # supply pull `vars` from R
#'
#' y <- 8
#' x <- python_dataset_connector(
#'   "ADSL",
#'   code = "import pandas as pd
#' data = pd.DataFrame({'STUDYID':  [r.y], 'USUBJID': [r.y]})",
#'   object = "data",
#'   vars = list(y = y)
#' )
#'
#' x$pull()
#' x$get_raw_data()
#' }
python_dataset_connector <- function(dataname,
                                     file,
                                     code,
                                     object = dataname,
                                     keys = character(0),
                                     label = character(0),
                                     mutate_code = character(0),
                                     mutate_script = character(0),
                                     vars = list(),
                                     metadata = NULL) {
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    stop("Cannot load package 'reticulate' - please install the package.", call. = FALSE)
  }
  if (utils::packageVersion("reticulate") < 1.22) {
    stop("Please upgrade package 'reticulate', teal.data requires version >= 1.22")
  }

  checkmate::assert_string(object)
  if (!xor(missing(code), missing(file))) stop("Exactly one of 'code' and 'script' is required")

  if (!missing(file)) {
    checkmate::assert_string(file)
    checkmate::assert_file_exists(file, extension = "py")
    x_fun <- CallablePythonCode$new("py_run_file") # nolint
    x_fun$set_args(list(file = file, local = TRUE))
  } else {
    checkmate::assert_string(code)
    x_fun <- CallablePythonCode$new("py_run_string") # nolint
    x_fun$set_args(list(code = code, local = TRUE))
  }

  x_fun$set_object(object)

  x <- dataset_connector(
    dataname = dataname,
    pull_callable = x_fun,
    keys = keys,
    label = label,
    code = code_from_script(mutate_code, mutate_script),
    vars = vars,
    metadata = metadata
  )

  return(x)
}

#' `Python` `CDISCTealDatasetConnector`
#'
#' `r lifecycle::badge("experimental")`
#' Create a `CDISCTealDatasetConnector` from `.py` file or through python code supplied directly.
#'
#' @inheritParams python_dataset_connector
#' @inheritParams cdisc_dataset_connector
#'
#' @export
#'
#' @rdname python_dataset_connector
python_cdisc_dataset_connector <- function(dataname,
                                           file,
                                           code,
                                           object = dataname,
                                           keys = get_cdisc_keys(dataname),
                                           parent = `if`(identical(dataname, "ADSL"), character(0L), "ADSL"),
                                           mutate_code = character(0),
                                           mutate_script = character(0),
                                           label = character(0),
                                           vars = list(),
                                           metadata = NULL) {
  x <- python_dataset_connector(
    dataname = dataname,
    file = file,
    code = code,
    object = object,
    keys = keys,
    mutate_code = mutate_code,
    mutate_script = mutate_script,
    label = label,
    vars = vars,
    metadata = metadata
  )

  res <- as_cdisc(
    x,
    parent = parent
  )

  return(res)
}

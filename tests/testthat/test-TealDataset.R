## TealDataset =====
testthat::test_that("TealDataset basics", {
  x <- data.frame(x = c(1, 2), y = c("a", "b"), stringsAsFactors = TRUE)
  col_labels(x) <- c("X", "Y")

  testthat::expect_silent({
    test_ds <- TealDataset$new(
      dataname = "testds",
      x = x,
      keys = "x",
      metadata = list(A = "A", B = "B")
    )
  })

  testthat::expect_equal(
    get_keys(test_ds),
    "x"
  )

  testthat::expect_silent(set_keys(test_ds, "y"))
  testthat::expect_equal(
    get_keys(test_ds),
    "y"
  )

  testthat::expect_equal(test_ds$get_metadata(), list(A = "A", B = "B"))

  df <- as.data.frame(
    list(a = c("a", "a", "b", "b", "c"), b = c(1, 2, 3, 3, 4), c = c(1, 2, 3, 4, 5))
  )
  # keys checking is not immediate
  ds1 <- dataset(dataname = "df", x = df, keys = character(0))
  testthat::expect_silent(ds1$check_keys())

  ds2 <- dataset(dataname = "df", x = df, keys = character(0)) %>% set_keys(c("c"))
  testthat::expect_silent(ds2$check_keys())

  ds3 <- dataset(dataname = "df", x = df) %>% set_keys("non_existing_col")
  testthat::expect_error(
    ds3$check_keys(),
    "Primary keys specifed for df do not exist in the data."
  )

  ds4 <- dataset(dataname = "df", x = df) %>% set_keys("a")
  testthat::expect_error(
    ds4$check_keys(),
    "Duplicate primary key values found in the dataset 'df'"
  )
})

testthat::test_that("metadata not a list throws an error", {
  testthat::expect_error(
    dataset("x", data.frame(x = c(1, 2)), metadata = 2),
    "Must be of type 'list'"
  )
})

testthat::test_that("metadata not a list of length one atomics throws an error", {
  testthat::expect_error(
    dataset("x", data.frame(x = c(1, 2)), metadata = list(x = list())),
    "Must be of type 'atomic', not 'list'"
  )
  testthat::expect_error(
    dataset("x", data.frame(x = c(1, 2)), metadata = list(x = 1:10)),
    "Must have length 1"
  )
})

testthat::test_that("metadata can be NULL (the default)", {
  testthat::expect_error(
    ds <- dataset("x", data.frame(x = c(1, 2)), metadata = NULL),
    NA
  )
  testthat::expect_equal(ds, dataset("x", data.frame(x = c(1, 2))))
})


testthat::test_that("TealDataset$recreate", {
  ds <- TealDataset$new(
    dataname = "mtcars",
    x = mtcars,
    keys = character(0),
    code = "mtcars",
    label = character(0),
    vars = list(),
    metadata = list(A = "A", B = "B")
  )
  ds2 <- ds$recreate()

  testthat::expect_identical(ds, ds2)
})

testthat::test_that("TealDataset$get_*_colnames", {
  df <- as.data.frame(
    list(
      num = c(1, 2, 3),
      char = as.character(c("a", "b", "c")),
      fac = factor(x = c("lev1", "lev2", "lev1"), levels = c("lev1", "lev2"))
    ),
    stringsAsFactors = FALSE
  )
  ds <- TealDataset$new("ds", x = df)

  testthat::expect_equal(ds$get_numeric_colnames(), c("num"))
  testthat::expect_equal(ds$get_character_colnames(), c("char"))
  testthat::expect_equal(ds$get_factor_colnames(), c("fac"))
})

testthat::test_that("TealDataset$get_rownames", {
  df <- as.data.frame(
    list(
      num = c(1, 2, 3),
      char = as.character(c("a", "b", "c")),
      fac = factor(x = c("lev1", "lev2", "lev1"), levels = c("lev1", "lev2"))
    ),
    stringsAsFactors = FALSE
  )
  ds <- TealDataset$new("ds", x = df)

  testthat::expect_equal(ds$get_rownames(), c("1", "2", "3"))
})

testthat::test_that("TealDataset active bindings and getters", {
  df <- as.data.frame(
    list(
      num = c(1, 2, 3),
      char = as.character(c("a", "b", "c")),
      fac = factor(x = c("lev1", "lev2", "lev1"), levels = c("lev1", "lev2")),
      num2 = c(3, 4, 5)
    ),
    stringsAsFactors = FALSE
  )
  ds <- TealDataset$new("ds", x = df)

  testthat::expect_equal(ds$get_ncol(), 4)
  testthat::expect_equal(ds$get_nrow(), 3)
  testthat::expect_equal(ds$get_colnames(), c("num", "char", "fac", "num2"))
  testthat::expect_equal(ds$get_rownames(), c("1", "2", "3"))
  testthat::expect_equal(
    ds$raw_data,
    as.data.frame(
      list(
        num = c(1, 2, 3),
        char = as.character(c("a", "b", "c")),
        fac = factor(x = c("lev1", "lev2", "lev1"), levels = c("lev1", "lev2")),
        num2 = c(3, 4, 5)
      ),
      stringsAsFactors = FALSE
    )
  )
  testthat::expect_equal(ds$var_names, ds$get_colnames())
  testthat::expect_true(is.null(ds$get_row_labels()))

  # Depreciation warnings
  labs <- ds$get_column_labels()
  exp <- as.character(rep(NA, 4))
  names(exp) <- c("num", "char", "fac", "num2")
  testthat::expect_equal(labs, exp)
})

testthat::test_that("TealDataset supplementary constructors", {
  file_example <- tempfile(fileext = ".R")
  writeLines(
    text = c(
      "library(teal.data)

      # code>
      x <- iris
      x$a1 <- 1
      x$a2 <- 2

      # <code
      dataset(dataname = \"iris_mod\", x = x)"
    ),
    con = file_example
  )
  testthat::expect_silent(x <- dataset_file(file_example))

  # Not a TealDataset object causes an error
  file_example2 <- tempfile(fileext = "2.R")
  writeLines(
    text = c(
      "iris"
    ),
    con = file_example2
  )
  testthat::expect_error(
    x <- dataset_file(file_example2),
    regexp = "The object returned from the file is not of TealDataset class.",
    fixed = TRUE
  )
})

testthat::test_that("TealDataset$set_vars throws an error if passed the enclosing TealDataset object directly", {
  test_ds <- TealDataset$new("mtcars", mtcars)
  testthat::expect_error(test_ds$set_vars(vars = list(itself = test_ds)), regexp = "Circular dependencies detected")
})

testthat::test_that("TealDataset$set_vars throws an error if passed the enclosing TealDataset object indirectly, distance 1", { # nolint
  test_ds0 <- TealDataset$new("mtcars", mtcars)
  test_ds1 <- TealDataset$new("iris", iris)
  test_ds1$set_vars(vars = list(test_ds0 = test_ds0))
  testthat::expect_error(test_ds0$set_vars(vars = list(test_ds1 = test_ds1)), regexp = "Circular dependencies detected")
})

testthat::test_that("TealDataset$set_vars throws an error if passed the enclosing TealDataset object indirectly, distance 2", { # nolint
  test_ds0 <- TealDataset$new("mtcars", mtcars)
  test_ds1 <- TealDataset$new("iris", iris)
  test_ds2 <- TealDataset$new("rock", rock)
  test_ds1$set_vars(vars = list(test_ds0 = test_ds0))
  test_ds2$set_vars(vars = list(test_ds1 = test_ds1))

  testthat::expect_error(
    test_ds0$set_vars(vars = list(test_ds2 = test_ds2)),
    regexp = "Circular dependencies detected"
  )
})

testthat::test_that("TealDataset$set_vars throws an error if passed the enclosing TealDatasetConnector", {
  test_ds0 <- TealDataset$new("mtcars", mtcars)
  test_ds1 <- TealDataset$new("iris", iris)
  test_ds2 <- TealDataset$new("rock", rock)
  test_ds1$set_vars(vars = list(test_ds0 = test_ds0))
  test_ds2$set_vars(vars = list(test_ds1 = test_ds1))

  testthat::expect_error(
    mutate_dataset(
      test_ds0,
      code = "mtcars$new_var <- rock$perm[1]", vars = list(test_ds2 = test_ds2)
    ),
    regexp = "Circular dependencies detected"
  )

  pull_fun2 <- callable_function(data.frame)
  pull_fun2$set_args(args = list(a = c(1, 2, 3)))
  t_dc <- dataset_connector("test", pull_fun2, vars = list(test_ds0 = test_ds0))
  testthat::expect_error(test_ds0$set_vars(vars = list(t_dc = t_dc)), regexp = "Circular dependencies detected")
  mutate_dataset(t_dc, code = "test$new_var <- iris$Species[1]", vars = list(test_ds1 = test_ds1))
  testthat::expect_error(
    mutate_dataset(test_ds0, code = "mtcars$new_var <- t_dc$a[1]", vars = list(t_dc = t_dc)),
    regexp = "Circular dependencies detected"
  )
})

testthat::test_that("TealDataset mutate method with delayed logic", {
  test_ds0 <- TealDataset$new("head_mtcars", head(mtcars), code = "head_mtcars <- head(mtcars)")
  test_ds1 <- TealDataset$new("head_iris", head(iris), code = "head_iris <- head(iris)")
  test_ds2 <- TealDataset$new("head_rock", head(rock), code = "head_rock <- head(rock)")

  pull_fun2 <- callable_function(data.frame)
  pull_fun2$set_args(args = list(head_letters = head(letters)))
  t_dc <- dataset_connector("test_dc", pull_fun2, vars = list(test_ds1 = test_ds1))

  testthat::expect_false(test_ds0$is_mutate_delayed())
  testthat::expect_equal(test_ds0$get_code(), "head_mtcars <- head(mtcars)")

  mutate_dataset(test_ds0, code = "head_mtcars$carb <- head_mtcars$carb * 2")
  testthat::expect_equal(test_ds0$get_raw_data()$carb, 2 * head(mtcars)$carb)
  testthat::expect_false(test_ds0$is_mutate_delayed())
  testthat::expect_equal(test_ds0$get_code(), "head_mtcars <- head(mtcars)\nhead_mtcars$carb <- head_mtcars$carb * 2")

  mutate_dataset(test_ds0, code = "head_mtcars$Species <- ds1$Species", vars = list(ds1 = test_ds1))
  testthat::expect_false(test_ds0$is_mutate_delayed())
  testthat::expect_equal(test_ds0$get_raw_data()$Species, test_ds1$get_raw_data()$Species)
  testthat::expect_equal(
    pretty_code_string(test_ds0$get_code()),
    c(
      "head_iris <- head(iris)",
      "ds1 <- head_iris",
      "head_mtcars <- head(mtcars)",
      "head_mtcars$carb <- head_mtcars$carb * 2",
      "head_mtcars$Species <- ds1$Species"
    )
  )

  mutate_dataset(test_ds0, code = "head_mtcars$head_letters <- dc$head_letters", vars = list(dc = t_dc))

  testthat::expect_equal(
    pretty_code_string(test_ds0$get_code()),
    c(
      "head_iris <- head(iris)",
      "ds1 <- head_iris",
      "test_ds1 <- head_iris",
      "test_dc <- data.frame(head_letters = c(\"a\", \"b\", \"c\", \"d\", \"e\", \"f\"))",
      "dc <- test_dc",
      "head_mtcars <- head(mtcars)",
      "head_mtcars$carb <- head_mtcars$carb * 2",
      "head_mtcars$Species <- ds1$Species",
      "head_mtcars$head_letters <- dc$head_letters"
    )
  )


  testthat::expect_null(test_ds0$get_raw_data()$head_mtcars)

  testthat::expect_true(test_ds0$is_mutate_delayed())
  testthat::expect_equal(
    pretty_code_string(test_ds0$get_code()),
    c(
      "head_iris <- head(iris)",
      "ds1 <- head_iris",
      "test_ds1 <- head_iris",
      "test_dc <- data.frame(head_letters = c(\"a\", \"b\", \"c\", \"d\", \"e\", \"f\"))",
      "dc <- test_dc",
      "head_mtcars <- head(mtcars)",
      "head_mtcars$carb <- head_mtcars$carb * 2",
      "head_mtcars$Species <- ds1$Species",
      "head_mtcars$head_letters <- dc$head_letters"
    )
  )

  # continuing to delay
  mutate_dataset(test_ds0, code = "head_mtcars$new_var <- 1")
  testthat::expect_true(test_ds0$is_mutate_delayed())

  testthat::expect_equal(
    pretty_code_string(test_ds0$get_code()),
    c(
      "head_iris <- head(iris)",
      "ds1 <- head_iris",
      "test_ds1 <- head_iris",
      "test_dc <- data.frame(head_letters = c(\"a\", \"b\", \"c\", \"d\", \"e\", \"f\"))",
      "dc <- test_dc",
      "head_mtcars <- head(mtcars)",
      "head_mtcars$carb <- head_mtcars$carb * 2",
      "head_mtcars$Species <- ds1$Species",
      "head_mtcars$head_letters <- dc$head_letters",
      "head_mtcars$new_var <- 1"
    )
  )
  expect_null(test_ds0$get_raw_data()$new_var)
  testthat::expect_true(test_ds0$is_mutate_delayed())

  mutate_dataset(test_ds0, code = "head_mtcars$perm <- ds2$perm", vars = list(ds2 = test_ds2))
  testthat::expect_equal(
    pretty_code_string(test_ds0$get_code()),
    c(
      "head_iris <- head(iris)",
      "ds1 <- head_iris",
      "test_ds1 <- head_iris",
      "test_dc <- data.frame(head_letters = c(\"a\", \"b\", \"c\", \"d\", \"e\", \"f\"))",
      "dc <- test_dc",
      "head_rock <- head(rock)",
      "ds2 <- head_rock",
      "head_mtcars <- head(mtcars)",
      "head_mtcars$carb <- head_mtcars$carb * 2",
      "head_mtcars$Species <- ds1$Species",
      "head_mtcars$head_letters <- dc$head_letters",
      "head_mtcars$new_var <- 1",
      "head_mtcars$perm <- ds2$perm"
    )
  )

  expect_null(test_ds0$get_raw_data()$perm)
  testthat::expect_equal(
    pretty_code_string(test_ds0$get_code()),
    c(
      "head_iris <- head(iris)",
      "ds1 <- head_iris",
      "test_ds1 <- head_iris",
      "test_dc <- data.frame(head_letters = c(\"a\", \"b\", \"c\", \"d\", \"e\", \"f\"))",
      "dc <- test_dc",
      "head_rock <- head(rock)",
      "ds2 <- head_rock",
      "head_mtcars <- head(mtcars)",
      "head_mtcars$carb <- head_mtcars$carb * 2",
      "head_mtcars$Species <- ds1$Species",
      "head_mtcars$head_letters <- dc$head_letters",
      "head_mtcars$new_var <- 1",
      "head_mtcars$perm <- ds2$perm"
    )
  )
  testthat::expect_true(test_ds0$is_mutate_delayed())

  load_dataset(t_dc)
  testthat::expect_true(test_ds0$is_mutate_delayed())

  load_dataset(test_ds0)
  testthat::expect_silent(test_ds0$get_raw_data())
  testthat::expect_false(test_ds0$is_mutate_delayed())
  testthat::expect_true(all(c("head_letters", "new_var", "perm") %in% names(test_ds0$get_raw_data())))
  expect_code <- c(
    "head_iris <- head(iris)",
    "ds1 <- head_iris",
    "test_ds1 <- head_iris",
    "test_dc <- data.frame(head_letters = c(\"a\", \"b\", \"c\", \"d\", \"e\", \"f\"))",
    "dc <- test_dc",
    "head_rock <- head(rock)",
    "ds2 <- head_rock",
    "head_mtcars <- head(mtcars)",
    "head_mtcars$carb <- head_mtcars$carb * 2",
    "head_mtcars$Species <- ds1$Species",
    "head_mtcars$head_letters <- dc$head_letters",
    "head_mtcars$new_var <- 1",
    "head_mtcars$perm <- ds2$perm"
  )
  testthat::expect_equal(
    pretty_code_string(test_ds0$get_code()),
    expect_code
  )

  mutate_dataset(test_ds0, code = "head_mtcars$new_var2 <- 2")
  testthat::expect_equal(
    pretty_code_string(test_ds0$get_code()),
    c(expect_code, "head_mtcars$new_var2 <- 2")
  )
  testthat::expect_false(test_ds0$is_mutate_delayed())
  testthat::expect_equal(test_ds0$get_raw_data()$new_var2, rep(2, 6))
})

testthat::test_that("TealDataset check method", {
  test_ds0 <- TealDataset$new("head_mtcars", head(mtcars))
  testthat::expect_error(
    test_ds0$check(),
    regex = "Cannot check preprocessing code of 'head_mtcars' - code is empty."
  )
  test_ds1 <- TealDataset$new("head_mtcars", x = head(mtcars), code = "head_mtcars <- head(mtcars)")
  testthat::expect_true(
    test_ds1$check()
  )
  test_ds2 <- TealDataset$new("head_mtcars", x = head(mtcars), code = "head_mtcars <- mtcars[1:6, ]")
  testthat::expect_true(
    test_ds2$check()
  )
  mutate_dataset(test_ds0, code = "head_mtcars$one <- 1")
  testthat::expect_true(
    test_ds1$check()
  )
  mutate_dataset(test_ds0, code = "head_mtcars$one <- head_mtcars$one * 2")
  testthat::expect_true(
    test_ds1$check()
  )
  mutate_dataset(test_ds1, code = "head_mtcars$one <- 1")
  testthat::expect_true(
    test_ds1$check()
  )
  mutate_dataset(test_ds1, code = "head_mtcars$one <- head_mtcars$one * 2")
  testthat::expect_true(
    test_ds1$check()
  )
})

testthat::test_that("TealDataset$check returns FALSE if the passed code creates a binding with a different object", {
  test_ds0 <- TealDataset$new("cars", head(mtcars), code = "cars <- head(iris)")
  testthat::expect_false(test_ds0$check())
})

testthat::test_that("get_code_class returns the correct `CodeClass` object", {
  cc1 <- CodeClass$new(code = "iris <- head(iris)", dataname = "iris")
  cc2 <- CodeClass$new(code = "mtcars <- head(mtcars)", dataname = "mtcars", deps = "iris")
  ds1 <- TealDataset$new("iris", head(iris), code = "iris <- head(iris)")
  ds2 <- TealDataset$new("mtcars", head(mtcars), code = "mtcars <- head(mtcars)", vars = list(iris = ds1))
  testthat::expect_equal(ds1$get_code_class(), cc1)
  testthat::expect_equal(ds2$get_code_class(), cc1$append(cc2))
})

testthat::test_that("get_code_class returns the correct `CodeClass` after mutating with another TealDataset", {
  ds1 <- TealDataset$new("iris", head(iris), code = "iris <- head(iris)")
  ds2 <- TealDataset$new("mtcars", head(mtcars), code = "mtcars <- head(mtcars)")
  cc1 <- CodeClass$new(code = "mtcars <- head(mtcars)", dataname = "mtcars")
  cc2 <- CodeClass$new(code = "iris <- head(iris)", dataname = "iris")
  cc3 <- CodeClass$new(code = "iris$test <- 1", dataname = "iris")
  ds1$mutate(cc3, vars = list(mtcars = ds2))
  testthat::expect_equal(ds1$get_code_class(), cc1$append(cc2)$append(cc3))
})

testthat::test_that("TealDataset$recreate does not reset the mutation code", {
  cf <- CallableFunction$new(function() head(mtcars))
  dataset_connector1 <- TealDatasetConnector$new("mtcars", cf)
  dataset1 <- TealDataset$new("iris", head(iris))
  dataset1$mutate(code = "test", vars = list(test = dataset_connector1))
  code_before_recreating <- dataset1$get_code()
  dataset1$recreate()
  code_after_recreating <- dataset1$get_code()
  testthat::expect_equal(code_after_recreating, code_before_recreating)
})

testthat::test_that("TealDataset$recreate does not reset the variables needed for mutation", {
  cf <- CallableFunction$new(function() head(mtcars))
  dataset_connector1 <- TealDatasetConnector$new("mtcars", cf)
  dataset1 <- TealDataset$new("iris", head(iris))
  dataset1$mutate(code = "test", vars = list(test = dataset_connector1))
  mutate_vars_before_recreation <- dataset1$get_mutate_vars()
  dataset1$recreate()
  testthat::expect_identical(dataset1$get_mutate_vars(), mutate_vars_before_recreation)
})

testthat::test_that("TealDataset$is_mutate_delayed returns TRUE if the TealDataset's dependency is delayed", {
  cf <- CallableFunction$new(function() head(mtcars))
  dataset_connector1 <- TealDatasetConnector$new("mtcars", cf)
  dataset1 <- TealDataset$new("iris", head(iris))
  dataset1$mutate(code = "", vars = list(test = dataset_connector1))
  testthat::expect_true(dataset1$is_mutate_delayed())
})

testthat::test_that("TealDataset$is_mutate_delayed stays FALSE if the TealDataset's
  dependency turns from not delayed to delayed", {
  cf <- CallableFunction$new(function() head(mtcars))
  dataset_connector1 <- TealDatasetConnector$new("mtcars", cf)
  dataset1 <- TealDataset$new("iris", head(iris))
  dataset_dependency <- TealDataset$new("plantgrowth", head(PlantGrowth))

  dataset1$mutate(code = "", vars = list(test = dataset_dependency))
  testthat::expect_false(dataset1$is_mutate_delayed())

  dataset_dependency$mutate(code = "", vars = list(test = dataset_connector1))
  testthat::expect_true(dataset_dependency$is_mutate_delayed())
  testthat::expect_false(dataset1$is_mutate_delayed())
})

testthat::test_that("Dupliated mutation code is shown via get_code()", {
  dataset <- TealDataset$new("iris", head(iris))
  dataset$mutate("7")
  dataset$mutate("7")
  testthat::expect_equal(dataset$get_code(), paste("7", "7", sep = "\n"))
})

test_that("mutate_dataset", {
  x <- data.frame(x = c(1, 2), y = c("a", "b"), stringsAsFactors = FALSE)

  expect_silent({
    test_ds <- dataset(
      dataname = "x",
      x = x,
      code = "data.frame(x = c(1, 2), y = c('a', 'b'), stringsAsFactors = FALSE)"
    )
  })

  expect_error(mutate_dataset(x = test_ds), "Assertion failed.+code")

  expect_error(mutate_dataset(x = test_ds, code = TRUE), "Assertion failed.+code")

  expect_error(
    object = {
      mutate_dataset(x = test_ds, code = "y <- test")
    },
    "Evaluation of the code failed"
  )

  # error because the code, "y <- test", was added even though it yielded an error.
  expect_error({
    test_ds_mut <- test_ds %>% mutate_dataset("x$z <- c('one', 'two')")
  })

  expect_equal(
    test_ds$get_raw_data(),
    data.frame(x = c(1, 2), y = c("a", "b"), stringsAsFactors = FALSE)
  )

  expect_equal(
    test_ds$get_raw_data(),
    data.frame(x = c(1, 2), y = c("a", "b"), stringsAsFactors = FALSE)
  )

  expect_error(
    object = {
      test_ds %>% mutate_dataset("x <- 3")
    },
    "object 'test' not found"
  )

  expect_error(
    object = {
      test_ds %>% mutate_dataset(c("x <- 3", "som"))
    },
    "Assertion failed.+code"
  )

  expect_silent({
    test_ds <- dataset(
      dataname = "x",
      x = x,
      keys = "x"
    )
  })
  expect_error({
    test_ds_mut <- test_ds %>% mutate_dataset("testds$z <- c('one', 'two')")
  })

  expect_silent({
    test_ds <- dataset(
      dataname = "testds",
      x = x,
      code = "testds <- whatever",
      keys = "x"
    )
  })

  expect_silent({
    test_ds_mut <- mutate_dataset(test_ds, code = "testds$z <- c('one', 'two')")
  })

  expect_equal(
    test_ds_mut$get_raw_data(),
    data.frame(
      x = c(1, 2), y = c("a", "b"),
      z = c("one", "two"),
      stringsAsFactors = FALSE
    )
  )

  expect_silent({
    test_ds_mut <- test_ds %>% mutate_dataset(read_script("mutate_code/testds.R"))
  })

  expect_equal(
    test_ds_mut$get_raw_data(),
    data.frame(
      x = c(1, 2), y = c("a", "b"),
      z = c(1, 1),
      stringsAsFactors = FALSE
    )
  )

  expect_equal(
    test_ds_mut$get_code(),
    "testds <- whatever\ntestds$z <- c(\"one\", \"two\")\nmut_fun <- function(x) {\n    x$z <- 1\n    return(x)\n}\ntestds <- mut_fun(testds)" # nolint
  )

  expect_true(inherits(test_ds_mut, "TealDataset"))

  expect_silent({
    test_ds_mut <- test_ds %>% mutate_dataset(read_script("mutate_code/testds.R"))
  })

  expect_equal(
    test_ds_mut$get_raw_data(),
    data.frame(
      x = c(1, 2), y = c("a", "b"),
      z = c(1, 1),
      stringsAsFactors = FALSE
    )
  )

  expect_equal(
    test_ds_mut$get_code(),
    "testds <- whatever\ntestds$z <- c(\"one\", \"two\")\nmut_fun <- function(x) {\n    x$z <- 1\n    return(x)\n}\ntestds <- mut_fun(testds)\nmut_fun <- function(x) {\n    x$z <- 1\n    return(x)\n}\ntestds <- mut_fun(testds)" # nolint
  )

  expect_true(inherits(test_ds_mut, "TealDataset"))

  expect_error(
    object = {
      test_ds_mut <- test_ds %>% mutate_dataset(code = "rm('testds')")
    },
    "Code from testds need to return a data.frame"
  )
})

test_that("mutate_dataset with vars argument", {
  x <- data.frame(x = c(1, 2), y = c("a", "b"), stringsAsFactors = FALSE)
  var1 <- "3"
  var2 <- "4"
  test_ds <- dataset(
    dataname = "x",
    x = x,
    code = "data.frame(x = c(1, 2), y = c('a', 'b'), stringsAsFactors = TRUE)"
  )
  expect_silent(
    mutate_dataset(x = test_ds, code = "x$z <- var", vars = list(var = var1))
  )
  expect_silent(
    mutate_dataset(x = test_ds, code = "x$z <- var2", vars = list(var2 = paste(var1, var2)))
  )
  expect_error(
    mutate_dataset(x = test_ds, code = "x$z <- var", vars = list(var = var2))
  )
  expect_silent(
    mutate_dataset(x = test_ds, code = "x$zz <- var", vars = list(var = var1))
  )

  pull_fun2 <- callable_function(data.frame)
  pull_fun2$set_args(args = list(a = c(1, 2, 3)))
  expect_silent({
    t <- dataset_connector("test", pull_fun2)
  })
  expect_silent(load_dataset(t))
  expect_silent(
    mutate_dataset(x = t, code = "test$z <- var", vars = list(var = var1))
  )
  expect_silent(
    mutate_dataset(x = t, code = "test$z <- var2", vars = list(var2 = paste(var1, var2)))
  )
  expect_error(
    mutate_dataset(x = t, code = "test$z <- var", vars = list(var = var2))
  )
  expect_silent(
    mutate_dataset(x = t, code = "test$zz <- var", vars = list(var = var1))
  )
})

testthat::test_that("dataset$print warns of superfluous arguments", {
  x <- data.frame(x = c(1, 2), y = c("a", "b"), stringsAsFactors = FALSE)
  test_ds <- dataset(
    dataname = "x",
    x = x,
    code = "data.frame(x = c(1, 2), y = c('a', 'b'), stringsAsFactors = FALSE)"
  )
  testthat::expect_warning(
    capture.output(print(test_ds, "un used argument"))
  )
})

testthat::test_that("dataset$print prints out all rows when less than 6", {
  x <- data.frame(x = c(1, 2), y = c("a", "b"), stringsAsFactors = FALSE)
  test_ds <- dataset(
    dataname = "x",
    x = x,
    code = "data.frame(x = c(1, 2), y = c('a', 'b'), stringsAsFactors = FALSE)"
  )

  testthat::expect_equal(
    capture.output(print(test_ds)),
    c(
      "A TealDataset object containing the following data.frame (2 rows and 2 columns):",
      "  x y",
      "1 1 a",
      "2 2 b"
    )
  )
})

testthat::test_that("dataset$print truncates output after 6 rows", {
  x <- head(iris, 7)
  test_ds <- dataset(
    dataname = "x",
    x = x,
    code = "head(iris, 7)"
  )

  testthat::expect_equal(
    capture.output(print(test_ds)),
    c(
      "A TealDataset object containing the following data.frame (7 rows and 5 columns):",
      "  Sepal.Length Sepal.Width Petal.Length Petal.Width Species",
      "1          5.1         3.5          1.4         0.2  setosa",
      "2          4.9         3.0          1.4         0.2  setosa",
      "3          4.7         3.2          1.3         0.2  setosa",
      "4          4.6         3.1          1.5         0.2  setosa",
      "5          5.0         3.6          1.4         0.2  setosa",
      "6          5.4         3.9          1.7         0.4  setosa",
      "..."
    )
  )
})

testthat::test_that("get_var_r6 returns identical R6 objects as passed with set_vars", {
  test_ds0 <- TealDataset$new("mtcars", mtcars)
  test_ds1 <- TealDataset$new("iris", iris)
  test_ds1$set_vars(vars = list(test_ds0 = test_ds0))

  vars <- test_ds1$get_var_r6()
  testthat::expect_identical(vars$test_ds0, test_ds0)
})

testthat::test_that("clone(deep = TRUE) deep clones dependencies, which are TealDataset objects", {
  test_ds0 <- TealDataset$new("mtcars", mtcars)
  test_ds1 <- TealDataset$new("iris", iris)
  test_ds1$set_vars(vars = list(test_ds0 = test_ds0))
  test_ds1_cloned <- test_ds1$clone(deep = TRUE)
  testthat::expect_false(
    identical(test_ds1_cloned$get_var_r6()$test_ds0, test_ds0)
  )
})

testthat::test_that("reassign_datasets_vars updates the references of the vars to
                    addresses of passed objects", {
  test_ds0 <- TealDataset$new("mtcars", mtcars)
  test_ds1 <- TealDataset$new("iris", iris)
  test_ds1$set_vars(vars = list(test_ds0 = test_ds0))

  # after reassignment vars_r6, vars and muatate_vars match new reference
  test_ds0_cloned <- test_ds0$clone(deep = TRUE)
  test_ds1$reassign_datasets_vars(list(test_ds0 = test_ds0_cloned))

  vars <- test_ds1$get_vars()
  testthat::expect_identical(vars$test_ds0, test_ds0_cloned)
})

testthat::test_that("reassign_datasets_vars updates the references of the vars_r6 to
                    addresses of passed objects", {
  test_ds0 <- TealDataset$new("mtcars", mtcars)
  test_ds1 <- TealDataset$new("iris", iris)
  test_ds1$set_vars(vars = list(test_ds0 = test_ds0))

  # after reassignment vars_r6, vars and muatate_vars match new reference
  test_ds0_cloned <- test_ds0$clone(deep = TRUE)
  test_ds1$reassign_datasets_vars(list(test_ds0 = test_ds0_cloned))

  vars_r6 <- test_ds1$get_var_r6()
  testthat::expect_identical(vars_r6$test_ds0, test_ds0_cloned)
})

testthat::test_that("reassign_datasets_vars does not change `vars` elements of
                    class different than TealDataset and TealDatasetConnector", {
  test_ds0 <- mtcars
  test_ds1 <- TealDataset$new("mtcars", mtcars)
  test_ds2 <- TealDataset$new("iris", iris)
  test_ds2$set_vars(vars = list(test_ds0 = test_ds0, test_ds1 = test_ds1))

  test_ds2$reassign_datasets_vars(list(test_ds1 = test_ds1))
  testthat::expect_identical(test_ds2$get_vars()$test_ds0, test_ds0)
})

testthat::test_that("reassign_datasets_vars does not change any `vars` while
                    empty list is provided", {
  test_ds0 <- mtcars
  test_ds1 <- TealDataset$new("mtcars", mtcars)
  test_ds2 <- TealDataset$new("iris", iris)
  test_ds2$set_vars(vars = list(test_ds0 = test_ds0, test_ds1 = test_ds1))

  test_ds2$reassign_datasets_vars(list())
  testthat::expect_identical(test_ds2$get_vars()$test_ds0, test_ds0)
  testthat::expect_identical(test_ds2$get_vars()$test_ds1, test_ds1)
})

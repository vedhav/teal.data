% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mutate_dataset.R
\name{mutate_dataset}
\alias{mutate_dataset}
\alias{mutate_dataset.TealDataset}
\alias{mutate_dataset.TealDatasetConnector}
\alias{mutate_dataset.TealDataAbstract}
\title{Mutate dataset by code}
\usage{
mutate_dataset(x, ...)

\method{mutate_dataset}{TealDataset}(
  x,
  code = character(0),
  script = character(0),
  vars = list(),
  ...
)

\method{mutate_dataset}{TealDatasetConnector}(
  x,
  code = character(0),
  script = character(0),
  vars = list(),
  ...
)

\method{mutate_dataset}{TealDataAbstract}(
  x,
  dataname,
  code = character(0),
  script = character(0),
  vars = list(),
  ...
)
}
\arguments{
\item{x}{(\code{TealDataset})\cr
object.}

\item{...}{not used, only for support of S3}

\item{code}{(\code{character})\cr
Code to mutate the dataset. Must contain the \code{dataset$dataname}. Or can also be an object
of class \code{PythonCodeClass} returned by \code{\link{python_code}}.}

\item{script}{(\code{character})\cr
file that contains R Code that can be read using \code{\link{read_script}}.
Preferred before \code{code} argument.}

\item{vars}{(named \code{list})) \cr
In case when this object code depends on other \code{TealDataset} object(s) or
other constant value, this/these object(s) should be included as named
element(s) of the list. For example if this object code needs \code{ADSL}
object we should specify \verb{vars = list(ADSL = <adsl object>)}.
It's recommended to include \code{TealDataset} or \code{TealDatasetConnector} objects to
the \code{vars} list to preserve reproducibility. Please note that \code{vars}
are included to this object as local \code{vars} and they cannot be modified
within another dataset.}

\item{dataname}{(\code{character})\cr
\code{Dataname} to be mutated.}
}
\value{
modified \code{x} object
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
}
\examples{
library(magrittr)

ADSL <- teal.data::example_cdisc_data("ADSL")

ADSL_dataset <- dataset(
  dataname = "ADSL",
  x = ADSL,
  label = "AdAM subject-level dataset",
  code = "ADSL <- teal.data::example_cdisc_data(\"ADSL\")"
)
ADSL_mutated <- ADSL_dataset \%>\%
  mutate_dataset(code = "ADSL$new_variable <- 1")

ADSL_mutated$get_raw_data()$new_variable[1]

# Use an R script to mutate the data
file_example <- tempfile(fileext = ".R")
writeLines(
  text = c(
    "ADSL <- ADSL \%>\%
      dplyr::mutate(new_variable = new_variable * 2)"
  ),
  con = file_example
)

ADSL_mutated <- ADSL_mutated \%>\%
  mutate_dataset(script = file_example)

ADSL_mutated$get_raw_data()$new_variable[1]

ADSL_mutated <- ADSL_mutated \%>\%
  mutate_dataset(code = read_script(file_example))

ADSL_mutated$get_raw_data()$new_variable[1]
}

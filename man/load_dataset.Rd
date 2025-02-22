% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_dataset.R
\name{load_dataset}
\alias{load_dataset}
\alias{load_dataset.TealDataset}
\alias{load_dataset.TealDatasetConnector}
\title{Load data from connection}
\usage{
load_dataset(x, ...)

\method{load_dataset}{TealDataset}(x, ...)

\method{load_dataset}{TealDatasetConnector}(x, args = NULL, try = FALSE, conn = NULL, ...)
}
\arguments{
\item{x}{(\code{TealDatasetConnector} or \code{TealDataset})}

\item{...}{not used, only for support of S3}

\item{args}{(\code{NULL} or named \code{list})\cr
additional dynamic arguments passed to function which loads the data.}

\item{try}{(\code{logical}) whether perform function evaluation inside \code{try} clause}

\item{conn}{Optional (\code{TealDataConnection}) object required to pull the data.}
}
\value{
\code{x} with loaded \code{dataset} object
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}
Load data from connection. Function used on \code{\link{TealDatasetConnector}} and
\code{\link{TealDataset}} to obtain data from connection.
}
\examples{

# TealDataset --------
ADSL <- teal.data::example_cdisc_data("ADSL")
ADSL_dataset <- dataset("ADSL", x = ADSL)

load_dataset(ADSL_dataset)

# TealDatasetConnector --------

random_data_connector <- function(dataname) {
  fun_dataset_connector(
    dataname = dataname,
    fun = teal.data::example_cdisc_data,
    fun_args = list(dataname = dataname),
  )
}

adsl <- random_data_connector(dataname = "ADSL")
load_dataset(adsl)
get_dataset(adsl)

adae <- random_data_connector(dataname = "ADAE")
load_dataset(adae)
get_dataset(adae)
}

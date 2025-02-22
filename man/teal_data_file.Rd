% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/teal_data.R
\name{teal_data_file}
\alias{teal_data_file}
\title{Load \code{TealData} object from a file}
\usage{
teal_data_file(path, code = get_code(path))
}
\arguments{
\item{path}{A (\code{connection}) or a (\code{character})\cr
string giving the pathname of the file or URL to read from. "" indicates the connection \code{stdin}.}

\item{code}{(\code{character})\cr
reproducible code to re-create object}
}
\value{
\code{TealData} object
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
Please note that the script has to end with a call creating desired object. The error will be raised otherwise.
}
\examples{
# simple example
file_example <- tempfile(fileext = ".R")
writeLines(
  text = c(
    "library(teal.data)

     x1 <- dataset(dataname = \"IRIS\",
                   x = iris,
                   code = \"IRIS <- iris\")

     x2 <- dataset(dataname = \"MTCARS\",
                   x = mtcars,
                   code = \"MTCARS <- mtcars\")

     teal_data(x1, x2)"
  ),
  con = file_example
)
teal_data_file(file_example, code = character(0))
}

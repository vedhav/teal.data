% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_code.R
\name{get_code_single}
\alias{get_code_single}
\title{Get code}
\usage{
get_code_single(file_path, read_sources, if_url = grepl("^http[s]", file_path))
}
\arguments{
\item{file_path}{(\code{character}) path or URL address of the file to be parsed}

\item{read_sources}{(\code{logical}) whether to replace \code{source("path")} with code lines from sourced file.
If \code{read_sources = TRUE} changing working directory inside preprocessing is not allowed.}

\item{if_url}{(\code{logical}) (optional) TRUE when URL address is provided}
}
\value{
lines (\code{character}) of preprocessing code
}
\description{
Get code from specified file.
}
\keyword{internal}

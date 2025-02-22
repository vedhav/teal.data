% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CallableCode.R
\name{callable_code}
\alias{callable_code}
\title{Create \code{\link{CallableCode}} object}
\usage{
callable_code(code)
}
\arguments{
\item{code}{(\code{character})\cr
a string containing R code to reproduce the desired object. Please be aware
that objects assigned to temporary environment are locked which means
that they can't be modified.}
}
\value{
\code{CallableCode} object
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}

Create \link{CallableCode} object to execute specific code and get reproducible call.
}
\examples{
cf <- callable_code(code = "mtcars")
cf$run()
cf$get_call()
}

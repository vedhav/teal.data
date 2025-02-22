% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/formatters_var_labels.R
\name{col_labels}
\alias{col_labels}
\title{Get Label Attributes of Variables in a \code{data.frame}}
\source{
This function was taken 1-1 from
\href{https://cran.r-project.org/package=formatters}{formatters} package, to reduce the complexity of
the dependency tree.
}
\usage{
col_labels(x, fill = FALSE)
}
\arguments{
\item{x}{a \code{data.frame} object}

\item{fill}{boolean in case the \code{label} attribute does not exist if
\code{TRUE} the variable names is returned, otherwise \code{NA}}
}
\value{
a named character vector with the variable labels, the names
correspond to the variable names
}
\description{
Variable labels can be stored as a \code{label} attribute for each variable.
This functions returns a named character vector with the variable labels
(empty sting if not specified)
}
\examples{
x <- iris
col_labels(x)
col_labels(x) <- paste("label for", names(iris))
col_labels(x)
}
\seealso{
\code{\link[=col_relabel]{col_relabel()}} \code{\link{col_labels<-}}
}

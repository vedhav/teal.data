% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TealDataConnection.R
\name{data_connection}
\alias{data_connection}
\title{The constructor for \code{TealDataConnection} class.}
\usage{
data_connection(
  open_fun = NULL,
  close_fun = NULL,
  ping_fun = NULL,
  if_conn_obj = FALSE
)
}
\arguments{
\item{open_fun}{(\code{CallableFunction}) function to open connection}

\item{close_fun}{(\code{CallableFunction}) function to close connection}

\item{ping_fun}{(\code{CallableFunction}) function to ping connection}

\item{if_conn_obj}{optional, (\code{logical}) whether to store \code{conn} object returned from opening}
}
\value{
\code{TealDataConnection} object
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}
}
\examples{
open_fun <- callable_function(data.frame) # define opening function
open_fun$set_args(list(x = 1:5)) # define fixed arguments to opening function

close_fun <- callable_function(sum) # define closing function
close_fun$set_args(list(x = 1:5)) # define fixed arguments to closing function

ping_fun <- callable_function(function() TRUE)

x <- data_connection( # define connection
  ping_fun = ping_fun, # define ping function
  open_fun = open_fun, # define opening function
  close_fun = close_fun # define closing function
)

x$set_open_args(args = list(y = letters[1:5])) # define additional arguments if necessary

x$open() # call opening function
x$get_open_call() # check reproducible R code

# get data from connection via TealDataConnector$get_dataset()
\dontrun{
x$open(args = list(x = 1:5, y = letters[1:5])) # able to call opening function with arguments
x$close() # call closing function
}

}

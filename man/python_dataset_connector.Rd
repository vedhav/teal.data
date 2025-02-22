% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TealDatasetConnector_constructors.R
\name{python_dataset_connector}
\alias{python_dataset_connector}
\alias{python_cdisc_dataset_connector}
\title{\code{Python} \code{TealDatasetConnector}}
\usage{
python_dataset_connector(
  dataname,
  file,
  code,
  object = dataname,
  keys = character(0),
  label = character(0),
  mutate_code = character(0),
  mutate_script = character(0),
  vars = list(),
  metadata = NULL
)

python_cdisc_dataset_connector(
  dataname,
  file,
  code,
  object = dataname,
  keys = get_cdisc_keys(dataname),
  parent = if (identical(dataname, "ADSL")) character(0L) else "ADSL",
  mutate_code = character(0),
  mutate_script = character(0),
  label = character(0),
  vars = list(),
  metadata = NULL
)
}
\arguments{
\item{dataname}{(\code{character})\cr
A given name for the dataset it may not contain spaces}

\item{file}{(\code{character})\cr
Path to the file location containing the python script used to generate the object.}

\item{code}{(\code{character})\cr
string containing the python code to be run using \code{reticulate}. Carefully consider
indentation to follow proper python syntax.}

\item{object}{(\code{character})\cr
name of the object from the python script that is assigned to the dataset to be used.}

\item{keys}{optional, (\code{character})\cr
vector of dataset primary keys column names}

\item{label}{(\code{character})\cr
Label to describe the dataset.}

\item{mutate_code}{(\code{character})\cr
String containing the code used to mutate the object
after it is produced.}

\item{mutate_script}{(\code{character})\cr
Alternatively to \code{mutate_code} - location of the file containing modification code.
Can't be used simultaneously with \code{mutate_script}.}

\item{vars}{(named \code{list})) \cr
In case when this object code depends on other \code{TealDataset} object(s) or
other constant value, this/these object(s) should be included as named
element(s) of the list. For example if this object code needs \code{ADSL}
object we should specify \verb{vars = list(ADSL = <adsl object>)}.
It's recommended to include \code{TealDataset} or \code{TealDatasetConnector} objects to
the \code{vars} list to preserve reproducibility. Please note that \code{vars}
are included to this object as local \code{vars} and they cannot be modified
within another dataset.}

\item{metadata}{(named \code{list}, \code{NULL} or \code{CallableFunction}) \cr
Field containing either the metadata about the dataset (each element of the list
should be atomic and length one) or a \code{CallableFuntion} to pull the metadata
from a connection. This should return a \code{list} or an object which can be
converted to a list with \code{as.list}.}

\item{parent}{(\code{character}, optional) parent dataset name}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
Create a \code{TealDatasetConnector} from \code{.py} file or through python code supplied directly.

\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
Create a \code{CDISCTealDatasetConnector} from \code{.py} file or through python code supplied directly.
}
\details{
Note that in addition to the \code{reticulate} package, support for python requires an
existing python installation. By default, \code{reticulate} will attempt to use the
location \code{Sys.which("python")}, however the path to the python installation can be
supplied directly via \code{reticulate::use_python}.

The \code{teal} API for delayed data requires the python code or script to return a
data.frame object. For this, the \code{pandas} package is required. This can be installed
using \code{reticulate::py_install("pandas")}.

Please see the package documentation for more details.
}
\note{
Raises an error when passed \code{code} and \code{file} are passed at the same time.

When using \code{code}, keep in mind that when using \code{reticulate} with delayed data, python
functions do not have access to other objects in the \code{code} and must be self contained.
In the following example, the function \code{makedata()} doesn't have access to variable \code{x}:

\preformatted{import pandas as pd

x = 1
def makedata():
  return pd.DataFrame({'x': [x, 2], 'y': [3, 4]})

data = makedata()}

When using custom functions, the function environment must be entirely self contained:

\preformatted{def makedata():
  import pandas as pd
  x = 1
  return pd.DataFrame({'x': [x, 2], 'y': [3, 4]})

data = makedata()
  }

\strong{Additional \code{reticulate} considerations:}
\enumerate{
\item Note that when using pull \code{vars}, \code{R} objects  referenced in the python
code or script have to be prefixed with \code{r.}.
\item \code{reticulate} isn't able to convert \code{POSIXct} objects. Please take extra
care when working with \code{datetime} variables.
}

Please read the official documentation for the \code{reticulate} package for additional
features and current limitations.
}
\examples{
\dontrun{
library(reticulate)

# supply python code directly in R

x <- python_dataset_connector(
  "ADSL",
  code = "import pandas as pd
data = pd.DataFrame({'STUDYID':  [1, 2], 'USUBJID': [3, 4]})",
  object = "data"
)

x$pull()
x$get_raw_data()

# supply an external python script

python_file <- tempfile(fileext = ".py")
writeLines(
  text = "import pandas as pd
data = pd.DataFrame({'STUDYID':  [1, 2], 'USUBJID': [3, 4]})",
  con = python_file
)

x <- python_dataset_connector(
  "ADSL",
  file = python_file,
  object = "data",
)

x$pull()
x$get_raw_data()

# supply pull `vars` from R

y <- 8
x <- python_dataset_connector(
  "ADSL",
  code = "import pandas as pd
data = pd.DataFrame({'STUDYID':  [r.y], 'USUBJID': [r.y]})",
  object = "data",
  vars = list(y = y)
)

x$pull()
x$get_raw_data()
}
}

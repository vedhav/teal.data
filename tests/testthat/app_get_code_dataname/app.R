# code>
library(teal) # nocode
require(magrittr)
library(teal)
set.seed(1)
# <code

source("app_source1.R")
source("app_source2.R")

# code>
"# this is not a comment" # this is a comment
# "this is a comment"
# <code

x <- init(
  data = cdisc_data(
    ADSL = ADSL,
    ADTTE = ADTTE,
    code = get_code("app.R", exclude_comments = TRUE),
    check = TRUE
  ),
  modules = modules(
    tm_made_up_lm(
      label = "Regression",
      dataname = c("ADSL", "ADTTE"),
      response = list(adtte_extracted),
      regressor = list(
        adsl_extracted,
        adtte_extracted1
      )
    )
  )
)

shinyApp(x$ui, x$server)

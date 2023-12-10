#!/bin/Rscript

cran.packages <- c('devtools', 'renv', 'lintr', 'jsonlite', 'xml2', 'covr', 'DT', 'testthat')
install.opts <- c("--no-help", "--no-html", "--no-docs")

install.packages(
  cran.packages,
  repos = "http://cran.us.r-project.org/",
  dependencies = TRUE,
  type = "source",
  Ncpus = "4",
  clean = TRUE,
  INSTALL_opts = install.opts
)

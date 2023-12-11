#!/bin/Rscript

cran.packages <- c('devtools', 'renv', 'lintr', 'jsonlite')
install.opts <- c('--no-help', '--no-html', '--no-docs', '--no-docs','--no-multiarch')

install.packages(
  cran.packages,
  repos = 'https://cloud.r-project.org/',
  dependencies = TRUE,
  type = 'source',
  Ncpus = '4',
  clean = TRUE,
  INSTALL_opts = install.opts
)

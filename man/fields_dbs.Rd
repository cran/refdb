% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fields.R
\name{fields_dbs}
\alias{fields_dbs}
\alias{refdb_set_fields_NCBI}
\alias{refdb_set_fields_BOLD}
\alias{refdb_set_fields_PR2}
\alias{refdb_set_fields_diatbarcode}
\title{Functions to set fields for various databases}
\usage{
refdb_set_fields_NCBI(x)

refdb_set_fields_BOLD(x)

refdb_set_fields_PR2(x)

refdb_set_fields_diatbarcode(x)
}
\arguments{
\item{x}{a reference database.}
}
\value{
The function returns \code{x} with updated attributes.
}
\description{
Functions to set fields for various databases
}
\examples{
lib <- read.csv(system.file("extdata", "baetidae_bold.csv", package = "refdb"))
refdb_set_fields_BOLD(lib)

}

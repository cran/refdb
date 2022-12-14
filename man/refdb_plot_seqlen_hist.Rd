% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/refdb_plots.R
\name{refdb_plot_seqlen_hist}
\alias{refdb_plot_seqlen_hist}
\title{Plot an histogram of sequence lengths}
\usage{
refdb_plot_seqlen_hist(x, remove_gaps = TRUE)
}
\arguments{
\item{x}{a reference database}

\item{remove_gaps}{a logical (default \code{TRUE} to control whether
gaps (-) should be removed prior computing sequence lengths.}
}
\value{
A ggplot object. This means the plot
can be further customized using \pkg{ggplot2} compatible functions.
}
\description{
Plot an histogram of sequence lengths
}
\examples{
lib <- read.csv(system.file("extdata", "baetidae_bold.csv", package = "refdb"))
lib <- refdb_set_fields_BOLD(lib)
refdb_plot_seqlen_hist(lib)

}

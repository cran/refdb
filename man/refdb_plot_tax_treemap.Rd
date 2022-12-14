% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/refdb_plots.R
\name{refdb_plot_tax_treemap}
\alias{refdb_plot_tax_treemap}
\title{Reference database treemap}
\usage{
refdb_plot_tax_treemap(x, cols = NULL, freq_labels = c(0.01, 0.003))
}
\arguments{
\item{x}{a reference database.}

\item{cols}{a vector of column names referring to taxonomic levels
to include in the treemap. If not provided (\code{NULL})
the function tries to find a relevant subset of columns.}

\item{freq_labels}{a numeric vector of length two to adjust
the number of printed labels (see Details).


Only the columns provided in the \code{cols} argument are represented
in the treemap. Large labels are printed for the highest rank, while light
text labels are printed for the lowest rank
Intermediate ranks are drawn but their names are not shown.

The number of labels printed are determined by \code{freq_labels}.
The first value gives the threshold
for the highest rank (large labels) and the second value gives
the threshold for the lowest rank (light text labels).

The underlying graph is computed using the non-exported function
\code{igraph_from_taxo}.}
}
\value{
A \pkg{ggplot2} (\pkg{ggraph}) object. This means the plot
can be further customized using \pkg{ggplot2} compatible functions.
}
\description{
Represent the hierarchical structure of the taxonomic information
of a reference database as a set of nested rectangles (treemap).
}
\examples{
lib <- read.csv(system.file("extdata", "baetidae_bold.csv", package = "refdb"))
lib <- refdb_set_fields_BOLD(lib)
refdb_plot_tax_treemap(lib)

}

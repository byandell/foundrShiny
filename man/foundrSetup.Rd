% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/foundrSetup.R
\name{foundrSetup}
\alias{foundrSetup}
\title{Setup Data for Foundr App}
\usage{
foundrSetup(
  data_instance = c("Liver", "Trait"),
  data_subset = NULL,
  custom_settings = TRUE,
  dirpath = file.path("~", "founder_diet_study", "HarmonizedData")
)
}
\arguments{
\item{data_instance}{type of data}

\item{data_subset}{focus instance to selected dataset(s) if not `NULL`}

\item{custom_settings}{setup custom if `TRUE`}

\item{dirpath}{path to data directory}
}
\value{
invisible
}
\description{
Setup Data for Foundr App
}

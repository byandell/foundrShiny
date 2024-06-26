% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trait.R
\name{traitServer}
\alias{traitServer}
\alias{traitInput}
\alias{traitUI}
\alias{traitOutput}
\alias{traitApp}
\title{Shiny Module Server for Trait Panel}
\usage{
traitServer(
  id,
  main_par,
  traitData,
  traitSignal,
  traitStats,
  customSettings = NULL
)

traitInput(id)

traitUI(id)

traitOutput(id)

traitApp()
}
\arguments{
\item{id}{identifier for shiny reactive}

\item{traitData, traitSignal, traitStats}{static data frames}

\item{customSettings}{list of custom settings}
}
\value{
reactive object

nothing returned

nothing returned

nothing returned

nothing returned
}
\description{
Shiny Module Server for Trait Panel

Shiny Module Input for Trait Panel

Shiny Module UI for Trait Panel

Shiny Module Output for Trait Panel

Shiny Module App for Trait Panel
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/traitTable.R
\name{traitTableServer}
\alias{traitTableServer}
\alias{traitTableUI}
\alias{traitTableOutput}
\alias{traitTableApp}
\title{Shiny Module Server for Trait Table}
\usage{
traitTableServer(
  id,
  panel_par,
  main_par,
  keyTrait,
  relTraits,
  traitData,
  traitSignal,
  customSettings = NULL
)

traitTableUI(id)

traitTableOutput(id)

traitTableApp()
}
\arguments{
\item{id}{identifier for shiny reactive}

\item{panel_par, main_par}{reactive arguments}

\item{keyTrait, relTraits}{reactives with trait names}

\item{traitData, traitSignal}{static objects}

\item{input, output, session}{standard shiny arguments}
}
\value{
reactive object for `shinyTrait` routines

nothing returned

nothing returned

nothing returned
}
\description{
Shiny Module Server for Trait Table

Shiny Module UI for Trait Table

Shiny Module UI for Trait Table

Shiny Module App for Trait Table
}
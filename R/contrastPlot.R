#' Shiny Module Server for Contrast Plots
#'
#' @param id identifier
#' @param panel_par,main_par input parameters
#' @param contrast_table reactive data frame
#' @param customSettings list of custom settings
#' @param modTitle character string title for section
#'
#' @return reactive object 
#' @importFrom shiny column fluidRow moduleServer NS observeEvent
#'             radioButtons reactive reactiveVal reactiveValues renderUI
#'             req selectInput tagList uiOutput updateSelectInput
#' @importFrom DT renderDataTable
#' @importFrom foundr ggplot_conditionContrasts summary_conditionContrasts
#'             summary_strainstats
#' @export
#'
contrastPlotServer <- function(id, panel_par, main_par,
                              contrast_table, customSettings = NULL,
                              modTitle = shiny::reactive("Contrasts")) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    plot_par <- plotParServer("plot_par", contrast_table)
    volcano <- volcanoServer("volcano", input, plot_par, contrast_table)
    biplot  <- biplotServer("biplot", input, plot_par, contrast_table)
    dotplot <- dotplotServer("dotplot", input, plot_par, contrast_table)
    
    output$plot_table <- shiny::renderUI({
      shiny::tagList(
        shiny::h3(modTitle()),
        switch(shiny::req(main_par$plot_table),
          Plots  = shiny::tagList(
            shiny::uiOutput(ns("plot_choice")),
            shiny::uiOutput(ns("plot"))), 
          Tables = DT::renderDataTable(tableObject(), escape = FALSE,
            options = list(scrollX = TRUE, pageLength = 10))))
    })
    output$plot_choice <- shiny::renderUI({
      choices <- c("Volcano","BiPlot","DotPlot")
      shiny::checkboxGroupInput(ns("plot_choice"), "",
                                choices = choices, selected = choices, inline = TRUE)
    })
    output$plot <- shiny::renderUI({
      shiny::req(input$plot_choice)
      shiny::tagList(
        if("Volcano" %in% input$plot_choice) volcanoOutput(ns("volcano")),
        if("BiPlot" %in% input$plot_choice)  biplotOutput(ns("biplot")),
        if("DotPlot" %in% input$plot_choice) dotplotOutput(ns("dotplot")))
    })

    tableObject <- shiny::reactive({
      shiny::req(contrast_table())
      title <- ifelse(inherits(contrast_table(), "conditionContrasts"),
                      "Strains", "Terms")
      if(title == "Strains") {
        foundr::summary_conditionContrasts(
          dplyr::filter(contrast_table(), sex == shiny::req(panel_par$sex)),
          ntrait = 0)
      } else { # title == "Terms"
        foundr::summary_strainstats(contrast_table(),
                            stats = "log10.p", model = "terms",
                            threshold = c(p.value = 1.0, SD = 0.0))
      }
    })
    
    ###############################################################
    shiny::reactiveValues(
      postfix = shiny::reactive({
        shiny::req(contrast_table())
        paste(unique(contrast_table()$dataset), collapse = ",")
      }),
      plotObject = shiny::reactive({
        if("Volcano" %in% input$plot)
          print(shiny::req(volcano()))
        if("BiPlot" %in% input$plot)
          print(shiny::req(biplot()))
        if("DotPlot" %in% input$plot)
          print(shiny::req(dotplot()))
      }),
      tableObject = tableObject)
  })
}
#' Shiny Module UI for Contrast Plots
#' @return nothing returned
#' @rdname contrastPlotServer
#' @export
contrastPlotUI <- function(id) {
  ns <- shiny::NS(id)
  plotParInput(ns("plot_par")) # ordername, interact
}
#' Shiny Module Output for Contrast Plots
#' @return nothing returned
#' @rdname contrastPlotServer
#' @export
contrastPlotOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    plotParUI(ns("plot_par")), # volsd, volvert (sliders)
    plotParOutput(ns("plot_par")), # rownames (strains/terms)
    shiny::uiOutput(ns("plot_table")))
}
#' Shiny Sex App for Contrast Plots
#'
#' @return nothing returned
#' @rdname contrastSexServer
#' @export
contrastPlotApp <- function() {
  title <- "Test contrastSex Module"
  
  ui <- function() {
    shiny::fluidPage(
      shiny::titlePanel(title),
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          mainParInput("main_par"), # dataset
          border_line(),
          mainParUI("main_par") # order
        ),
        shiny::mainPanel(
          mainParOutput("main_par"), # plot_table, height
          shiny::fluidRow(
            shiny::column(4, shiny::uiOutput("sex")),
            shiny::column(8, contrastPlotUI("contrast_plot"))),
          contrastPlotOutput("contrast_plot")
        )
      )
    )
  }
  
  server <- function(input, output, session) {
    # Contrast Trait Table
    main_par <- mainParServer("main_par", traitStats)
    contrast_table <- contrastTableServer("contrast_table", main_par,
      traitSignal, traitStats, customSettings)
    contrastPlotServer("contrast_plot", input, main_par,
      contrast_table, customSettings)

    # SERVER-SIDE INPUTS
    output$strains <- shiny::renderUI({
      choices <- names(foundr::CCcolors)
      shiny::checkboxGroupInput(
        "strains", "Strains",
        choices = choices, selected = choices, inline = TRUE)
    })
    sexes <- c(B = "Both Sexes", F = "Female", M = "Male", C = "Sex Contrast")
    output$sex <- shiny::renderUI({
      shiny::selectInput("sex", "", as.vector(sexes))
    })
  }
  
  shiny::shinyApp(ui = ui, server = server)
}

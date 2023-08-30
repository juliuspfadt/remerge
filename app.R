
library(shiny)
library(DT)
library(readxl)

source("mergeDf.R")

# Define UI ----
ui <- fluidPage(
  titlePanel("Merge event and covariates data sets for REM in JASP"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Upload the event data"),
      fileInput(inputId = "eventData", buttonLabel = "Upload", label = NULL, multiple = FALSE, accept = c(".xlsx", ".csv"), 
                placeholder = ".csv, .xlsx"),
      h4("Upload the covariate data"),
      fileInput(inputId = "covariateData", buttonLabel = "Upload", label = NULL, multiple = FALSE, accept = c(".xlsx", ".csv"),
                placeholder = ".csv, .xlsx"),
      uiOutput("downloadText"), 
      uiOutput("downloadButton")
      ),
    
    mainPanel(
      uiOutput("title1"), 
      DTOutput("eventDataOut"),
      uiOutput("title2"), 
      DTOutput("covariateDataOut"),
      uiOutput("mergeButton"),
      uiOutput("mergedTitle"),
      DTOutput("mergedData")
      )
  )
)

# Define server logic ----
server <- function(input, output) {
  
  output$downloadText <- renderUI({
    if (is.null(mergedDt())) return()
    h4("Download the merged data")
  })
  
  output$downloadButton <- renderUI({
    if (is.null(mergedDt())) return()
    downloadButton("downloadData", "Download")
  })
  
  output$title1 <- renderUI({
    if (is.null(input$eventData)) return()
    h4("Event data")
  })
  
  output$title2 <- renderUI({
    if (is.null(input$covariateData)) return()
    h4("Covariate data")
  })
  
  output$mergeButton <- renderUI({
    if (is.null(input$covariateData) || is.null(input$eventData)) return()
    actionButton(inputId = "mergeDt", label = "Merge")
    
  })
  
  output$mergedTitle <- renderUI({
    if (is.null(mergedDt())) return()
    h4("Merged data")
  })
  
  dataset1 <- reactive({
    tmp <- input$eventData
    req(tmp)
    if (endsWith(tmp$datapath, ".csv")) {
      dt <- read.csv(file = tmp$datapath)
    } else if (endsWith(tmp$datapath, ".xlsx")) {
      dt <- read_excel(tmp$datapath)
    }
    return(dt)
  })
  
  output$eventDataOut <- renderDT(options = list(pageLength = 5, dom = "pt"), {
    dataset1()
  })
  
  dataset2 <- reactive({
    tmp <- input$covariateData
    req(tmp)
    if (endsWith(tmp$datapath, ".csv")) {
      dt <- read.csv(file = tmp$datapath)
    } else if (endsWith(tmp$datapath, ".xlsx")) {
      dt <- read_excel(tmp$datapath)
    }
    return(dt)
  })
  
  output$covariateDataOut <- renderDT(options = list(pageLength = 5, dom = "pt"), {
    dataset2()
  })
  
  # output$test <- renderText({
  #   mode(dataset1())
  # })
  
  mergedDt <- eventReactive(input$mergeDt, {
    tmp <- mergeDf(dataset1(), dataset2())
    req(tmp)
    return(tmp)
  })
  
  output$mergedData <- renderDT(options = list(pageLength = 5, dom = "pt"), {
    mergedDt()
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(mergedDt(), file, row.names = FALSE)
    }
  )
  
  

}

# Run the app ----
shinyApp(ui = ui, server = server)



library(shiny)
library(DT)
library(readxl)

source("mergeDf.R")

# Define UI ----
ui <- fluidPage(
  titlePanel("Merge event and covariates data sets for REM in JASP"),
  uiOutput("link"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Upload the event data"),
      fileInput(inputId = "eventData", buttonLabel = "Upload", label = NULL, multiple = FALSE, accept = c(".xlsx", ".csv"), 
                placeholder = ".csv, .xlsx"),
      uiOutput("deleteEvDataButton"),
      h4("Upload the covariate data"),
      fileInput(inputId = "covariateData", buttonLabel = "Upload", label = NULL, multiple = FALSE, accept = c(".xlsx", ".csv"),
                placeholder = ".csv, .xlsx"),
      uiOutput("deleteCovDataButton"),
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

  url <- a("Github page", href="https://github.com/juliuspfadt/remerge")
  output$link <- renderUI({
    tagList("Help:", url)
  })

  ### event data 
  
  output$title1 <- renderUI({
    if (is.null(input$eventData)) return()
    h4("Event data")
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
  
  # for storing and deleting the datasets
  mydf <- reactiveValues()
  
  observeEvent(input$eventData, {
    mydf$data1 <- dataset1()
  })
  
  output$eventDataOut <- renderDT(options = list(pageLength = 5, dom = "pt"), {
    mydf$data1
  })
  
  output$deleteEvDataButton <- renderUI({
    if (is.null(mydf$data1)) return()
    actionButton("deleteEventData", "Remove")
  })
  
  observeEvent(input$deleteEventData, {
    mydf$data1 <- NULL
  })
  
  
  ### covariates data
  output$title2 <- renderUI({
    if (is.null(input$covariateData)) return()
    h4("Covariate data")
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
  
  observeEvent(input$covariateData, {
    mydf$data2 <- dataset2()
  })
  
  output$covariateDataOut <- renderDT(options = list(pageLength = 5, dom = "pt"), {
    mydf$data2
  })
  
  output$deleteCovDataButton <- renderUI({
    if (is.null(mydf$data2)) return()
    actionButton("deleteCovariateData", "Remove")
  })
  
  observeEvent(input$deleteCovariateData, {
    mydf$data2 <- NULL
  })

  
  ### merged data
  output$mergedTitle <- renderUI({
    if (is.null(mergedDt())) return()
    h4("Merged data")
  })
  
  output$mergeButton <- renderUI({
    if (is.null(input$eventData) || is.null(input$covariateData)) return()
    actionButton(inputId = "mergeDt", label = "Merge")
    
  })
  
  mergedDt <- eventReactive(input$mergeDt, {
    tmp <- mergeDf(mydf$data1, mydf$data2)
    req(tmp)
    return(tmp)
  })
  
  output$mergedData <- renderDT(options = list(pageLength = 5, dom = "pt"), {
    mergedDt()
  })
  
  ### download
  output$downloadText <- renderUI({
    if (is.null(mergedDt())) return()
    h4("Download the merged data")
  })
  
  output$downloadButton <- renderUI({
    if (is.null(mergedDt())) return()
    downloadButton("downloadData", "Download")
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


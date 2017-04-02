library(shiny)

shinyUI(
  fluidPage(
    # tytul aplikacji
    titlePanel("Wstepna analiza danych"), 
    sidebarLayout(
      sidebarPanel(
        #kontrolki wejscia
        selectInput("variable", "Nazwa:",
                    list("General Electic Company "="GE",
                         "3m Company"="MMM",
                         "Boeing Company"="BA",
                         "Union Pacific Corporation"="UNP",
                         "Caterpillar Inc."="CAT",
                         "Honeywell International Inc."="HON",
                         "General Dynamics Corporation"="GD",
                         "FedEx Corporation"="FDX",
                         "United Parcel Service"="UPS",
                         "Procter & Gamble Co"="PG",
                         "Wal-Mart Stores Inc"="WMT",
                         "The Coca-Cola Co"="KO",
                         "PepsiCo, Inc"="PEP"),
                    selected="GE"
                    ),
        sliderInput("date_range", 
                    "Wybierz zakres czasowy:", 
                    min = as.Date("2015-01-01"), max = Sys.Date(), 
                    value = c(as.Date("2016-02-25"), Sys.Date())
        ),
        sliderInput("Bins","Liczba przedzialow w histogramie",
                    min=1, 
                    max=25, 
                    value=9),
        actionButton("go", "Rozklad normalny"),
        actionButton("go2", "Wygladzony model"),
        h3(verbatimTextOutput("print4"))
        
      ),
      mainPanel(
        #wyscie: wykresy i dane
        h2(textOutput("name1")),
        h3(verbatimTextOutput("print1")),
        fluidRow(
          column(6, plotOutput("Plot1")),
          column(6, plotOutput("Plot2"))
          ),
        fluidRow(
          column(12, plotOutput("Plot3"))
        )
      ) #end mainPanel
    ) #end sidebarPanel
  ) #end fluidPage 
) #end shinyUI


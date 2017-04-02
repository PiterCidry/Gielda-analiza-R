library(quantmod)

shinyServer(function(input, output){
  
  output$name1 <- renderText({input$variable})
  lolcio<- FALSE
  lolcio1<-FALSE
  
  d <- reactive({
    getSymbols(input$variable, src="google", 
               from = as.Date(input$date_range[1]), 
               to = as.Date(input$date_range[2]),
               auto.assign = F)
  })
  test<-reactive({as.data.frame(getSymbols(Symbols = input$variable, 
                                 src = "google", from = input$date_range[1],to = input$date_range[2], env = NULL))})
  output$print1 = renderPrint({
    summary(test()[,4])
  })
  
  output$Plot1 <- renderPlot({
  plot(test()[,4], type="l", xlab="Odczyt", ylab="Kurs zamkniecia", main = paste("wykres", input$variable))
    
    })
  output$Plot2 <- renderPlot({
    bins <- seq(min(d()[,4]), max(d()[,4]), length.out = input$Bins +1)
    
    list_histo<-hist(d()[,4], breaks = bins, col = "skyblue", border = "white",
         xlab=paste(input$variable, "zamkniecie"), main = paste("Histogram", input$variable), ylab = "Czestotliwosc")
               
           
  })
  output$Plot3 <- renderPlot({
    x <- 1:length(test()[,4])
    y <- test()[,4]
    predict(lm(y ~ x))
    #x<-1:length(test()[,4])
    #y<-as.vector(smooth(test()[,4]))
    plot(test()[,4], type="l", xlab="Odczyt", ylab="Kurs zamkniecia", main = paste("Trend liniowy"))
    lines(x,predict(lm(y ~ x)),col="purple", lwd=3)
  })
  
  
  observeEvent(input$go2, {
    lolcio1<<-!lolcio1
    if (lolcio1) {
      output$Plot1 <- renderPlot({
        plot(test()[,4], type="l", xlab="Data", ylab="Kurs zamkniecia", main = paste("wykres", input$variable))
        x<-1:length(test()[,4])
        y<-as.vector(smooth(test()[,4]))
        lines(x,y,col="green", lwd=2)
      })
        
      
    } else {
      output$Plot1 <- renderPlot({
        plot(test()[,4], type="l", xlab="Data", ylab="Kurs zamkniecia", main = paste("wykres", input$variable))

      })
    }
    
  })
  
  observeEvent(input$go, {
    lolcio<<-!lolcio
    if (lolcio) {
      output$Plot2 <- renderPlot({
        bins <- seq(min(d()[,4]), max(d()[,4]), length.out = input$Bins +1)
        
        list_histo<-hist(d()[,4], breaks = bins, col = "skyblue", border = "white",
                         xlab=paste(input$variable, "zamkniecie"), main = paste("Histogram", input$variable), ylab = "Czestotliwosc")
        
        x<-seq(min(d()[,4]), max(d()[,4]), length.out = 500)
        y<-dnorm(x, mean = mean(d()[,4]), sd = sd(d()[,4]))
        lines(x,y/max(y)*max(list_histo$counts), col="red", lwd=3)
        output$print4 = renderPrint({
          shapiro.test(test()[,4])
        })
        
      })
    } else {
      output$Plot2 <- renderPlot({
        bins <- seq(min(d()[,4]), max(d()[,4]), length.out = input$Bins +1)
        
        list_histo<-hist(d()[,4], breaks = bins, col = "skyblue", border = "white",
                         xlab=paste(input$variable, "zamkniecie"), main = paste("Histogram", input$variable), ylab = "Czestotliwosc")
        
        x<-seq(min(d()[,4]), max(d()[,4]), length.out = 500)
        y<-dnorm(x, mean = mean(d()[,4]), sd = sd(d()[,4]))
        
        output$print4 = renderPrint({
          "Brak daych"
        })
        
      })
    }
    
  })
  
})

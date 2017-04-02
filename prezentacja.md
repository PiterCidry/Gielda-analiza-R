
Programowanie w R - projekt zaliczeniowy
========================================================
author: Piotr Gretszel, Rafal Bondyra
date: 14.02.2017
autosize: true
font-family: 'Verdana'
css: prezentacja.css


Podzial pracy
========================================================
~~**Aplikacje web** wykonal w wiekszosci Rafal Bondyra na podstawie pliku z zajec od Piotra Gretszela. Dodano kilka elementow o ktorych szerzej w dalszej czesci. Wspolnie ustalilismy na jakich danych bedziemy pracowac oraz jakie elementy bedzie zawierwala aplikacja. **Prezentacje** w calosci oraz usprawnienia aplikacji wykonal Piotr Gretszel.~~

Opis Danych
========================================================
left: 70%
~~Dane pochodza ze strony [https://www.google.com/finance](https://www.google.com/finance).  
Dotycza one notowan kilku wielkich korporacji notowanych na gieldzie w Nowym Jorku.
Api udostepnia kursy: otwarcia, najwyzszy, najnizszy, zamkniecia i wolumen.  
Do naszej analizy wykorzystujemy **kursy zamkniecia** w danym dniu.~~
***
![alt](13.jpg)

Wybor korporacji
========================================================
id: wyborkorpo
left: 40%
Dokonujemy go poprzez wybranie z listy dostepnych korporacji:    
![alt](1.jpg)
***
### Kod ui.R:
```
selectInput("variable", "Nazwa:",  
                    list("General Electic Company "="GE",  
                         .   
                         .   
                         .   
                         "PepsiCo, Inc"="PEP"),   
                    selected="GE"   
                    ),
```

Wybor zakresu danych
========================================================
id:wyborzakresu
Po wyborze korporacji nalezy wybrac dla jakiego przedzialu czasowego przeprowadzane maja byc wszystkie obliczenia:
![alt](2.jpg)
***
### Kod ui.R:
```
sliderInput("date_range", 
                    "Wybierz zakres czasowy:", 
                    min = as.Date("2016-01-01"), max = Sys.Date(), 
                    value = c(as.Date("2016-02-25"), Sys.Date())
        ),
```

Pobieranie danych
========================================================
~~Pobieranie danych za pomoca fukncji getSymobls:~~  
```
d <- reactive({
    getSymbols(input$variable, src="google", 
               from = as.Date(input$date_range[1]), 
               to = as.Date(input$date_range[2]),
               auto.assign = F)
  })
  test<-reactive({as.data.frame(getSymbols(Symbols = input$variable, 
                                 src = "google", from = input$date_range[1],to = input$date_range[2], env = NULL))})
```  
>- *input$variable* - wybrana korporacja [Zobacz](#/wyborkorpo)
>- *input$date_range* - zakres dat [Zobacz](#/wyborzakresu)

Statystyki opisowe
========================================================
~~Automatyczne obliczanie podstawowych statystyk opisowych dla wybranej korporacji w wybranym przedziale czasowym:~~  
<div align="center">
<img src="3.jpg" width=800 height=600>
</div>
***
### Kod server.R:  
```
output$print1 = renderPrint({
    summary(test()[,4])
  })
```  
### Kod ui.R:  
```
h3(verbatimTextOutput("print1")),
```

Statystyki opisowe - interpretacja
========================================================

~~- **Min.** - wartosc minimalna w zbiorze danych~~  
~~- **1st Qu.** - kwartyl dolny zbioru danych (25% danych ponizej tej wartosci)~~  
~~- **Median** - mediana (wartosc srodkowa) w zbiorze danych~~  
~~- **Mean** - srednia wartosc w zbiorze danych~~  
~~- **3rd Qu.** - kwartyl gorny zbioru danych (25% danych powyzej tej wartosci)~~  

Wykres podstawowy
========================================================
~~Obrazuje zmiany kursu zamkniecia wybranej korporacji w podanym zakresie czasowym:~~  
<div align="center">
![alt](4.jpg)

***
### Kod server.R:
```
output$Plot1 <- renderPlot({
  plot(test()[,4], type="l", xlab="Odczyt", ylab="Kurs zamkniecia", main = paste("wykres", input$variable))
    })
```  
### Kod ui.R:
```
fluidRow(
          column(6, plotOutput("Plot1")),
          ...
          ),
```

Wykres podstawowy - interpretacja
========================================================
~~Z wykresu podstawowego mozemy odczytac jakie wartosci przyjmowal kurs zamkniecia w czasie. Dla wybranych danych na potrzeby prezentacji mozemy interpretowac, ze firma Boeing na poczatku 2016 roku przechodzila kryzys i cena jej akcji systematycznie spadala by nastepnie wzrosnac gwaltownie i przez dlugi okres utrzymywac sie na wzglednie stalym poziomie. W drugiej polowie 2016r firma doswiadczyla hossy gieldowej i wartosc akcji poszybowala znacznie w gore. Niedawno cena akcji osiagnela swoje maksimum.~~

Liczba przedzialow histogramu
========================================================
~~Pozwala na wybranie liczby klas w histogramie~~
<div align = "center">
![alt](7.jpg)
***
### Kod server.R:
```
sliderInput("Bins","Liczba przedzialow w histogramie",
                    min=1, 
                    max=25, 
                    value=9),
```

Histogram
========================================================
id:histogram
~~Obrazuje czestosc wystepowania poszczegolnych kursow zamkniecia:~~
<div align="center">
![alt](5.jpg)
***
### Kod server.R:
```
output$Plot2 <- renderPlot({
    bins <- seq(min(d()[,4]), max(d()[,4]), length.out = input$Bins +1)
    
    list_histo<-hist(d()[,4], breaks = bins, col = "skyblue", border = "white",
         xlab=paste(input$variable, "zamkniecie"), main = paste("Histogram", input$variable), ylab = "Czestotliwosc")
               
           
  })
```
### Kod ui.R:
```
fluidRow(
          ...
          column(6, plotOutput("Plot2"))
          ),
```
Histogram - interpretacja
========================================================
~~Histogram sluzy do przedstawienia rozkladow empirycznych cech, co oznacza, ze za jego pomoca, przedstawiamy jakie
uzyskalismy wyniki dla pewnych zmiennych ilosciowych. Odpowiada na pytania (w sposob graficzny) przy jakich wartosciach zlokalizowane jest wiekszosc naszych wynikow.   
Z histogramu dla firmy Boeing mozna wnioskowac, ze zdecydowanie najczesciej jej cena akcji byla w przedziale **129-135$**.~~

Trend liniowy
========================================================
~~Linia trendu naniesiona na wykres podstawowy:~~
<div align="center">
![alt](6.jpg)
***
### Kod server.R:
```
output$Plot3 <- renderPlot({
    x <- 1:length(test()[,4])
    y <- test()[,4]
    predict(lm(y ~ x))
    plot(test()[,4], type="l", xlab="Odczyt", ylab="Kurs zamkniecia", main = paste("Trend liniowy"))
    lines(x,predict(lm(y ~ x)),col="purple", lwd=3)
  })
```
### Kod ui.R:
```
fluidRow(
          column(12, plotOutput("Plot3"))
        )
```

Trend liniowy - interpretacja
========================================================
~~Wyznaczanie trendu liniowego polega na dopasowywaniu do wykresu dla danych, funkcji w postaci:~~  
>**y = ax + b**

>- jezeli a > 0 to funkcja jest rosnaca
- jezeli a = 0 to funkcja jest stala
- jezeli a < 0 to funkcja jest malejaca

~~Dla wybranych danych z firmy Boeing mozna latwo na wykresie zauwazyc, ze funkcja jest rosnaca a wiec jest wspolczynnik *a* jest wiekszy od zera. Oznacza to, ze cena akcji tej korporacji ma tendencje wzrostowe w czasie.~~

Przycisk "rozklad normalny"
========================================================
~~Dodaje funkcjonalnosci w postaci nakladania na histogram dystrybuanty rozkladu normalnego oraz przeprowadzania testu normalnosci Shapiro-Wilka~~
<div align="center">
<img src="8.jpg" width=400 height=300>
</div>
***
### Kod ui.R:
```
actionButton("go", "Rozklad normalny"),
```
~~Jego nacisniecia zmienia wartosc logiczna operatora~~

Zgodnosc z rozkladem normalnym (1)
========================================================
~~Dystrybuanta rozkladu normalnego naniesiona na histogram:~~
<div align="center">
![alt](12.jpg)
***
### Kod server.R:
```
output$Plot2 <- renderPlot({
        ...
        x<-seq(min(d()[,4]), max(d()[,4]), length.out = 500)
        y<-dnorm(x, mean = mean(d()[,4]), sd = sd(d()[,4]))
        lines(x,y/max(y)*max(list_histo$counts), col="red", lwd=3)
        ...})
```
~~reszta jak [tutaj](#/histogram)~~

Zgodnosc z rozkladem normalnym (2)
========================================================
~~Test normalnosci Shapiro-Wilka:~~
<div align="center">
<img src="10.jpg" width=600 height=400>
</div>
***
### Kod server.R:
```
output$print4 = renderPrint({
          shapiro.test(test()[,4])
        })
```
### Kod ui.R:
```
h3(verbatimTextOutput("print4"))
```

Zgodnosc z roskladem normalnym - interpretacja (1)
========================================================
~~Jezeli dane pochodzilyby z rozkladu normalnego (lub byly do niego zblizone) to histogram czestosci powinien pokrywac sie z naniesiona czerwnona linia oznaczajaca dystrybuante rozkladu normalnego.  
Cena akcji firmy Boeing ma dosyc oddalony histogram od czerwonej linii co pozwala powiedziec, ze dane raczej nie maja rozkladu podobnego do rozkladu normalnego.~~

Zgodnosc z roskladem normalnym - interpretacja (2)
========================================================
~~Aby jeszcze dokladniej ocenic rozklad danych, mozna przeprowadzic test normalnosci. W naszym projekcie posluzylismy sie testem **Shapiro-Wilka**.~~  
## Hipoteza glowna: "Dane maja rozklad normalny"  
## Hipoteza alternatywna: "Dane nie maja rozkladu normalnego"
Wartosc p-value: 0.00001947715 = 3.17e^(-12)  
```
p-value < 0.05
```  
~~A wiec na 95% mozemy odrzucic hipoteze, ze te dane pochodza z rozkladu normalnego.~~

Przycisk "wygladzony model"
========================================================
~~Dodaje funkcjonalnosc w postaci nakladania na wykres lini danych wygladzonych przez srednia ruchoma~~
<div align="center">
<img src="9.jpg" width=200 height=150>
</div>
<div align="center">
<img src="11.jpg" width=500 height=300>
</div>
***
### Kod ui.R (przycisk):
```
actionButton("go2", "Wygladzony model"),
```

### Kod server.R (wygladzona linia)
```
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
      ...
    }
  })
```
Koniec
==========================================================
~~Dziekujemy za uwage.~~

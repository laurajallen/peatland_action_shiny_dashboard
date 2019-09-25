
## This is the code for the user interface side of the app - so what plots show up, what you can enter and the general layout
## All the contents of the outputs are created and defined within the 'server' tab.

# Define the UI
fluidPage( ## title and logo, plus intro text: 
  titlePanel(title=div(img(src = "Peatland Action no strapline.png", height = 70, width = 80), "  Peatland ACTION projects")),
  p("Here you can see an overview of the Peatland ACTION work carried out from 2012-2019. You can see the summary data for a specific year, or explore the trends in restoration projects over time. Use the dropdown menus to select the data of interest and the charts and map will be updated accordingly."),
  
  # Main panel for displaying outputs ----
  mainPanel(width= 12, ## total width of page is 12 columns, so you can choose how many columns each section occupies (I split it 5 & 7)
    column(5, 
           uiOutput('report'), ## show the summary report, based on the selected year
           hr(), ## line break
           h4("Compare data across years (choose a topic):"), ## header (h4 is size)
           selectInput(inputId = "selectdata", ## selectdata is the name of the input variable (choice of data type (hectares etc))
                       label = NULL,
                       choices = c("Number of projects", "Area in hectares", "Money spent", "Total funding")), ## what types of data you can choose in dropdown
           plotlyOutput('trends')), ## show the plot of trends across years
    column(7,
           h4("View data by year (select a year):"),
           # Input: Slider for the number of bins ----
           selectInput(inputId = "selectyear", ## select year to display data for
                       label = NULL,
                       choices = c("all years","2012-13","2013-14","2014-15","2015-16","2016-17","2017-18","2018-19", "2019-20")), ## choice of years in dropdown
           h4("Map of projects for selected year"),   ## header for map
           # Output: Map of sites ----
           leafletOutput('leaf',height=600)) ## display map
  ) #mainPanel bracket
  
)#fluidPage bracket
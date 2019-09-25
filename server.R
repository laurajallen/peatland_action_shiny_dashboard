## the server tab is where things happen behind the scenes, such as applying the filter to the data based on the selection in the dropdown menu,

# Define the server code
function(input, output) { ## this is a function that take 'input' variable from the ui, and then creates an output that can be displayed
  
  sites_filtered <- reactive({ ## reactive means that the output will change depending on what input you give it (from the dropdown menus)
    
    if(input$selectyear == "all years"){ ## if all years are selected, then plot all sites
      sites <- sites 
    } else{
    
    sites <- sites %>% filter(Financial.year == input$selectyear) ## otherwise filter the sites to plot by the financial year selected
    }
  })
  
    output$leaf <- renderLeaflet({ ## Leaflet is a map package
      leaflet(sites_filtered()) %>% ## it takes whatever sites have been filtered by the year selection and plot those
        addTiles() %>% ## background tiles for map
        addMarkers(~x,~y, clusterOptions = markerClusterOptions(), ## adds markers at the grid ref points, and these can be clustered when you zoom in and out
                   popup = (sprintf(#tooltip
                       "Grant reference: %g<br/>Project: %s<br/>Hectares: %g<br/>Project type: %s", # This specifies the label prefix to show next to the  info taken from the data. Where the data are numbers, this is indicated with a %g, and %s for text
                       sites_filtered()$Grant.reference, sites_filtered()$Project.name, 
                       sites_filtered()$Hectares.restoration, sites_filtered()$Project.type) %>% lapply(htmltools::HTML))) ## this control what is shown in the pop up summary display for each site 
        
    })
    
    output$selected_var <- renderText({ 
      paste("Summary of year", input$var) ## change heading to say which year it is a summary of
    })

    output$report <- renderUI({ ## creating the summary table depending on the year selected in the dropdown menu
      
      if(input$selectyear == "all years"){ 
        totals_summary <- totals %>% select(value, data_type) %>% group_by(data_type) %>% 
          summarise(value= sum(value, na.rm=T)) ## if you select all years, then sum up the values for the summary report (from the dataset created calculating the totals by year)
      } else{
        
        totals_summary <-  totals %>% filter(Year == input$selectyear) ## get the values from the 'totals' dataset for the year selected
      }
      
      tagList( ## this output for the summary report
        div(style = "border: 3px solid rgb(119, 187, 224); width:100%", ## ## change the width, colour and thickness of the border. The style can be customised with html (when you run the shiny app you can right click and choose 'inspect' you can see the html code and try customising it to change style by copying and pasting bits, then use that in here)
            div(h4(paste0("Summary data for ", input$selectyear)), style = "background-color: rgb(119, 187, 224); padding: 5px;"),  ## header, customised by year selected. Colour and space between text and border adjusted
            div(style= "padding: 5px;", ## the amount of space between the text and border
              h4("Number of projects: ", totals_summary$value[totals_summary$data_type == "Number of projects"]), ## what to display in the summary, selecting the totals for each data type for the year selected
            h4("Hectares on the road to restoration: ", totals_summary$value[totals_summary$data_type == "Area in hectares"]),
            h4("Money spent: £", totals_summary$value[totals_summary$data_type == "Money spent"])))
        )
    })

    
    totals_filtered <- reactive({
      
        totals <- totals  %>% 
          filter(data_type == input$selectdata) ## filter the annual data by the choice of data type selected in the dropdown menu

    })

    output$trends <- renderPlotly({ ## create a pretty chart using plotly (lots of customisable options available)


      #Text for tooltip
      tooltip_trend <- c(paste0(totals_filtered()$rest_feas, ": ", totals_filtered()$value)) # hover-over tooltip for chart, displays values
      
      #Creating time trend plot
      trend_plot <- plot_ly(data=totals_filtered(), x=~Year,  y = ~value,  ## plot the data based on slection in dropdown
                            text=tooltip_trend, hoverinfo="text", color = ~rest_feas) %>%   ## add tooltips, and have colour based on whether restoration or feasibility study
        add_trace(type = 'scatter', mode = 'lines+markers', marker = list(size = 8)) %>% # how to plot it (scatterplot with dots and lines)
        #Layout 
        layout(yaxis = list(title = unique(totals_filtered()$data_type), rangemode="tozero", fixedrange=TRUE, ## label y axis with data type (depends on selection)
                            size = 4, titlefont =list(size=14), tickfont =list(size=14)), 
               xaxis = list(title = "Financial year", tickfont =list(size=14),  fixedrange=TRUE), ## set x axis labels
               showlegend = TRUE,
               legend = list(orientation = 'h', x = 0, y = 1.18)) %>%  #legend on top
        config(displayModeBar = TRUE, displaylogo = F) # taking out plotly logo and collaborate button
      
    })
}


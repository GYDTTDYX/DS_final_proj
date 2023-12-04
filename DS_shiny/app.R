library(ggplot2)
library(dplyr)
library(feasts)
library(tsibble)
library(shiny)
library(tidyverse)
library(shinythemes)
library(wordcloud2)
library(glmnet)
library(caret)
library(ROCR)
library(janitor)



# Read data and clean
df = read.csv("games.csv") %>%
  janitor::clean_names() %>%
  subset(select = -c(dlc_count, about_the_game, reviews, header_image, website, support_url, support_email, metacritic_score, metacritic_url, notes, developers, publishers, screenshots, movies, score_rank, average_playtime_two_weeks, median_playtime_two_weeks, average_playtime_forever, peak_ccu, full_audio_languages)) %>%
  subset(price > 0)

# Change the format of release date
df$release_date = as.Date(df$release_date, format = "%b %d, %Y")


genre_freq_year = df|>
  mutate(year = year(release_date))|>
  separate_rows(genres, sep = ",")|>
  group_by(year, genres)|>
  summarise(n_obs = n())|>
  group_by(year)

genre_freq_year_total = df|>
  mutate(year = year(release_date))|>
  separate_rows(genres, sep = ",")|>
  group_by(year)|>
  summarise(n_obs_total = n())


# Define Shiny app
ui <- fluidPage(
  titlePanel("Steam game high-frequency word display"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("price", "Select Price Range", min = 0, max = max(df$price), value = c(0, max(df$price))),
      dateRangeInput("release_date", "Select Release Date Range", 
                     start = "1997-06-30", end =  "2023-08-07",
                     min = "1997-06-30", max = "2023-08-07"),
      numericInput("positive_rate", "Select Positive rate", value = 0.7, min = 0, max = 1),
      numericInput("review_number", "Select Total Review Number", value = 10, min = 0, max = max(df$positive)+max(df$negative)),
      numericInput("median_playtime", "Select median_playtime", value = 120, min = 0, max = max(df$median_playtime_forever)),
      selectInput("estimated_owner","Select estimated_owners",
                  choices = c("0 - 20000",
                              "50000 - 100000",
                              "20000 - 50000" ,
                              "200000 - 500000",
                              "100000 - 200000",
                              "2000000 - 5000000",
                              "500000 - 1000000",
                              "0 - 0",
                              "1000000 - 2000000",
                              "20000000 - 50000000",
                              "5000000 - 10000000",
                              "10000000 - 20000000",
                              "50000000 - 100000000"),
                  selected = "0 - 20000"),
      br(),
      br(),
      sliderInput("Year","Select year for bar plot",min = 1997, max = 2016, value = c(1997,2016))
    ),
    
    
    mainPanel(
      h4("Wordcloud of subset of games based on specific evaluation matrix"),
      wordcloud2Output("wordcloud"),
      tags$hr(),
      h4("Barplot of genre frequency based on selected timeframe"),
      plotOutput("barplot")
    )
  )
)

server <- function(input, output) {
  filtered_data <- reactive({
    df %>%
      filter(price >= input$price[1] & price <= input$price[2]) %>%
      filter(release_date >= input$release_date[1] & release_date <= input$release_date[2])%>%
      filter(positive/(positive+negative) >= input$positive_rate[1])%>%
      filter((positive+negative) >= input$review_number[1])%>%
      filter(median_playtime_forever > input$median_playtime[1])%>%
      filter(estimated_owners != input$estimated_owner[1])
  })
  
  output$wordcloud <- renderWordcloud2({
    tags_data <- filtered_data() %>%
      separate_rows(tags, sep = ",") %>%
      group_by(tags) %>%
      summarise(n_obs = n())
    
    wordcloud2(tags_data)
  })
  
  output$barplot <- renderPlot({
    popular_genres_bar_plot = left_join(genre_freq_year, genre_freq_year_total, by = "year")|>
      subset(year >= input$Year[1] & year <= input$Year[2])|>
      mutate(genre_ratio = n_obs/n_obs_total)|>
      ggplot(aes(x = year, y = genre_ratio, fill = genres)) + 
      geom_col(position = 'stack', width = 0.6)+
      theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1))
    popular_genres_bar_plot
  })
}

shinyApp(ui, server)


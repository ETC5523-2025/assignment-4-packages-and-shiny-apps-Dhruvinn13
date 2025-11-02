library(shiny)
library(ggplot2)
library(dplyr)

ui <- fluidPage(
  titlePanel("fireRiskR • Fire Weather Risk Explorer"),
  tags$head(tags$style(HTML("
    body { background:#f8fafc; }
    .panel { background:#ffffff; border-radius:14px; box-shadow:0 4px 12px rgba(0,0,0,.06); padding:16px; }
    .title { font-size:26px; font-weight:700; margin-bottom:6px; }
    .muted { color:#6b7280; }
  "))),
  div(class="title","Fire Weather Risk Explorer"),
  div(class="muted","Interactive view of published probability ratios (PR) for extreme FWI events."),
  br(),
  sidebarLayout(
    sidebarPanel(class="panel",
                 selectInput("scenario", "Scenario:",
                             choices = unique(fireRiskR::fwi_pr$scenario)),
                 helpText(HTML("
        <b>What the fields mean</b><br/>
        <b>PR (probability ratio)</b>: how many times more likely an event is compared with the early-20th-century baseline.<br/>
        <b>1920→2019</b>: early 20th century vs present climate.<br/>
        <b>1920→2°C</b>: early 20th century vs a +2 °C world.<br/><br/>
        <b>How to interpret</b>: A PR of 4 means '4× more likely'. Lower bounds are conservative.
      "))
    ),
    mainPanel(
      div(class="panel",
          plotOutput("bars", height = 360),
          hr(),
          h4("Values table"),
          tableOutput("tbl"),
          tags$small(class="muted",
                     HTML("Values summarised from van Oldenborgh et al. (2021)"))
      )
    )
  )
)

server <- function(input, output, session) {
  data_react <- reactive({
    fireRiskR::fwi_pr |>
      filter(scenario == input$scenario)
  })
  
  output$bars <- renderPlot({
    df <- data_react()
    ymax <- max(ifelse(is.na(df$pr_best), df$pr_lower, df$pr_best), na.rm = TRUE) * 1.25
    
    ggplot(df, aes(x = source)) +
      geom_col(aes(y = ifelse(is.na(pr_best), pr_lower, pr_best))) +
      geom_errorbar(aes(ymin = pr_lower,
                        ymax = ifelse(is.na(pr_upper),
                                      ifelse(is.na(pr_best), pr_lower, pr_best),
                                      pr_upper)),
                    width = .2) +
      labs(x = NULL, y = "PR (times more likely)",
           title = paste("FWI probability ratios:", unique(df$scenario))) +
      theme_minimal(base_size = 13) +
      coord_cartesian(ylim = c(0, ymax))
  })
  
  output$tbl <- renderTable({
    fireRiskR::fwi_pr |>
      dplyr::filter(scenario == input$scenario) |>
      dplyr::mutate(
        pr_lower = ifelse(is.na(pr_lower), "—", pr_lower),
        pr_best  = ifelse(is.na(pr_best),  "—", pr_best),
        pr_upper = ifelse(is.na(pr_upper), "—", pr_upper)
      ) |>
      dplyr::select(source, pr_lower, pr_best, pr_upper, note)
  }, digits = 2)
}

shinyApp(ui, server)

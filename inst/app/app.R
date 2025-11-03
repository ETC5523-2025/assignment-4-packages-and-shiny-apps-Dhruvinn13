library(shiny)
library(ggplot2)
library(dplyr)
library(bslib)     
library(thematic)  

ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bootswatch = "minty",                        
    primary = "#0ea5e9",                         
    secondary = "#0f172a",
    success = "#10b981",
    info = "#06b6d4",
    warning = "#f59e0b",
    danger = "#ef4444",
    base_font = font_google("Poppins"),
    heading_font = font_google("Poppins"),
    bg = "#f7fafc", fg = "#0f172a"
  ),
  title = "fireRiskR • Fire Weather Risk Explorer",
  titlePanel("fireRiskR • Fire Weather Risk Explorer"),
  
  # Extra polish (kept your existing classes, just enhanced them)
  tags$head(tags$style(HTML("
    body { background:#f7fafc; }
    .panel { 
      background:#ffffff; border-radius:18px; 
      box-shadow:0 10px 24px rgba(2,8,23,.06);
      padding:18px; border:1px solid rgba(2,8,23,.06);
    }
    .muted { color:#64748b; }
    .download-btn .btn { display:flex; align-items:center; gap:.6rem; }
    .btn-primary {
      box-shadow:0 6px 14px rgba(14,165,233,.22);
      border-radius:12px; padding:.5rem .9rem; font-weight:600;
    }
    /* Gradient title */
    .container h2 {
      background: linear-gradient(90deg,#0ea5e9,#22c55e);
      -webkit-background-clip: text; background-clip:text; color:transparent;
      font-weight:800; letter-spacing:.3px;
    }
  "))),
  div(class="muted",
      "Interactive view of published probability ratios (PR) for extreme FWI events."
  ),
  br(),
  sidebarLayout(
    sidebarPanel(
      class = "panel",
      selectInput("scenario", "Scenario:",
                  choices = unique(fireRiskR::fwi_pr$scenario)),
      helpText(HTML(
        "<b>What the fields mean</b><br/>
         <b>PR (probability ratio)</b>: how many times more likely an event is
         compared with the early-20th-century baseline.<br/>
         <b>1920→2019</b>: early 20th century vs present climate.<br/>
         <b>1920→2°C</b>: early 20th century vs a +2 °C world.<br/><br/>
         <b>How to interpret</b>: A PR of 4 means '4× more likely'. Lower bounds are conservative."
      )),
      div(class = "download-btn",
          downloadButton("dl", "Download filtered data (.csv)")
      )
    ),
    mainPanel(
      div(class="panel",
          plotOutput("bars", height = 400),
          tags$small(class="muted",
                     HTML('Source: van Oldenborgh et al. (2021). <a href="https://doi.org/10.5194/nhess-21-941-2021" target="_blank">DOI:10.5194/nhess-21-941-2021</a>.')
          ),
          hr(),
          h4("Values table"),
          tableOutput("tbl")
      )
    )
  )
)

server <- function(input, output, session) {
  thematic_shiny()  # NEW: sync ggplot with the Bootstrap theme colors
  
  data_react <- reactive({
    fireRiskR::fwi_pr |>
      filter(scenario == input$scenario)
  })
  
  output$bars <- renderPlot({
    df <- data_react()
    y_bar <- ifelse(is.na(df$pr_best), df$pr_lower, df$pr_best)
    y_err <- ifelse(is.na(df$pr_upper),
                    ifelse(is.na(df$pr_best), df$pr_lower, df$pr_best),
                    df$pr_upper)
    ymax <- max(y_bar, y_err, na.rm = TRUE) * 1.25
    
    ggplot(df, aes(x = source)) +
      geom_col(aes(y = y_bar)) +
      geom_errorbar(aes(ymin = pr_lower, ymax = y_err), width = .2) +
      labs(x = NULL, y = "PR (times more likely)",
           title = paste("FWI probability ratios:", unique(df$scenario))) +
      theme_minimal(base_size = 13) +
      coord_cartesian(ylim = c(0, ymax))
  })
  
  output$tbl <- renderTable({
    data_react() |>
      mutate(
        across(c(pr_lower, pr_best, pr_upper),
               ~ ifelse(is.na(.x), "not reported", .x))
      ) |>
      select(source, pr_lower, pr_best, pr_upper, note)
  }, digits = 2)
  
  output$dl <- downloadHandler(
    filename = function() {
      paste0("fwi_pr_", gsub("\\s+|→|°", "_", input$scenario), ".csv")
    },
    content = function(file) {
      df <- data_react() |>
        dplyr::mutate(
          pr_lower = ifelse(is.na(pr_lower), "not reported", pr_lower),
          pr_best  = ifelse(is.na(pr_best),  "not reported", pr_best),
          pr_upper = ifelse(is.na(pr_upper), "not reported", pr_upper)
        )
      readr::write_excel_csv(df, file, na = "not reported")
    }
  )
}

shinyApp(ui, server)

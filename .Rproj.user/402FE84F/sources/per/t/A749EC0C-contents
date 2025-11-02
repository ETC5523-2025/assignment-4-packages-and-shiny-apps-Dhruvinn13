#' Launch the Shiny app
#'
#' Opens the package's Shiny app for interactive exploration of
#' bushfire risk attribution results.
#'
#' @return No return value; called for side effects.
#' @examples
#' \dontrun{
#'   launch_app()
#' }
#' @export
launch_app <- function() {
  app_dir <- system.file("app", package = "fireRiskR")
  if (app_dir == "") stop("App directory not found. Reinstall the package.", call. = FALSE)
  shiny::runApp(app_dir, launch.browser = TRUE)
}

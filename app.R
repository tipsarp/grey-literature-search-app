library(shiny)
library(DBI)
library(shinyalert) # To display informative dialogue boxes
library(ggplot2) # To visualize your data
library(lubridate) # To work with dates

##### SQLite-related commands ####

# Define the SQL connection
con <- DBI::dbConnect(RSQLite::SQLite(), "newdb.sqlite")
source_df <- dbReadTable(con, "source")
search_df <- dbReadTable(con, "search")
record_df <- dbReadTable(con, "record")
item_df <- dbReadTable(con, "item")

##### Functions #####

# Function to retrieve data from SQLite table
getDataFromSQLite <- function(data = c("source", "search", "record", "item")) {
  query <- paste("SELECT * FROM", data)
  dbGetQuery(con, query)
}

# Function to update the MySQL table with new source
addRowToSource <- function(new_source) {
  query <- "INSERT INTO source (src_id, source_name, organization, tier, entry_url, access_route, date_added, owner) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
  params <- c(new_source$id, new_source$source_name, new_source$organization, new_source$tier, new_source$entry_url, new_source$access_route, new_source$date_added, new_source$owner)
  dbExecute(con, query, params = params)
} 

addRowToSearch <- function(new_search) {
  query <- "INSERT INTO search (sea_id, linked_src_id, search_date, searcher, query_or_navigation_path, filters_and_limits, hits, screened, new_items, notes_and_deviations) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  params <- c(new_search$id, new_search$linked_src_id, new_search$search_date, new_search$searcher, new_search$query_or_navigation_path, new_search$filters_and_limits, new_search$hits, new_search$screened, new_search$new_items, new_search$notes_and_deviations)
  dbExecute(con, query, params = params)
}

addRowToRecord <- function(new_record) {
  query <- "INSERT INTO record (rec_id, linked_sea_id, linked_itm_id, document_title, document_type, publisher, document_date, accessed_date, url, item_as_stated, decision, reason) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  params <- c(new_record$id, new_record$linked_sea_id, new_record$linked_itm_id, new_record$document_title, new_record$document_type, new_record$publisher, new_record$document_date, new_record$accessed_date, new_record$url, new_record$item_as_stated, new_record$decision, new_record$reason)
  dbExecute(con, query, params = params)
}

addRowToItem <- function(new_item) {
  query <- "INSERT INTO item (itm_id, preferred_name, linked_rec_id, aliases, by_organization, status, first_identified, decision, reason, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  params <- c(new_item$id, new_item$preferred_name, new_item$linked_rec_id, new_item$aliases, new_item$by_organization, new_item$status, new_item$first_identified, new_item$decision, new_item$reason, new_item$notes)
  dbExecute(con, query, params = params)
} 


##### UI #####

ui <- fluidPage(
  navlistPanel(
    id = "navlist",
  tabPanel(
      title = "View Data",
      selectInput("selected_table", label = "Select table", choices = c("source", "search","record","item"), selected = ""),
      tableOutput('showtable')
    ),
  "Input new data",
  tabPanel(
      title = "New Source",
      textInput("src_source_name", "Source Name"),
      textInput("src_organization", "Organization"),
      selectInput("src_tier", "Tier", choices = c("Tier 1","Tier 2","Tier 3")),
      textInput("src_entry_url", "Entry URL"),
      textInput("src_access_route", "Access Route"),
      dateInput("src_date_added", "Date Added"),
      textInput("src_owner", "Owner"),
      actionButton("add_source", "Add Source")
    ),
  tabPanel(
      title = "New Search",
      selectInput("sea_linked_src_id", "Linked Source ID", choices = unique(source_df$src_id)),
      dateInput("search_date", "Search Date"),
      textInput("searcher", "Searcher"),
      textInput("query_or_navigation_path", "Query or Navigation Path"),
      textInput("filters_and_limits", "Filters and Limits"),
      numericInput("hits", "Hits", value = 0),
      numericInput("screened", "Screened", value = 0),
      numericInput("new_items", "New Items", value = 0),
      textInput("notes_and_deviations", "Notes and Deviations"),
      actionButton("add_search", "Add Search")),

  tabPanel(
      title = "New Record",
      selectInput("rec_linked_sea_id", "Linked Search ID", choices = unique(search_df$sea_id)),
      selectInput("rec_linked_itm_id", "Linked Item ID", choices = unique(item_df$itm_id)),
      textInput("document_title", "Document Title"),
      textInput("document_type", "Document Type"),
      textInput("publisher", "Publisher"),
      dateInput("document_date", "Document Date"),
      dateInput("accessed_date", "Accessed Date"),
      textInput("url", "URL"),
      textInput("item_as_stated", "Item as Stated"),
      selectInput("rec_decision", "Decision", choices = c("Include", "Exclude")),
      textInput("rec_reason", "Reason"),
      actionButton("add_record", "Add Record")
    ),
  tabPanel(
      title = "New Item",
      textInput("preferred_name", "Preferred Name"),
      selectInput("itm_linked_rec_id", "Linked Record ID", choices = unique(record_df$rec_id)),
      textInput("aliases", "Aliases"),
      textInput("by_organization", "Related Organization"),
      textInput("status", "Status"),
      dateInput("first_identified", "First Identified"),
      textInput("itm_decision", "Decision"),
      textInput("itm_reason", "Reason"),
      textInput("notes", "Notes"),
      actionButton("add_item", "Add Item")
      )
    )
  )


##### Server #####
server <- function(input, output, session) {

  output$showtable <- renderTable({
    getDataFromSQLite(input$selected_table)
  })

  ## Add new source to the database and display a success message
  observeEvent(input$add_source, 
  {
    # Create a new source data frame with the input values
    new_source <- data.frame(
      id = as.character(nrow(source_df) + 1),
      source_name = input$src_source_name,
      organization = input$src_organization,
      tier = input$src_tier,
      entry_url = input$src_entry_url,
      access_route = input$src_access_route,
      date_added = input$src_date_added,
      owner = input$src_owner
    )

    # Add the new source to the database
    addRowToSource(new_source)

    # Open alert box
    shinyalert(title = "New source successfully added!", 
    type = "success")

})

  observeEvent(input$add_search, 
  {
    # Create a new search data frame with the input values
    new_search <- data.frame(
      id = as.character(nrow(search_df) + 1),
      linked_src_id = input$sea_linked_src_id,
      search_date = input$search_date,
      searcher = input$searcher,
      query_or_navigation_path = input$query_or_navigation_path,
      filters_and_limits = input$filters_and_limits,
      hits = input$hits,
      screened = input$screened,
      new_items = input$new_items,
      notes_and_deviations = input$notes_and_deviations
    )

    # Add the new search to the database
    addRowToSearch(new_search)

    # Open alert box
    shinyalert(title = "New search successfully added!", 
    type = "success")

})

  observeEvent(input$add_record, 
  {
    # Create a new record data frame with the input values
    new_record <- data.frame(
      id = as.character(nrow(record_df) + 1),
      linked_sea_id = input$rec_linked_sea_id,
      linked_itm_id = input$rec_linked_itm_id,
      document_title = input$document_title,
      document_type = input$document_type,
      publisher = input$publisher,
      document_date = input$document_date,
      accessed_date = input$accessed_date,
      url = input$url,
      item_as_stated = input$item_as_stated,
      decision = input$rec_decision,
      reason = input$rec_reason
    )

    # Add the new record to the database
    addRowToRecord(new_record)

    # Open alert box
    shinyalert(title = "New record successfully added!", 
    type = "success")

})

  observeEvent(input$add_item, 
  {
    # Create a new item data frame with the input values
    new_item <- data.frame(
      id = as.character(nrow(item_df) + 1),
      preferred_name = input$preferred_name,
      linked_rec_id = input$itm_linked_rec_id,
      aliases = input$aliases,
      by_organization = input$by_organization,
      status = input$status,
      first_identified = input$first_identified,
      decision = input$itm_decision,
      reason = input$itm_reason,
      notes = input$notes
    )

    # Add the new item to the database
    addRowToItem(new_item)

    # Open alert box
    shinyalert(title = "New item successfully added!", 
    type = "success")

})  

observeEvent(input$navlist, {
    if (input$navlist == "View Data") {
      # Refresh the data frames when the user navigates to the "View Data" tab
      source_df <- getDataFromSQLite("source")
      search_df <- getDataFromSQLite("search")
      record_df <- getDataFromSQLite("record")
      item_df <- getDataFromSQLite("item")
    }
  })

# Function to close SQLite connection ####
on.exit(function() {
  dbPoolClose(con)
  dbDisconnect(con)
  })
}
shinyApp(ui, server)

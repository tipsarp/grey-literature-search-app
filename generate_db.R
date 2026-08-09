library(DBI)
library(RSQLite)

item_db <- data.frame(
  itm_id = character(0),
  preferred_name = character(0),
  linked_rec_id = character(0),
  aliases = character(0),
  by_organization = character(0),
  status = character(0),
  first_identified = character(0),
  decision = character(0),
  reason = character(0),
  notes = character(0),
  stringsAsFactors = FALSE
)

source_db <- data.frame(
  src_id = character(0),
  source_name = character(0),
  organization = character(0),
  tier = character(0),
  entry_url = character(0),
  access_route = character(0),
  date_added = character(0),
  owner = character(0),
  stringsAsFactors = FALSE
)

search_db <- data.frame(
  sea_id = character(0),
  linked_src_id = character(0),
  search_date = character(0),
  searcher = character(0),
  query_or_navigation_path = character(0),
  filters_and_limits = character(0),
  hits = character(0),
  screened = character(0),
  new_items = character(0),
  notes_and_deviations = character(0),
  stringsAsFactors = FALSE
)
record_db <- data.frame(
  rec_id = character(0),
  linked_sea_id = character(0),
  linked_itm_id = character(0),
  document_title = character(0),
  document_type = character(0),
  publisher = character(0),
  document_date = character(0),
  accessed_date = character(0),
  url = character(0),
  item_as_stated = character(0),
  decision = character(0),
  reason = character(0),
  stringsAsFactors = FALSE
)

con <- DBI::dbConnect(RSQLite::SQLite(), "newdb.sqlite")
DBI::dbWriteTable(con, "item", item_db, overwrite = TRUE, append = FALSE)
DBI::dbWriteTable(con, "source", source_db, overwrite = TRUE, append = FALSE)
DBI::dbWriteTable(con, "search", search_db, overwrite = TRUE, append = FALSE)
DBI::dbWriteTable(con, "record", record_db, overwrite = TRUE, append = FALSE)

dbDisconnect(con)

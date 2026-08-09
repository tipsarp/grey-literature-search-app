Date created: August 10, 2026

# What is this?
- This is essentially an R Shiny App that provides a (hopefully) user friendly interface for data entry
- This app is meant to be used to document Grey Literature Searches for a Scoping Review that I am leading
- The app is connected to a SQLite database with four tables (Source, Search, Record, Item)

# Why was this app created?
- I recently attended a workshop which highlighted importance of documenting grey literature searches (for reproducibility!)
- Ben Haycroft of the National University of Singapore who gave the talk also provided us attendees with Excel sheets to document our searches (which the database in this app is modified from)
- I plan to use this documentation process in an upcoming scoping review.
- So, this is the perfect opportunity to improve the UX/UI of the documentation form, brush up on `Shiny`, AND learn `SQL`

# How to use this app?
- The `generate_db.R` file is used to generate an empty database to start
- Then, 

## Resources used to buikd the app?
- ["Tutorial: Build your own data collection app in R"](https://www.sebastianvanbaalen.se/uploads/tutorial-data-collection-app#step-3-specifying-the-server-logic) by Sebastian van Baalen
- [Mastering Shiny](https://mastering-shiny.org/index.html) by Hadley Wickham

## Future updates ?
- Plan to add helper notes using `library(shinyhelper)` ... eventually
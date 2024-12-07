# load necessary libraries
library(tidyverse) # for general coding
library(rvest) # for web scraping

# determine year of new results
year <- year(today())

# store number of winners for every category in every ceremony in winners_count
winners_count <- NULL

# get url of each page
oscars_url <- str_c("https://www.oscars.org/oscars/ceremonies/", as.character(year))
# scrape list of categories, winners, and nominees from each page
awards_text <- oscars_url |>
  read_html() |>
  html_nodes(css = "#view-by-category-pane .field__item") |>
  html_text()
  
# remove excessive whitespace from resulting text
awards_text <- str_replace_all(awards_text, "\\n", "") |> str_squish()
  
# count number of winners in each category at that ceremony
winners_count <- str_count(awards_text, "Winner")
winners_count_remove <- str_detect(str_sub(awards_text, start=1, end=3), "Win")
winners_count <- winners_count[!winners_count_remove]
winners_count <- winners_count[winners_count>0]
  
# count total number of awards given at that ceremony
num_awards <- length(winners_count)

# store category name, winner(s), nominees for all awards
awards <- rep(NA, num_awards)
# store number of nominees for all awards in nominees_count
nominees_count <- NULL

# save info about each individual award as a separate item in awards vector
start_index <- 1
for(i in 1:num_awards){
  # count number of nominees for each award
  nom_count <- str_count(awards_text[start_index], "Nominees")
  
  # determine start and end indices for text of each award
  start_index <- start_index + 1
  end_index <- start_index + (3*nom_count) + (3*winners_count[i])
  
  # store all text and number of nominees for each award
  this_category <- list(awards_text[start_index:end_index])
  awards[i] <- this_category
  nominees_count <- c(nominees_count, nom_count)
  start_index <- end_index + 1
}

# count total number of winners, nominees, and winners and nominees
num_winners <- cumsum(winners_count)[num_awards]
num_nominees <- cumsum(nominees_count)[num_awards]
num_winnoms <- num_winners + num_nominees

# store all years, categories, films, winners, and nominees for all awards
years <- rep(year, num_winnoms)
cat_names <- rep(NA, num_winnoms)
film_names <- rep(NA, num_winnoms)
nom_names <- rep(NA, num_winnoms)
won01 <- rep(0, num_winnoms)

# for all awards, extract information and save it in the appropriate vector
# i represents each of the awards
# j represents the line of text associated with each of the awards
# k represents an individual row in the eventual dataframe, where every nominee has 1 row
k <- 1
for(i in 1:num_awards){
  # reset winners_added to 0 because no winners have been recorded for the ith award yet
  winners_added <- 0
  j <- 2
  
  # while there are more lines to examine in the text associated with the ith award
  while(j < length(awards[[i]])){
    
    # note the category of the award
    cat_names[k] <- awards[[i]][1]
    
    # if the jth line of text contains only a film name or nominee name
    if(is.na(awards[[i]][j]) |
       str_detect(awards[[i]][j], "Winner", negate = TRUE) &
       str_detect(awards[[i]][j], "Nominees", negate = TRUE)){
      
      # extract the film name and nominee name
      if(str_detect(cat_names[k], "Actor") |
         str_detect(cat_names[k], "Actress")){
        # nominee first then movie
        nom_names[k] <- awards[[i]][j]
        film_names[k] <- awards[[i]][j+1]
      } else {
        # movie first then nominee
        film_names[k] <- awards[[i]][j]
        nom_names[k] <- awards[[i]][j+1]
      }
      
      # determine whether this film and nominee won the award or not
      if(winners_added < winners_count[i]){
        won01[k] <- 1
        winners_added <- winners_added + 1
      }
      
      # move to the next lines of text and the next row in the dataframe
      j <- j + 2
      k <- k + 1
      
      # if the jth line of text isn't only a film or nominee name, move on  
    } else {
      j <- j + 1
    }
  }
}

# determine IDs for each row in new dataframe based on last existing row number
old_data <- read.csv("oscars-data.csv")
last_id <- nrow(old_data)
ids <- seq(last_id+1, last_id+num_winnoms)

# build dataframe with all info
new_data <- tibble(id = ids,
                   year = years,
                   category = cat_names,
                   film = film_names,
                   nominee = nom_names,
                   won = won01)

# standardize category names
new_data <- new_data |>
  mutate(category = case_when(
    category == "Production Design" ~ "Art Direction",
    category == "Honorary Award" | category == "Special Achievement Award" ~ "Special Award",
    TRUE ~ as.character(category)
  ))

# update csv to contain all data
oscars_data <- rbind(old_data, new_data)
write_csv(oscars_data, "oscars-data.csv")

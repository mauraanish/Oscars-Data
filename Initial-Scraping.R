# load necessary libraries
library(tidyverse) # for general coding
library(polite) # for checking website scrapability
library(rvest) # for web scraping

# check if URL is scrapable
bow("https://www.oscars.org/oscars/ceremonies/2024")
# Output: <polite session> https://www.oscars.org/oscars/ceremonies/2024
#    User-agent: polite R package
#    robots.txt: 1 rules are defined for 1 bots
#   Crawl delay: 5 sec
#  The path is scrapable for this user-agent

# store all information for every category in every ceremony in awards_text
awards_text <- NULL
# store number of awards given at each ceremony in awards_count
awards_count <- NULL
# store number of winners for every category in every ceremony in winners_count
winners_count <- NULL

# loop through all 96 ceremonies' information
for (year in 1929:2024) {
  # wait 10 seconds between scraping each page
  Sys.sleep(10) 
  
  # get url of each page
  oscars_url <- str_c("https://www.oscars.org/oscars/ceremonies/", as.character(year))
  # scrape list of categories, winners, and nominees from each page
  awards <- oscars_url |>
    read_html() |>
    html_nodes(css = "#view-by-category-pane .field__item") |>
    html_text()
  
  # remove excessive whitespace from resulting text
  awards <- str_replace_all(awards, "\\n", "") |> str_squish()
  
  # count number of winners in each category at that ceremony
  win_counts <- str_count(awards, "Winner")
  win_counts_remove <- str_detect(str_sub(awards, start=1, end=3), "Win")
  win_counts <- win_counts[!win_counts_remove]
  win_counts <- win_counts[win_counts>0]
  
  # count total number of awards given at that ceremony
  num_cats <- length(win_counts)
  
  # add new information to ongoing lists
  awards_text <- c(awards_text, awards)
  awards_count <- c(awards_count, num_cats)
  winners_count <- c(winners_count, win_counts)
}

# view some of the results stored after scraping
length(awards_text) 
# Output: 36493
awards_text[1:13]
# Output: 
# [1] "Actor Winner Emil Jannings The Last Command Winner Emil Jannings The Way of All Flesh Nominees Richard Barthelmess The Noose Nominees Richard Barthelmess The Patent Leather Kid"
# [2] "Actor"                                                                                                                                                                           
# [3] "Winner Emil Jannings The Last Command"                                                                                                                                           
# [4] "Emil Jannings"                                                                                                                                                                   
# [5] "The Last Command"                                                                                                                                                                
# [6] "Winner Emil Jannings The Way of All Flesh"                                                                                                                                       
# [7] "Emil Jannings"                                                                                                                                                                   
# [8] "The Way of All Flesh"                                                                                                                                                            
# [9] "Nominees Richard Barthelmess The Noose"                                                                                                                                          
# [10] "Richard Barthelmess"                                                                                                                                                             
# [11] "The Noose"                                                                                                                                                                       
# [12] "Nominees Richard Barthelmess The Patent Leather Kid"                                                                                                                             
# [13] "Richard Barthelmess"
length(awards_count)
# Output: 96
awards_count
# Output: [1] 13  7  8  9 12 13 16 17 21 22 20 22 22 25 25 25 25 25 25 25 28 27 28 28 28 27 28 27 29 21 24 26 27 28 26 27 27 28
#        [39] 28 25 24 23 24 22 23 23 23 25 23 26 23 25 21 25 25 24 25 24 24 24 24 24 24 24 24 24 25 25 25 24 25 24 24 25 24 24
#        [77] 25 24 25 24 25 25 25 25 25 24 24 24 24 24 24 24 23 23 23 23
length(winners_count)
# Output: 2262
winners_count[1:13]
# Output: [1] 2 3 2 2 1 1 1 1 2 1 1 1 1

# save scraped text as a CSV
write_csv(awards_text, "awards_text.csv")

# read data back in after manually adding NA values and movie titles where needed
awards_text <- read_csv("awards_text.csv")
awards_text <- awards_text$awards_text

# total number of awards in dataset = 2262
num_awards <- length(winners_count)

# store category name, winner(s), nominees for all 2262 awards in awards
awards <- rep(NA, num_awards)
# store number of nominees for all 2262 awards in nominees_count
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

# view some of the results
length(awards)
# Output: 2262
awards[1]
# Output: 
# [[1]]
#  [1] "Actor"                                               "Winner Emil Jannings The Last Command"              
#  [3] "Emil Jannings"                                       "The Last Command"                                   
#  [5] "Winner Emil Jannings The Way of All Flesh"           "Emil Jannings"                                      
#  [7] "The Way of All Flesh"                                "Nominees Richard Barthelmess The Noose"             
#  [9] "Richard Barthelmess"                                 "The Noose"                                          
# [11] "Nominees Richard Barthelmess The Patent Leather Kid" "Richard Barthelmess"                                
# [13] "The Patent Leather Kid"  
length(nominees_count)
# Output: 2262
nominees_count[1:13]
# Output: [1] 2 2 2 3 1 2 2 2 0 2 2 1 2

# count total number of winners, nominees, and winners and nominees
num_winners <- cumsum(winners_count)[2262]
num_nominees <- cumsum(nominees_count)[2262]
num_winnoms <- num_winners + num_nominees

# make a list of the years in which every award was given
year_counts <- rep(1929:2024, awards_count)

# store all years, categories, films, winners, and nominees for all 2262 awards
years <- rep(0, num_winnoms)
cat_names <- rep(NA, num_winnoms)
film_names <- rep(NA, num_winnoms)
nom_names <- rep(NA, num_winnoms)
won01 <- rep(0, num_winnoms)

# for all awards, extract information and save it in the appropriate vector
# i represents each of the 2262 awards
# j represents the line of text associated with each of the awards
# k represents an individual row in the eventual dataframe, where every nominee has 1 row
k <- 1
for(i in 1:num_awards){
  # reset winners_added to 0 because no winners have been recorded for the ith award yet
  winners_added <- 0
  j <- 2
  
  # while there are more lines to examine in the text associated with the ith award
  while(j < length(awards[[i]])){
    
    # note the year and category of the award
    years[k] <- year_counts[i]
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

# view some of the results
length(years)
# Output: 10695
years[1:10]
# Output: [1] 1929 1929 1929 1929 1929 1929 1929 1929 1929 1929
length(cat_names)
# Output: 10695
cat_names[1:10]
# Output: [1] "Actor"         "Actor"         "Actor"         "Actor"         "Actress"       "Actress"       "Actress"      
#         [8] "Actress"       "Actress"       "Art Direction"
length(film_names)
# Output: 10695
film_names[1:10]
# Output: [1] "The Last Command"       "The Way of All Flesh"   "The Noose"              "The Patent Leather Kid"
#         [5] "7th Heaven"             "Street Angel"           "Sunrise"                "A Ship Comes In"       
#         [9] "Sadie Thompson"         "The Dove"
length(nom_names)
# Output: 10695
nom_names[1:10]
# Output: [1] "Emil Jannings"           "Emil Jannings"           "Richard Barthelmess"     "Richard Barthelmess"    
#         [5] "Janet Gaynor"            "Janet Gaynor"            "Janet Gaynor"            "Louise Dresser"         
#         [9] "Gloria Swanson"          "William Cameron Menzies"
length(won01)
# Output: 10695
won01[1:10]
# Output: [1] 1 1 0 0 1 1 1 0 0 1

# build dataframe with all info
oscars_data <- tibble(year = years,
                      category = cat_names,
                      film = film_names,
                      nominee = nom_names,
                      won = won01)

# view dimensions and first 5 rows of dataframe
dim(oscars_data)
# Output: 10695 x 5
head(oscars_data)
# Output:
# A tibble: 6 × 5
#    year category                  film                   nominee               won
#   <dbl> <chr>                     <chr>                  <chr>               <dbl>
# 1  1929 Actor in a Leading Role   The Last Command       Emil Jannings           1
# 2  1929 Actor in a Leading Role   The Way of All Flesh   Emil Jannings           1
# 3  1929 Actor in a Leading Role   The Noose              Richard Barthelmess     0
# 4  1929 Actor in a Leading Role   The Patent Leather Kid Richard Barthelmess     0
# 5  1929 Actress in a Leading Role 7th Heaven             Janet Gaynor            1
# 6  1929 Actress in a Leading Role Street Angel           Janet Gaynor            1

# examine all different category names
table(oscars_data$category)
# Actor                       Actor in a Leading Role               Actor in a Supporting Role
# 236                         240                                   440
# Actress                     Actress in a Leading Role             Actress in a Supporting Role
# 239                         240                                   440
# Animated Feature Film       Animated Short Film                   Assistant Director
# 99                          5                                     35
# Art Direction               Art Direction (Black-and-White)       Art Direction (Color)
# 309                         136                                   112 
# Best Motion Picture         Best Picture                          Dance Direction
# 90                          371                                   27
# Cinematography              Cinematography (Black-and-White)      Cinematography (Color)
# 341                         152                                   131 
# Costume Design              Costume Design (Black-and-White)      Costume Design (Color)
# 295                         77                                    77 
# Directing                   Directing (Comedy Picture)            Directing (Dramatic Picture)
# 471                         2                                     3
# Documentary                 Documentary (Feature)                 Documentary (Short Subject) 
# 25                          340                                   364
# Documentary Feature Film    Documentary Short Film                Engineering Effects 
# 10                          10                                    3
# Film Editing                Foreign Language Film                 Honorary Award
# 450                         314                                   6
# Honorary Foreign Language Film Award                              International Feature Film
# 5                                                                 25 
# Irving G. Thalberg Memorial Award                                 Jean Hersholt Humanitarian Award
# 44                                                                35 
# Live Action Short Film      Makeup                                Makeup and Hairstyling 
# 5                           87                                    46 
# Music (Adaptation Score)    Music (Music Score—substantially original)
# 3                           20
# Music (Music Score of a Dramatic or Comedy Picture)               Music (Music Score of a Dramatic Picture)
# 147                                                               20 
# Music (Original Dramatic Score)                                   Music (Original Music Score)
# 40                                                                10 
# Music (Original Musical or Comedy Score)                          Music (Original Score—for a motion picture [not a musical])
# 20                                                                10 
# Music (Original Score)      Music (Original Song Score and Its Adaptation -or- Adaptation Score)
# 270                         6 
# Music (Original Song Score and Its Adaptation or Adaptation Score)Music (Original Song Score or Adaptation Score)
# 6                                                                 3 
# Music (Original Song Score) Music (Original Song)                 Music (Score of a Musical Picture—original or adaptation)
# 8                           234                                   10 
# Music (Scoring of a Musical Picture)                              Music (Scoring of Music—adaptation or treatment)
# 127                                                               30 
# Music (Scoring)             Music (Scoring: Adaptation and Original Song Score)
# 64                          8 
# Music (Scoring: Original Song Score and Adaptation -or- Scoring: Adaptation) 
# 9
# Music (Song—Original for the Picture)                             Music (Song)
# 25                                                                215
# Outstanding Motion Picture  Outstanding Picture                   Outstanding Production
# 30                          8                                     102 
# Production Design           Short Film (Animated)                 Short Film (Dramatic Live Action)
# 60                          210                                   3 
# Short Film (Live Action)    Short Subject (Animated)              Short Subject (Cartoon)
# 220                         9                                     168 
# Short Subject (Color)       Short Subject (Comedy)                Short Subject (Live Action)
# 6                           12                                    68 
# Short Subject (Novelty)     Short Subject (One-reel)              Short Subject (Two-reel)
# 12                          90                                    81 
# Sound                       Sound Editing                         Sound Effects
# 245                         86                                    10 
# Sound Effects Editing       Sound Mixing                          Sound Recording
# 47                          85                                    195 
# Special Achievement Award   Special Achievement Award (Sound Editing)
# 3                           1
# Special Achievement Award (Sound Effects Editing)                 Special Achievement Award (Sound Effects)
# 4                                                                 1 
# Special Achievement Award (Visual Effects)                        Special Award
# 9                                                                 20 
# Special Effects             Special Foreign Language Film Award   Special Visual Effects
# 92                          2                                     16 
# Unique and Artistic Picture Visual Effects                        Writing
# 3                           155                                   16 
# Writing (Adaptation)        Writing (Adapted Screenplay)          Writing (Motion Picture Story)
# 17                          110                                   48 
# Writing (Original Motion Picture Story)                           Writing (Original Screenplay)
# 25                                                                160 
# Writing (Original Story)    Writing (Screenplay—Adapted)          Writing (Screenplay—based on material from another medium)
# 52                          5                                     95 
# Writing (Screenplay—Original)                                     Writing (Screenplay Adapted from Other Material)
# 5                                                                 10 
# Writing (Screenplay Based on Material from Another Medium)        Writing (Screenplay Based on Material Previously Produced or Published)
# 65                                                                55 
# Writing (Screenplay Written Directly for the Screen—based on factual material or on story material not previously published or produced)
# 10 
# Writing (Screenplay Written Directly for the Screen)              Writing (Screenplay)
# 120                                                               104
# Writing (Story and Screenplay—based on factual material or material not previously published or produced) 
# 20 
# Writing (Story and Screenplay—based on material not previously published or produced) 
# 5 
# Writing (Story and Screenplay—written directly for the screen)    Writing (Story and Screenplay)
# 60                                                                35 
# Writing (Title Writing) 
# 3 

# standardize category names
oscars_data <- oscars_data |>
  mutate(category = case_when(
    category == "Actor" ~ "Actor in a Leading Role", category == "Actress" ~ "Actress in a Leading Role",
    category == "Art Direction (Black-and-White)" | category == "Art Direction (Color)" | category == "Production Design" ~ "Art Direction",
    category == "Cinematography (Black-and-White)" | category == "Cinematography (Color)" ~ "Cinematography",
    category == "Costume Design (Black-and-White)" | category == "Costume Design (Color)" ~ "Costume Design",
    category == "Directing (Comedy Picture)" | category == "Directing (Dramatic Picture)" ~ "Directing",
    category == "Documentary" | category == "Documentary (Feature)" ~ "Documentary Feature Film",
    category == "Documentary (Short Subject)" ~ "Documentary Short Film",
    category %in% c("Engineering Effects", "Special Effects", "Special Visual Effects", 
                    "Special Achievement Award (Visual Effects)") ~ "Visual Effects",
    category == "Foreign Language Film" | category == "Special Foreign Language Film Award" | 
      category == "Honorary Foreign Language Film Award" ~ "International Feature Film",
    category == "Makeup" ~ "Makeup and Hairstyling",
    category %in% c("Music (Adaptation Score)", 
                    "Music (Music Score—substantially original)", 
                    "Music (Music Score of a Dramatic or Comedy Picture)", 
                    "Music (Music Score of a Dramatic Picture)", 
                    "Music (Original Dramatic Score)", 
                    "Music (Original Music Score)", 
                    "Music (Original Musical or Comedy Score)", 
                    "Music (Original Score—for a motion picture [not a musical])", 
                    "Music (Original Song Score and Its Adaptation -or- Adaptation Score)", 
                    "Music (Original Song Score and Its Adaptation or Adaptation Score)", 
                    "Music (Original Song Score or Adaptation Score)", 
                    "Music (Original Song Score)", 
                    "Music (Score of a Musical Picture—original or adaptation)", 
                    "Music (Scoring of a Musical Picture)", 
                    "Music (Scoring of Music—adaptation or treatment)", 
                    "Music (Scoring)", 
                    "Music (Scoring: Adaptation and Original Song Score)", 
                    "Music (Scoring: Original Song Score and Adaptation -or- Scoring: Adaptation)") ~ "Music (Original Score)",
    category == "Music (Song—Original for the Picture)" | category == "Music (Song)" ~ "Music (Original Song)",
    category %in% c("Best Motion Picture", "Outstanding Motion Picture", 
                    "Outstanding Picture", "Unique and Artistic Picture",
                    "Outstanding Production") ~ "Best Picture",
    category %in% c("Short Film (Animated)", "Short Subject (Animated)", "Short Subject (Cartoon)") ~ "Animated Short Film",
    category %in% c("Short Film (Dramatic Live Action)", "Short Film (Live Action)", "Short Subject (Live Action)") ~ "Live Action Short Film",
    category %in% c("Short Subject (Color)", "Short Subject (Comedy)", 
                    "Short Subject (Novelty)", "Short Subject (One-reel)", 
                    "Short Subject (Two-reel)") ~ "Short Film",
    category %in% c("Sound Editing", "Sound Effects", "Sound Effects Editing", 
                    "Sound Mixing", "Sound Recording", 
                    "Special Achievement Award (Sound Editing)", 
                    "Special Achievement Award (Sound Effects Editing)", 
                    "Special Achievement Award (Sound Effects)") ~ "Sound",
    category %in% c("Writing (Motion Picture Story)", "Writing (Screenplay)",
                    "Writing (Story and Screenplay)", "Writing (Title Writing)") ~ "Writing",
    category %in% c("Writing (Adaptation)", "Writing (Screenplay—Adapted)", 
                    "Writing (Screenplay—based on material from another medium)", 
                    "Writing (Screenplay Adapted from Other Material)", 
                    "Writing (Screenplay Based on Material from Another Medium)", 
                    "Writing (Screenplay Based on Material Previously Produced or Published)") ~ "Writing (Adapted Screenplay)",
    category %in% c("Writing (Original Motion Picture Story)", 
                    "Writing (Original Story)", "Writing (Screenplay—Original)", 
                    "Writing (Screenplay Written Directly for the Screen—based on factual material or on story material not previously published or produced)", 
                    "Writing (Screenplay Written Directly for the Screen)", 
                    "Writing (Story and Screenplay—based on factual material or material not previously published or produced)", 
                    "Writing (Story and Screenplay—based on material not previously published or produced)", 
                    "Writing (Story and Screenplay—written directly for the screen)") ~ "Writing (Original Screenplay)", 
    category == "Honorary Award" | category == "Special Achievement Award" ~ "Special Award",
    TRUE ~ as.character(category)
  ))

# examine new category names
table(oscars_data$category)
# Actor in a Leading Role          Actor in a Supporting Role         Actress in a Leading Role 
# 476                              440                                479 
# Actress in a Supporting Role     Animated Feature Film              Animated Short Film 
# 440                              99                                 392
# Art Direction                    Assistant Director                 Best Picture 
# 617                              35                                 604 
# Cinematography                   Costume Design                     Dance Direction
# 624                              449                                27
# Directing                        Documentary Feature Film           Documentary Short Film 
# 476                              375                                374
# Film Editing                     International Feature Film         Irving G. Thalberg Memorial Award 
# 450                              346                                44 
# Jean Hersholt Humanitarian Award Live Action Short Film             Makeup and Hairstyling
# 35                               296                                133
# Music (Original Score)           Music (Original Song)              Short Film
# 811                              474                                201 
# Sound                            Special Award                      Visual Effects
# 674                              29                                 275
# Writing                          Writing (Adapted Screenplay)       Writing (Original Screenplay)
# 206                              357                                457 

# save finalized df as csv
# write_csv(oscars_data, "oscars-data.csv")

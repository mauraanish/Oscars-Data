# Oscars-Data
For my final project for my DACSS 690A: Data Engineering course, taught by Dr. Tyler Horan at UMass Amherst, I wanted to re-create and expand upon the functionality of the [Academy Awards Database](https://awardsdatabase.oscars.org/). To do so, I extracted data from the Oscars website, stored it in a table, and created a Flask app which users can interact with to see information and visualizations about the awards.

### Files
This repository contains 6 files:
- Initial-Scraping.R: the R code used to scrape all of the data currently available on the Oscars website
- awards_text.csv: the initial results from scraping, before data transformation
- oscars-data.csv: the transformed data in a dataframe with 6 columns (ID, year, category, film, nominee, won)
- app.py: the Python code used to create the Flask app
- awards.db: the database containing the transformed data, built using SQLAlchemy in the Flask app
- Yearly-Update-Scraping.R: the R code used to scrape a new ceremony's data from the Oscars website 

### Extraction
Using the rvest library in R, data was scraped from all 96 webpages on the [Oscars website](https://www.oscars.org/oscars/ceremonies/1929) that contain information about the winners and nominees for all awards from each ceremony from 1929 through 2024. 
Upon scraping, the data was (mostly) in the form of a list of character vectors with the following structure, as seen in awards_text.csv:
- \[Name of Category] Winner \[Name of Winning Movie] \[Name of Winner] Nominees \[Name of First Nominated Movie] \[Name of First Nominee] ... Nominees \[Name of Last Nominated Movie] \[Name of Last Nominee]
- \[Name of Category]
- Winner \[Name of Winning Movie] \[Name of Winner]
- \[Name of Winning Movie]
- \[Name of Winner]
- Nominees \[Name of First Nominated Movie] \[Name of First Nominee]
- \[Name of First Nominated Movie]
- \[Name of First Nominee]
- ...
- Nominees \[Name of Last Nominated Movie] \[Name of Last Nominee]
- \[Name of Last Nominated Movie]
- \[Name of Last Nominee]

Given the unfriendly initial structure of the data, transformation was required to extract the names of the category, winner, nominees, and films for each award.

### Transformation
Due to the non-systemic nature of some of the formatting variations in the data, I made some manual alterations to the data in Microsoft Excel. For example, some awards were only attached to a nominee, not a particular film, so I added NA values in place of those film titles. Some awards consistently followed this pattern, such as the Irving G. Thalberg Memorial Award and Jean Hersholt Humanitarian Award, while other awards like the Sound and Assistant Director awards only occasionally followed this pattern. Furthermore, there were some instances in which awards like the International Feature Film and Short Film categories only listed a nominated country or individual but not the film they were nominated for, so I used the Internet to discover which film names should be inserted for those awards. Similarly, some Special Awards were only given to films, without being attached to any individuals, so NA values were necessary in place of the individual nominees' names there, too./ 
Once all of the data was in a consistent format, I was able to use the information I calculated about the number of winners and number of nominees for each award to build a dataframe. Some awards didn't have any nominees, other awards had multiple winners, and most awards had varying numbers of nominees, so the number of winners and nominees was necessary to know for each individual award. Eventually, the data was transformed such that each row represented one winner or nominee for one film for one award in one year. Each row can contain multiple winners or nominees if all of those people were nominated/won the same award for the same film. This doesn't apply to acting awards, but in almost all other categories, multiple people are associated with the writing, composing, or even directing for films./ 
Finally, with the dataframe built, I reduced the number of categories from 115 to 22 by grouping together very similar categories that had just changed in name over the years. This dataframe was saved as oscars-data.csv and was loaded into the Python app. The app further transformed the data by storing it in a table called 'award' in the database called 'awards' using Pandas and SQLAlchemy. 

### Loading
The awards.db file was then drawn from to allow user interaction with the Flask app.

### Automation
The data only needs to be updated once a year, towards the end of March, after each additional Oscars Ceremony. The yearly update code is quite similar to the initial scraping code, except it doesn't require as much storage or adjustment of award category names to reflect the changes over time. The only necessary information from the existing dataframe containing all past years' data is the last ID used, so as to start the ID values for the new rows appropriately. Depending on whether the Academy alters category names, adds new categories, or changes the format in which they store information about each category on their website in the coming years, the yearly update code may need to be modified accordingly. However, assuming that the structure of the data remains the same, the oscars-data.csv will be updated yearly, so the Flask app can continue to pull in the most current data.

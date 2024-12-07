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
Upon scraping, the data was in the form of a list of character vectors with the following structure, as seen in awards_text.csv:
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

### Loading

### Automation
The data only needs to be updated once a year, towards the end of March, after each additional Oscars Ceremony. The yearly update code is quite similar to the initial scraping code, except it doesn't require as much storage or adjustment of award category names to reflect the changes over time. The only necessary information from the existing dataframe containing all past years' data is the last ID used, so as to start the ID values for the new rows appropriately. Depending on whether the Academy alters category names, adds new categories, or changes the format in which they store information about each category on their website in the coming years, the yearly update code may need to be modified accordingly. However, assuming that the structure of the data remains the same, the oscars-data.csv will be updated yearly, so the Flask app can continue to pull in the most current data.

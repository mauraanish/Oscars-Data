# Oscars-Data
For my final project for my DACSS 690A: Data Engineering course, taught by Dr. Tyler Horan at UMass Amherst, I wanted to re-create and expand upon the functionality of the [Academy Awards Database](https://awardsdatabase.oscars.org/). To do so, I extracted data from the Oscars website, stored it in a table, and created a Flask app which users can interact with to see information and visualizations about the awards.

### Files
This repository contains 5 files:
- Initial-Scraping.R: the R code used to scrape all of the data currently available on the Oscars website
- awards_text.csv: the initial results from scraping, before data transformation
- oscars-data.csv: the transformed data in a dataframe with 6 columns (ID, year, category, film, nominee, won)
- app.py: the Python code used to create the Flask app
- awards.db: the database containing the transformed data, built using SQLAlchemy in the Flask app
- Yearly-Update-Scraping.R: the R code used to scrape a new ceremony's data from the Oscars website 

### Extraction

### Transformation

### Loading

### Automation
The data only needs to be updated once a year, towards the end of March, after each additional Oscars Ceremony. The yearly update code is quite similar to the initial scraping code, except it doesn't require as much storage or adjustment of award category names to reflect the changes over time. The only necessary information from the existing dataframe containing all past years' data is the last ID used, so as to start the ID values for the new rows appropriately. Depending on whether the Academy alters category names, adds new categories, or changes the format in which they store information about each category on their website in the coming years, the yearly update code may need to be modified accordingly.

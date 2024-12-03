# Oscars-Data
For my final project for my DACSS 690A: Data Engineering course, taught by Professor Tyler Horan at UMass Amherst, I wanted to re-create and expand upon the functionality of the [Academy Awards Database](https://awardsdatabase.oscars.org/). To do so, I extracted data from the Oscars' website, stored it in a table, and created a Flask app which users can interact with to see information and visualizations about the awards.

### Files
This repository contains 4 files:
- Initial-Scraping.R: the R code used to scrape all of the data currently available on the Oscar's website
- awards_text.csv: the initial results from scraping, before data transformation
- oscars-data.csv: the transformed data in a dataframe with 6 columns (ID, year, category, film, nominee, won)
- app.py: the Python code used to create the Flask app 

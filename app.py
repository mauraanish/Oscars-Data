# import necessary libraries
from flask import Flask, request, render_template
from flask_sqlalchemy import SQLAlchemy
import pandas as pd
import pytest

# create app
app = Flask(__name__)

# create SQLite database called awards using SQLAlchemy
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///awards.db'
db = SQLAlchemy(app)

# set up table schema
class Award(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  year = db.Column(db.Integer, nullable=False, unique=False)
  category = db.Column(db.String(35), nullable=False, unique=False)
  film = db.Column(db.String(130), nullable=True, unique=False)
  nominee = db.Column(db.String(210), nullable=True, unique=False)
  won = db.Column(db.Integer, nullable=False, unique=False)
  
# create the database
with app.app_context():
  db.create_all()

# load data into awards database
def load_data():
  # clear database
  db.session.query(Award).delete()
  
  # load the data into the database
  awards = pd.read_csv("oscars-data.csv", encoding='latin-1')
  awards = awards[['id', 'year', 'category', 'film', 'nominee', 'won']]
  for _, row in awards.iterrows():
    new_award = Award(
      id = int(row['id']),
      year = int(row['year']),
      category = row['category'],
      film = row['film'],
      nominee = row['nominee'],
      won = int(row['won'])
    )
    db.session.add(new_award)
  db.session.commit()    
 
# route to homepage
@app.route('/')
def homepage():
  load_data()
  return render_template('prompt.html')

# generate stats for specific year
def year_stats(user_year):
  user_year = int(user_year)
  assert user_year >= 1929 and user_year <= 2024
  this_year = db.session.execute(db.select(Award).where(Award.year==user_year)).scalars()
  return this_year

# generate stats for specific category
def cat_stats(user_cat):
  if user_cat == 'Picture':
    user_cat = 'Best Picture'
  elif user_cat == 'Actor':
    user_cat = 'Actor in a Leading Role'
  elif user_cat == 'Supporting Actor':
    user_cat = 'Actor in a Supporting Role'
  elif user_cat == 'Actress':
    user_cat = 'Actress in a Leading Role'
  elif user_cat == 'Supporting Actress':
    user_cat = 'Actress in a Supporting Role'
  elif user_cat == 'Director':
    user_cat = 'Directing'
  elif user_cat == 'Costumes':
    user_cat = 'Costume Design'
  elif user_cat == 'Dance':
    user_cat = 'Dance Direction'
  elif user_cat == 'Documentary Feature':
    user_cat = 'Documentary Feature Film'
  elif user_cat == 'Documentary Short':
    user_cat = 'Documentary Short Film'
  elif user_cat == 'Editing':
    user_cat = 'Film Editing'
  elif user_cat == 'International Feature':
    user_cat = 'International Feature Film'
  elif user_cat == 'Animated Feature':
    user_cat = 'Animated Feature Film'
  elif user_cat == 'Animated Short':
    user_cat = 'Animated Short Film'
  elif user_cat == 'Live Action Short':
    user_cat = 'Live Action Short Film'
  elif user_cat == 'Short':
    user_cat = 'Short Film'
  elif user_cat == 'Makeup':
    user_cat = 'Makeup and Hairstyling'
  elif user_cat == 'Production Design':
    user_cat = 'Art Direction'
  elif user_cat == 'Score':
    user_cat = 'Music (Original Score)'
  elif user_cat == 'Song':
    user_cat = 'Music (Original Song)'
  elif user_cat == 'Adapted Writing':
    user_cat = 'Writing (Adapted Screeplay)'
  elif user_cat == 'Original Writing':
    user_cat = 'Writing (Original Screenplay)'
  elif user_cat != 'Assistant Director' and user_cat != 'Cinematography' and user_cat != 'Sound' and user_cat != 'Visual Effects' and user_cat != 'Writing' and user_cat != 'Special Award' and user_cat != 'Irving G. Thalberg Memorial Award' and user_cat != 'Jean Hersholt Humanitarian Award':
    # invalid category entered, throw error
  this_cat = db.session.execute(db.select(Award).where(Award.category==user_cat)).scalars()
  return this_cat

# generate stats for specific film
def film_stats(user_film):
  # throw error if invalid film name entered
  this_film = db.session.execute(db.select(Award).where(Award.film==user_film)).scalars()
  return this_film

# generate stats for specific nominee
def nom_stats(user_nom):
  # throw error if invalid nominee name entered
  this_nom = db.session.execute(db.select(Award).where(Award.nominee.contains(user_nom))).scalars()
  return this_nom

# route to display results
@app.route('/display')
def display():
  user_year = request.args.get('year_entry', '')
  user_cat = request.args.get('cat_entry', '')
  user_film = request.args.get('film_entry', '')
  user_nom = request.args.get('nom_entry', '')
  if len(user_year)>0:
    results = year_stats(user_year)
  elif len(user_cat)>0:
    results = cat_stats(user_cat)
  elif len(user_film)>0:
    results = film_stats(user_film)
  elif len(user_nom)>0:
    results = nom_stats(user_nom)
  else:
    return "Please enter information in one of the above fields."
  return render_template('results.html', results=results)  

# run app
if __name__ == '__main__':
  app.run()

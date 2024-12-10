# import necessary libraries
from flask import Flask, request, render_template
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import func
import pandas as pd

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
  this_year = db.session.execute(db.select(Award.year, Award.category, Award.film, Award.nominee, Award.won).where(Award.year==user_year))
  return this_year

# generate stats for specific category
def cat_stats(user_cat):
  this_cat = db.session.execute(db.select(Award.year, Award.category, Award.film, Award.nominee, Award.won).where(Award.category==user_cat))
  return this_cat

# generate stats for specific film
def film_stats(user_film):
  this_film = db.session.execute(db.select(Award.year, Award.category, Award.film, Award.nominee, Award.won).where(Award.film==user_film))
  # calculate number of awards the film won and lost
  wonlost = [0, 0]
  wonlost[0] = db.session.execute(db.select(func.count('*')).where(Award.film==user_film).where(Award.won==1)).scalar()
  wonlost[1] = db.session.execute(db.select(func.count('*')).where(Award.film==user_film).where(Award.won==0)).scalar()
  return this_film, wonlost

# generate stats for specific nominee
def nom_stats(user_nom):
  this_nom = db.session.execute(db.select(Award.year, Award.category, Award.film, Award.nominee, Award.won).where(Award.nominee.contains(user_nom)))
  # calculate number of awards the nominee won and lost
  wonlost = [0, 0]
  wonlost[0] = db.session.execute(db.select(func.count('*')).where(Award.nominee.contains(user_nom)).where(Award.won==1)).scalar()
  wonlost[1] = db.session.execute(db.select(func.count('*')).where(Award.nominee.contains(user_nom)).where(Award.won==0)).scalar()
  return this_nom, wonlost

# route to display results
@app.route('/display')
def display():
  user_year = request.args.get('year_entry', '')
  user_cat = request.args.get('cat_entry', '')
  user_film = request.args.get('film_entry', '')
  user_nom = request.args.get('nom_entry', '')
  if len(user_year)>0:
    results = year_stats(user_year)
    return render_template('results.html', results=results) 
  elif len(user_cat)>0:
    results = cat_stats(user_cat)
    return render_template('results.html', results=results) 
  elif len(user_film)>0:
    results, wonlost = film_stats(user_film)
    return render_template('results_graph.html', results=results, data=wonlost) 
  elif len(user_nom)>0:
    results, wonlost = nom_stats(user_nom)
    return render_template('results_graph.html', results=results, data=wonlost) 
  else:
    return "Please enter information in one of the above fields."  

# run app
if __name__ == '__main__':
  app.run()

# import necessary libraries
from flask import Flask
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

# route to homepage
@app.route('/')
def homepage():
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
  
  return "It's working!"  

# run app
if __name__ == '__main__':
  app.run()
  
# unit tests
#with app.app_context():
#  def test_query_all_awards(test_client):
#    awards = Awards.query.all()
#    assert len(awards) == 10695

from flask import Flask, request, Response, render_template
import json
import logging
import random
import pandas
import numpy as np


app = Flask(__name__)

centroid_df = pandas.read_excel('~/Desktop/CreationSpace/5G_AI_Innovation/front_end_browser/cellular_centroids.xlsx')
initial_df = pandas.read_excel('~/Desktop/CreationSpace/5G_AI_Innovation/front_end_browser/user_initial.xls')

@app.route('/')
def home():

    # Heatmap data: 156 Point
  data = dict.fromkeys(range(1, centroid_df.shape[0]))

  for i in range(1, centroid_df.shape[0]+1):
      data[i] = []
      data[i].append(centroid_df.iloc[i-1]["latitude"])
      data[i].append(centroid_df.iloc[i-1]["longitude"])
      data[i].append(100 * random.uniform(0, 1))
    
  l = len(data.keys())
  

  return render_template('heatmap.html', co_data = data, co_lenth = l)



  #export FLASK_APP=heatmap_data.py
  #flask run --host=0.0.0.0 --port=5005

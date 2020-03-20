
from flask import Flask, request, Response, render_template
import json
import logging
import random

app = Flask(__name__)

@app.route('/')
def home():

    # Heatmap data: 500 Points
    def getPoints():
        return {
          1: [37.8726, -122.2607, 100 * random.uniform(0, 1)],
          2: [37.8692, -122.2597, 100 * random.uniform(0, 1)],
          3: [37.8703, -122.2581, 100 * random.uniform(0, 1)],
          4: [37.8752, -122.2615, 100 * random.uniform(0, 1)],
          5: [37.8756, -122.2588, 100 * random.uniform(0, 1)],
          6: [37.8753, -122.256, 100 * random.uniform(0, 1)],
        }

    data = getPoints()

    l = len(data.keys())

    return render_template('heatmap.html', co_data = data, co_lenth = l)

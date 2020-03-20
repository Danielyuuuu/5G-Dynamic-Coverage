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
          7: [37.871716, -122.264999, 100 * random.uniform(0, 1)],
          8: [37.8704, -122.2661, 100 * random.uniform(0, 1)],
          9: [37.8762, -122.2611, 100 * random.uniform(0, 1)],
          10: [37.8710, -122.2554, 100 * random.uniform(0, 1)],
          11: [37.8723, -122.2545, 100 * random.uniform(0, 1)],
          12: [37.8707, -122.2508, 100 * random.uniform(0, 1)],
          13: [37.8686, -122.2628, 100 * random.uniform(0, 1)],
          14: [37.8677, -122.2643, 100 * random.uniform(0, 1)],
        }

    data = getPoints()

    l = len(data.keys())

    return render_template('heatmap.html', co_data = data, co_lenth = l)
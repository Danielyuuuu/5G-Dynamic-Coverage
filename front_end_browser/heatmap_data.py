from flask import Flask, request, Response, render_template
import json
import logging

app = Flask(__name__)

@app.route('/')
def home():

    # Heatmap data: 500 Points
    def getPoints():
        return {
          1: [37.8726, -122.2607],
          2: [37.8692, -122.2597],
          3: [37.8703, -122.2581],
          4: [37.8752, -122.2615],
          5: [37.8756, -122.2588],
          6: [37.8753, -122.256],
          7: [37.871716, -122.264999],
        }

    data = getPoints()

    l = len(data.keys())

    return render_template('heatmap.html', co_data = data, co_lenth = l)
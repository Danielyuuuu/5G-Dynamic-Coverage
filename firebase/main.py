
from flask import Flask, request, Response, render_template
import json
import logging
import random
import numpy as np

import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

cred = credentials.Certificate("../admin key/dynamic-deployment-firebase-adminsdk-nx8lh-0a96741e77.json")

default_app = firebase_admin.initialize_app(cred, {'databaseURL': "https://dynamic-deployment.firebaseio.com/"})

ref = db.reference('testData/')

app = Flask(__name__)

db = np.array(ref.get())

def getPoints(offset=0):
        d = db[-1-offset]
        return {i+1:d[i].tolist() for i in range(d.shape[0])}
    
@app.route('/')
def home():
    data = getPoints()

    l = len(data.keys())
    
    return render_template('heatmap.html', co_data = data, co_lenth = l)

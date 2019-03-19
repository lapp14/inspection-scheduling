
from datetime import date
import scheduling
from flask import Flask, request, jsonify

# allow cross origin for dev purposes
from flask_cors import CORS
app = Flask(__name__)
CORS(app)

"""REST api endpoint for completion. Returns a JSON object
    representing the completion of a set of facilities
"""
@app.route("/completion/", methods=['GET'])
def completion():
	year 	    = request.args.get('year', 	      default = date.today().year,  type = int)
	category    = request.args.get('category',    default = '', type = str)
	fac_type    = request.args.get('factype',     default = '', type = str)
	inspector   = request.args.get('inspector',   default = '', type = str)
	seasonality = request.args.get('seasonality', default = '', type = str)

	# 3 = High, 2 = Moderate, 1 = Low, 0 = Unassessed, -1 = All
	risk = request.args.get('risk', default = -1, type = int)
	top  = request.args.get('top',  default = -1, type = int)

	completion = scheduling.calculate_completion(year, category, fac_type, inspector, risk, seasonality, top)
	
	return jsonify(completion)




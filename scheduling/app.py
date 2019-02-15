
import datetime
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
	year 	 = request.args.get('year', 	default = 2018,  type = int)
	category = request.args.get('category', default = 'All', type = str)

	completion = scheduling.calculate_completion(year, category)
	
	return jsonify(completion)




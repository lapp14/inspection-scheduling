
import datetime
import inspection_scheduling as scheduling
from flask import Flask, request, jsonify

# allow cross origin for dev purposes
from flask_cors import CORS
app = Flask(__name__)
CORS(app)

"""REST api endpoint for completion. Returns a JSON object
    representing the completion of a set of facilities
"""
@app.route("/completion/", methods=['GET', 'POST'])
def completion():	
	year = request.args.get('year', default = 2018, type = int)

	try:		
		completion = scheduling.calculate_completion(year)
	except:
		print('request /completion/ failed: ' + now.strftime("%Y-%m-%d %H:%M"))
		return jsonify({'error': 'server error'}), 500
	
	return jsonify(completion)




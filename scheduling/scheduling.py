from flask_cors import CORS

import os, sys, datetime, traceback
import math
import pandas as pd
import pyodbc
import json

from flask import Flask, request, jsonify

import config

app = Flask(__name__)

# allow cross origin for dev purposes
CORS(app) 


sql_conn = pyodbc.connect(config.SQL_CONNECTION_STRING)

@app.route("/completion/", methods=['GET', 'POST'])
def completion():
	now = datetime.datetime.now()
	print('request completion, starting: ' + now.strftime("%Y-%m-%d %H:%M"))
	
	year = request.args.get('year', default = 2018, type = int)

	try:
		f = get_facilities(year)
		completion = calculate_completion(f, year)
	except:
		print('request failed: ' + now.strftime("%Y-%m-%d %H:%M"))
		return jsonify({'error': 'server error'}), 500
	
	print('request completion, finishing: ' + now.strftime("%Y-%m-%d %H:%M"))
	return jsonify(completion)

def execute_query(query):	
	try:
		result = pd.read_sql(query, sql_conn).head(10).to_dict(orient='records')
	except Exception as err:
		result = jsonify({'error': 'error'})
		traceback.print_tb(err.__traceback__)

	return result
	
def get_facilities(year):
	query = "EXEC [sp_schedulingFacilityOverview] @YEAR = {}".format(year)
	result = execute_query(query)
	
	if not isinstance(result, (list,)):
		print('ERROR: get_facilities failed')
		raise
	
	return result
	
def get_facility_inspections(facId, year):
	query = "EXEC [sp_schedulingQueryInspections] @FACILITY_ID = '{}', @YEAR = {}".format(facId, year)
	return execute_query(query)

def calculate_completion(dict, year):
	num_intervals = 0
	num_intervals_complete = 0
	num_inspections = 0

	for row in dict:
		#calculate seasonality
		if row['Seasonality'] == 'Seasonal':
			months = []
			
			monthFrom = int(row['OperatingSchedule_FromMonthOfYear']) - 1
			monthTo   = int(row['OperatingSchedule_ToMonthOfYear'])
			
			if monthFrom > monthTo:
				monthTo += 12
				
			for x in range(monthFrom, monthTo):
				i = (x % 12) + 1            
				months.append(i)
			
			row['MonthsOpen'] = months
		else:
			row['MonthsOpen'] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

		
		monthsOpen = row['MonthsOpen'];  
		row['InspectionIntervals'] = []
		freq = row['Freq']
		
		if freq < 30:
			freq = 360
		
		months            = freq / 30
		intervals         = math.ceil(len(row['MonthsOpen']) / months)
		monthsPerInterval = math.floor(len(row['MonthsOpen']) / intervals)
		facId             = row['FacilityId']
		
		ins = get_facility_inspections(facId, year)

		try:
			length = len(ins)
		except:
			length = 0

		num_inspections += length

		for x in range(intervals):
			num_intervals = num_intervals + 1
			row['InspectionIntervals'].append({
				'Complete': False,
				'Months': [],
				'Inspections': [],
			})

			for y in range(monthsPerInterval):
				i = y + (x * monthsPerInterval)

				if(i >= len(monthsOpen)):
					break

				interval = row['InspectionIntervals'][x]
				interval['Months'].append(monthsOpen[i])
		 
			for y in ins:
				#put the inspections into right interval
				if y['Month'] in row['InspectionIntervals'][x]['Months']:
					row['InspectionIntervals'][x]['Inspections'].append(y)
					
					if y['IsCompliance'] is True:
						row['InspectionIntervals'][x]['Complete'] = True
						num_intervals_complete = num_intervals_complete + 1
			
	
	return { 
		'Meta': {
			'Year':				   year,
			'DateGenerated':	   datetime.datetime.now(),
			'InspectionIntervals': num_intervals,
			'CompletedIntervals':  num_intervals_complete,
			'CompletionRate':	   (num_intervals_complete / num_intervals * 100),
			'Inspections':		   num_inspections
		},
		'Facilities': dict 
	}
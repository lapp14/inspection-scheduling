import os, sys, datetime, traceback, math, pyodbc, json, pandas as pd
from flask import Flask, request, jsonify

import config
sql_conn = None


"""Establish connection to the SQL Server database"""
def connect():
	print('reconnecting')	
	try:
		global sql_conn
		sql_conn = pyodbc.connect(config.SQL_CONNECTION_STRING)
	except Exception as err:
		traceback.print_tb(err.__traceback__)


"""Executes a sql statement through an active `sql_conn` to the SQL Server database
    Returns a DataFrame with results
"""
def execute_query(query):
	for retry in range(3):
		try:
			result = pd.read_sql(query, sql_conn)
			return result
		except Exception as err:
			print('execute_query failed')
			connect()
			
	print(traceback.print_tb(err.__traceback__))
	return jsonify({'error': 'execute_query failed max number of times'})


""" Executes the schedulingFacilityOverview stored procedure.
     Returns a <dict> of Facility objects
"""
def get_facilities(year):
	query = "EXEC [sp_schedulingFacilityOverview] @YEAR = {}".format(year)
	result = execute_query(query).head(10).to_dict(orient='records')
	
	if not isinstance(result, (list,)):
		print('ERROR: get_facilities failed')
		raise
	
	return result
 

""" Executes the schedulingQueryInspections stored procedure. Returns all inspections
	 for the specified facility ID for specified year.
	 Returns a <dict> of Inspection objects
"""	
def get_facility_inspections(facId, year):
	query = "EXEC [sp_schedulingQueryInspections] @FACILITY_ID = '{}', @YEAR = {}".format(facId, year)
	return execute_query(query).to_dict(orient='records')
 

""" Calculates the completion rate for a set of facilities. Splits the months open for each facility
	 into a number of "inspection intervals" and places the inspections within each interval.
	 Returns a <dict> of facilities with completion rates and metadata
"""
def calculate_completion(year):
	dict = get_facilities(year)

	num_intervals = 0
	num_intervals_complete = 0
	num_inspections = 0

	for row in dict:
		facility_calculate_seasonality(row)
		
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


""" Calculate months open for a Facility and adds all open months to MonthsOpen property. 
	 Pass a Facility object
"""
def facility_calculate_seasonality(facility):
	#calculate seasonality
	if facility['Seasonality'] == 'Seasonal':
		months = []		
		monthFrom = int(facility['OperatingSchedule_FromMonthOfYear']) - 1
		monthTo   = int(facility['OperatingSchedule_ToMonthOfYear'])
		
		if monthFrom > monthTo:
			monthTo += 12
			
		for x in range(monthFrom, monthTo):
			i = (x % 12) + 1            
			months.append(i)
		
		facility['MonthsOpen'] = months
	else:
		facility['MonthsOpen'] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
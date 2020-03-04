from credentials import *
import requests
import csv

class API(object):
	def __init__(self, url, username, password):
		self.url = url
		self.username = username
		self.password = password

	def get(self, path, **kwargs):
		response = requests.get(self.url + path, auth=(self.username, self.password), params=kwargs)
		if response.status_code == 200:
			return response.json()
		else:
			raise Exception('API returned response code {}. {}'.format(response.status_code, response.json()['api.responseText']))

	def post(self, path, **kwargs):
		response = requests.post(self.url + path, auth=(self.username, self.password), params=kwargs)
		if response.status_code == 200:
			return response.json()
		else:
			raise Exception('API returned response code {}. {}'.format(response.status_code, response.json()['api.responseText']))

def combine_codes(lst):
	return [item['code'] for item in lst]

class DataBase(object):
	def __init__(self, api, db):
		self.api = api
		self.db_name = db
		info = self.info()['db']
		self.countries = info['countries']
		self.variables = info['variables']
		self.periods = info['periods']
		self.sectors = info['isics']
 
	def info(self):
		return self.api.get('/dbinfo/{}'.format(self.db_name))

	def get(self, **parameters):
		parameters['db'] = self.db_name 
		return self.api.post('/dbdata', **parameters)

	def get_country_variable(self, country, variable, start, end):
		return self.get(cc = country, 
			isic = combine_codes(self.sectors),
			variable = variable,
			start = start, 
			end = end)['data']

class DataStore(object):
	def __init__(self, keys):
		self.keys = keys
		self.payload = {}

	def push(self, row):
		key = tuple([row[k] for k in self.keys])
		self.payload[key] = row

	def push_rows(self, rows):
		for row in rows:
			self.push(row)

if __name__ == '__main__':
	unido = API(url, username, password)
	db = DataBase(unido, 'INDSTAT 2 2019, ISIC Revision 3')

	variables = dict(gross_output='14', value_added='20')

	country_output = csv.DictWriter(open('country.csv', 'wt'), fieldnames=['code', 'name'])
	country_output.writeheader()

	for country in db.countries:
		country_output.writerow(country)

	for variable in variables:
		data = DataStore(keys=['country', 'isic', 'year'])
		output = csv.DictWriter(open('{}.csv'.format(variable), 'wt'), fieldnames=['country', 'isic', 'year', 'value', 'isicComb', 'variable'])
		output.writeheader()

		for country in db.countries:
			data.push_rows(db.get_country_variable(country=country['code'], variable=variables[variable], start=2010, end=2017))

		for row in data.payload:
			output.writerow(data.payload[row])
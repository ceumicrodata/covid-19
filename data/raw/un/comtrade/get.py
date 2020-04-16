from credentials import *
import requests
import csv
import sys
import json
import codecs

class API(object):
	def __init__(self, url, key):
		self.url = url
		self.api_key = key

	def get(self, path, **kwargs):
		kwargs['token'] = self.api_key
		response = requests.get(self.url + path, params=kwargs)
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
	codes = dict(reporter = 'r',
		partner = 'p',
		period = 'ps',
		classification = 'px',
		product = 'cc',
		type = 'type')

	def __init__(self, api, classification='S4'):
		self.api = api
		self.classification = classification
		self.type = 'C'

	def get(self, **parameters):
		query = {}
		for key in parameters:
			query[DataBase.codes[key]] = parameters[key]

		return self.api.get('/get', **query)['dataset']

class Writer(object):
	'''
	A CSV dictwriter that automatically creates header row on the fly.
	'''

	def __init__(self, file):
		self.file = file
		self.writer = None

	def write(self, row):
		if self.writer:
			self.writer.writerow(row)
		else:
			header = [str(i) for i in row.keys()]
			self.writer = csv.DictWriter(self.file, fieldnames=header)
			self.writer.writeheader()

def read_unido_countries(fname):
	countries = []
	for row in csv.DictReader(open(fname, 'rt')):
		if row['country'] not in countries:
			countries.append(row['country'])
	return countries

def get_year(db, countries, year):
	'''
	Generator for all bilateral pairs of trade data in a given year.
	'''
	for reporter in countries:
		# add World as partner
		for partner in countries + ['0']:
			data = db.get(reporter=reporter, partner=partner, 
				classification='S4', product='AG3', period=year)
			for row in data:
				yield row

if __name__ == '__main__':
	comtrade = API(URL, API_KEY)
	db = DataBase(comtrade, classification='S4')

	year = sys.argv[1].split('.')[0]

	countries = read_unido_countries('../../unido/indstat2/unido.csv')
	columns = 'period rgCode rtCode ptCode cmdCode TradeValue'.split()

	print('Downloading data for {}.'.format(year))
	writer = Writer(open('{}.csv'.format(year), 'wt'))
	for row in get_year(db, countries, year):
		writer.write({k: row[k] for k in row if str(k) in columns})

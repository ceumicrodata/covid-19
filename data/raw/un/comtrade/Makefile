years: 2010.csv 2011.csv 2012.csv 2013.csv 2014.csv 2015.csv 2016.csv 2017.csv 2018.csv
%.csv: get.py
	python3 get.py $@
ReporterAreas.json:
	curl https://comtrade.un.org/Data/cache/reporterAreas.json > $@

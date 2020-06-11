from credentials import *
import requests
import csv
import sys
import json
import codecs
import time
import random
import pandas as pd


class API(object):
    def __init__(self, url, key, countries):
        self.url = url
        self.api_key = key
        self.log = "error_log.txt"
        self.countries = countries

    def get(self, path, **kwargs):
        # print(kwargs)
        kwargs["token"] = self.api_key
        time.sleep(random.randint(5, 10))
        response = requests.get(self.url + path, params=kwargs)
        if response.status_code == 200:
            try:
                return response.json()
            except error as e:
                print("api get error ", e)
        else:
            print("Error " + response.status_code + "\n", response.request.url)
            raise Exception(
                "API returned response code {}. {}".format(
                    response.status_code, response.json()["api.responseText"]
                )
            )

    def post(self, path, **kwargs):
        response = requests.post(
            self.url + path, auth=(self.username, self.password), params=kwargs
        )
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(
                "API returned response code {}. {}".format(
                    response.status_code, response.json()["api.responseText"]
                )
            )


def combine_codes(lst):
    return [item["code"] for item in lst]


class DataBase(object):
    codes = dict(
        reporter="r",
        partner="p",
        period="ps",
        classification="px",
        product="cc",
        type="type",
    )

    def __init__(self, api, classification="S4"):
        self.api = api
        self.classification = classification
        self.type = "C"

    def get(self, **parameters):
        query = {}
        for key in parameters:
            query[DataBase.codes[key]] = parameters[key]
        try:
            return self.api.get("/get/plus", **query)["dataset"]

        except:
            return []


class Writer(object):
    """
    A CSV dictwriter that automatically creates header row on the fly.
    """

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
    for row in csv.DictReader(open(fname, "rt")):
        if row["country"] not in countries:
            countries.append(row["country"])

    un_cm=pd.read_csv("country_convert_w_diff.csv")
    correct=un_cm.loc[(un_cm.unido_code.isin(countries))&\
    (un_cm.unido_code==un_cm.ct_code),]

    miss=[x for x in countries if x not in list(correct.unido_code)]


    final=un_cm.loc[(un_cm.unido_code.isin(countries))&\
    (un_cm.unido_code==un_cm.ct_code)|un_cm.unido_code.isin(miss),]

    return [str(int(x)) for x in final.ct_code]


def get_year(db, countries, year):
    """
    Generator for all bilateral pairs of trade data in a given year.
    """
    for reporter in countries:
        # add World as partner
        data = db.get(
            reporter=reporter,
            partner=",".join(countries + ["0"]),
            classification="S4",
            product="AG3",
            period=year,
        )
        if len(data) > 0:
            for row in data:
                yield row
        elif len(data) == 0:
            print("starting problematic download ", reporter, " in ", year)
            parts = chunkIt(countries + ["0"], 10)
            data2 = []
            for partner in parts:
                data2 = db.get(
                    reporter=reporter,
                    partner=",".join(partner),
                    classification="S4",
                    product="AG3",
                    period=year,
                )
                if len(data2)>0:
                    data+=data2
                else:
                    for p in partner:
                        print("Getting country pair: ",reporter," and ",p," in ",year)
                        data_pair=db.get(
                            reporter=reporter,
                            partner=p,
                            classification="S4",
                            product="AG3",
                            period=year,
                        )
                    if len(data_pair)>0:
                        print("Done with downloading ", reporter, " in ", year)
                        data2+=data_pair
                if len(data2)>0:
                    data+=data2
                else:                   
                    print("Error: no dataset in response")
                    print("Error with ", reporter, " ", year)
                    with open(db.api.log, "a") as log:
                        log.write(",".join([reporter,year]) + "\n")
                        log.close()
            
            
            for row in data:
                yield row
        else:
            print("Error (unknown), ",reporter," in ",year)


def chunkIt(seq, num):
    avg = len(seq) / float(num)
    out = []
    last = 0.0
    while last < len(seq):
        out.append(seq[int(last) : int(last + avg)])
        last += avg
    return out


if __name__ == "__main__":
    countries = read_unido_countries("../../unido/indstat2/unido.csv")
    comtrade = API(URL, API_KEY, countries)
    db = DataBase(comtrade, classification="S4")

    year = sys.argv[1].split(".")[0]

    columns = "period rgCode rtCode ptCode cmdCode TradeValue".split()

    print("Downloading data for {}.".format(year))
    writer = Writer(open("{}.csv".format(year), "wt"))
    for row in get_year(db, countries, year):
        writer.write({k: row[k] for k in row if str(k) in columns})


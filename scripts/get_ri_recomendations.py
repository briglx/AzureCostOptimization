#!/usr/bin/python

import sys
import requests
import datetime
import time
import json
import csv

HOST_NAME = 'https://consumption.azure.com'
API_PATH = '/v2/enrollments/%s/SharedReservationRecommendations?lookBackPeriod=%s'


def getUri(eid, lookBackPeriod):
    path_url = HOST_NAME + API_PATH
    uri = (path_url % (eid, lookBackPeriod))
    return uri


def getLastWeekUri(eid):
    lookBackPeriod = '7'
    return getUri(eid, lookBackPeriod)


def getLast30DaysUri(eid):
    lookBackPeriod = '30'
    return getUri(eid, lookBackPeriod)


def getMostDataUri(eid):
    lookBackPeriod = '60'
    return getUri(eid, lookBackPeriod)


def getRecomendations(uri, auth_key):

    print("Calling uri " + uri)

    headers = {
        "authorization": "bearer " + str(auth_key),
        "Content-Type": "application/json"}

    resp = requests.get(
        uri,
        headers=headers,
    )
    print(resp)

    data = json.loads(resp.content)

    header = list(data[0].keys())[1:-1]

    with open('ri_recommendations.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=',')

        writer.writerows([header])

        for d in data:

            row = [d.get(key) for key in header]
            writer.writerows([row])


def main(argv):

    eid = argv[0]
    auth_key = argv[1]

    uri = getMostDataUri(eid)
    getRecomendations(uri, auth_key)


if __name__ == "__main__":
    main(sys.argv[1:])

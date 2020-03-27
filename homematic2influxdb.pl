#!/usr/bin/python3
import configparser
import sys
import xml.etree.ElementTree as ET
import urllib.request
import datetime
import time
from influxdb import InfluxDBClient


config = configparser.ConfigParser()
config.read('settings.cfg')


# Initialize InfluxDB
try:
    client = InfluxDBClient(host=config['influxdb']['host'], port=config['influxdb']['port'])
    client.create_database(config['influxdb']['database'])
except:
    print("Error: Unable to connect to InfluxDB")
    sys.exit(2)

# Initialize Homematic
try:
    url = 'http://'+config['homematic']['host']+'/addons/xmlapi/statelist.cgi'
    response = urllib.request.urlopen(url).read()
except:
    print("Error: Unable to connect to Homematic")
    sys.exit(2)


# Validate input as value
def isValidValue(string):
    try:
        float(string)
        return True
    except ValueError:
        return False


tree = ET.fromstring(response)

dataitems = []
# Walk all devices
for device in tree.findall('device'):
    device_name = device.get('name')

    # Walk all channels
    for channel in device.findall('channel'):
        channel_name = channel.get('name')

        # Walk all datapoints and parse data
        for datapoint in channel.findall('datapoint'):

            # Convert input epoch as timestamp
            srcts = datetime.datetime.fromtimestamp(int(datapoint.get('timestamp')))
            ts = int(time.mktime(srcts.timetuple())* 1000)


            # prepare influx entry
            if (isValidValue(datapoint.get('value'))):
                dataitems.append("{measurement},device={device},datapoint={datapoint},channel={channel},datapointtype={datapoint_type} value={value} {timestamp}"
                    .format(
                        measurement=config['influxdb']['measurement'],
                        device=device_name.replace(" ","\ "),
                        channel=channel_name.replace(" ","\ "),
                        datapoint=datapoint.get('name').replace(" ","\ "),
                        datapoint_type=datapoint.get('type').replace(" ","\ "),
                        value_type=datapoint.get('valuetype').replace(" ","\ "),
                        value=float(datapoint.get('value')),
                        timestamp=ts
                        )
                    )

    
try:
    client.write_points(dataitems, database=config['influxdb']['database'], time_precision='ms', batch_size=1000, protocol='line')
except:
    print("Error: Unable to write data into InfluxDB")
    sys.exit(2)   


print("Success! {rows} datapoints written to InfluxDB".format(rows=len(dataitems)))        
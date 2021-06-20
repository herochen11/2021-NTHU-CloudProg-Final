# Receive the requests from Service Provider and assign truck for delivery

import json
import time
import threading
import random
import boto3

from uuid import uuid4
from awscrt import io, mqtt, auth, http
from awsiot import mqtt_connection_builder, iotshadow
from concurrent.futures import Future

# AWS SNS
sns_client = boto3.client('sns', 'us-east-1')
# AWS IoT Core
iot_client = boto3.client('iot-data', 'us-east-1')

# Define ENDPOINT, CLIENT_ID, PATH_TO_CERT, PATH_TO_KEY, PATH_TO_ROOT, MESSAGE, TOPIC, and RANGE
ENDPOINT = "a1wn4qi9a26ti-ats.iot.us-east-1.amazonaws.com"
CLIENT_ID = "testDevice"
PATH_TO_CERT = "./5888a20553-certificate.pem.crt"
PATH_TO_KEY = "./5888a20553-private.pem.key"
PATH_TO_ROOT = "./RootCA1.pem"
MESSAGE = "Hello World"
TOPIC = "test/testing"
THING_NAME="final_test"
SHADOW_NAME="final"
def trace_sensor_state():
    topic_arn = 'arn:aws:sns:us-east-1:378130993847:test'
    while True:
        response = iot_client.get_thing_shadow(thingName=THING_NAME,shadowName=SHADOW_NAME)
        sensor_state = json.load(response['payload'])
        reported = sensor_state['state']['reported']
        heart_beat_rate= int(reported['BMP'])
        bearing = float(reported['Bearing'])
        print(' heart beat rate: {}, gas_sensor: {}'.format(str(heart_beat_rate), str(bearing)))
        
        if  heart_beat_rate < 0 and bearing < 180.0 :	
            # Publish to sns to report abnormal state
            msg = 'The sensor on detected abnormal environment.'
            sns_client.publish(TopicArn=topic_arn, Message=msg)
            time.sleep(10)
        time.sleep(1)   

if __name__ == '__main__':
    
    trace = threading.Thread(target=trace_sensor_state,args=())
    trace.daemon = True
    trace.start()
    while True:
        time.sleep(1)   
    

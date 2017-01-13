import RPi.GPIO as GPIO
import time
import requests
import json

GPIO.setmode(GPIO.BCM)

GPIO.setup(18, GPIO.IN, pull_up_down=GPIO.PUD_UP)

n=0
while True:
    input_state = GPIO.input(18)
    if input_state == False:
        print('Button Pressed')
        n=n+1
        payload = {'message': 'Button Pressed','attempt':n}
        print requests.post('http://harvest.soracom.io', data=json.dumps(payload))
        time.sleep(0.2)

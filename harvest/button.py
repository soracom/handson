# -*- coding: utf-8 -*-
import RPi.GPIO as GPIO
import time
import requests
# GPIO の初期設定
button_pin = 18	# GPIO 18 にボタンを接続
GPIO.setmode(GPIO.BCM)
GPIO.setup(button_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)

n=0 # 押された回数をリセット
while True:
	input_state = GPIO.input(button_pin) # ピンの状態を読み取る
	if input_state == False:             # 押されると 0v (False) になる
		n=n+1
		print 'ボタンが押されました！ (%s 回目)' % n
		data = '{"message":"Button Pressed!", "attempt": %d}' % n
		print requests.post('http://harvest.soracom.io', data=data) # POST
	time.sleep(0.1)

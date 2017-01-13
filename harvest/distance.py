#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import time
import requests
import json

# 距離を読む関数
def read_distance():
    # 必要なライブラリのインポート・設定
    import RPi.GPIO as GPIO

    # 使用するピンの設定
    GPIO.setmode(GPIO.BOARD)
    TRIG = 11 # ボード上の11番ピン(GPIO17)
    ECHO = 13 # ボード上の13番ピン(GPIO27)

    # ピンのモードをそれぞれ出力用と入力用に設定
    GPIO.setup(TRIG,GPIO.OUT)
    GPIO.setup(ECHO,GPIO.IN)
    GPIO.output(TRIG, GPIO.LOW)

    # TRIG に短いパルスを送る
    GPIO.output(TRIG, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(TRIG, GPIO.LOW)

    # ECHO ピンがHIGHになるのを待つ
    signaloff = time.time()
    while GPIO.input(ECHO) == GPIO.LOW:
        signaloff = time.time()

    # ECHO ピンがLOWになるのを待つ
    signalon = signaloff
    while time.time() < signaloff + 0.1:
        if GPIO.input(ECHO) == GPIO.LOW:
            signalon = time.time()
            break

    # GPIO を初期化しておく
    GPIO.cleanup()

    # 時刻の差から、物体までの往復の時間を求め、距離を計算する
    timepassed = signalon - signaloff
    distance = timepassed * 17000

    # 500cm 以上の場合はノイズと判断する
    if distance <= 500:
        return distance
    else:
        return None

# 第一引数を interval に設定
interval=5 if len(sys.argv)==1 else int(sys.argv[1])

while True:
    start_time = time.time()
    distance = read_distance()
    if distance:
        print "%.1f cm" % (distance)
        headers = {'Content-Type': 'application/json'}
        payload = {'distance': round(distance*10)/10 }
        print requests.post('http://harvest.soracom.io', data=json.dumps(payload), headers=headers)

    # １秒間に１回実行するためのウェイトを入れる
    wait = start_time + interval - start_time
    if wait > 0:
        time.sleep(wait)

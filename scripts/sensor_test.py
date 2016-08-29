#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 距離を読む関数
def read_distance():
    # 必要なライブラリのインポート・設定
    import time
    import RPi.GPIO as GPIO
    GPIO.setwarnings(False)

    # 使用するピンの設定
    GPIO.setmode(GPIO.BOARD)
    TRIG = 11 # ボード上の11番ピン(GPIO17)
    ECHO = 13 # ボード上の13番ピン(GPIO27)

    # ピンのモードをそれぞれ出力用と入力用に設定
    GPIO.setup(TRIG,GPIO.OUT)
    GPIO.setup(ECHO,GPIO.IN)
    GPIO.output(TRIG, GPIO.LOW)
    time.sleep(0.3)

    # TRIGに短いパルスを送る
    GPIO.output(TRIG, GPIO.HIGH)
    time.sleep(0.000011)
    GPIO.output(TRIG, GPIO.LOW)

    # ECHO ピンがHIGHになるのを待つ
    while GPIO.input(ECHO) == GPIO.LOW:
        signaloff = time.time()

    # ECHO ピンがLOWになるのを待つ
    while GPIO.input(ECHO) == GPIO.HIGH:
        signalon = time.time()

    # 時刻の差から、物体までの往復の時間を求め、距離を計算する
    timepassed = signalon - signaloff
    distance = timepassed * 17000
    GPIO.cleanup()
    return distance

while True:
  print "距離: %.1f cm" % (read_distance())

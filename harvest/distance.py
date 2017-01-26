#!/usr/bin/env python
# -*- coding: utf-8 -*-
import time

# 距離を読む関数
def read_distance():
    # 必要なライブラリのインポート・設定
    import RPi.GPIO as GPIO
    GPIO.setwarnings(False)

    # 使用するピンの設定
    GPIO.setmode(GPIO.BCM)
    TRIG = 17 # ボード上の11番ピン(GPIO17)
    ECHO = 27 # ボード上の13番ピン(GPIO27)

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

    # 時刻の差から、物体までの往復の時間を求め、距離を計算する
    timepassed = signalon - signaloff
    distance = timepassed * 17000

    # 500cm 以上の場合はノイズと判断する
    if distance <= 500:
        return distance
    else:
        return None

# 直接実行した時にだけ実行される
if __name__ == '__main__':
	while True:
		start_time = time.time()
		distance = read_distance()
		if distance:
			print "距離: %.1f cm" % (distance)

	   # １秒間に１回実行するためのウェイトを入れる
		wait = start_time + 1 - start_time
		if wait > 0:
			time.sleep(wait)

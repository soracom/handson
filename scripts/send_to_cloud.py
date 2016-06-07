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
    time.sleep(0.00001)
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
    return distance
    GPIO.cleanup()

# IMSIの取得
import requests
import json

print "- メタデータサービスにアクセスして IMSI を確認中 ...",
subscriber=json.loads(requests.get('http://metadata.soracom.io/v1/subscriber').text)
imsi = subscriber['imsi']
print imsi

# 閾値の設定: 距離 10cm 以内が３回続いた場合にイベント
threshold_distance = 10
threshold_count = 3
status = 'out' # 何もない時は out 、何かある時は in
duration = 0
count = 0

print "- 条件設定"
print "障害物を %d cm 以内に %d 回検知したらクラウドにデータを送信します" % (threshold_distance, threshold_count )
print "センサーを手で遮ったり、何か物を置いてみたりしてみましょう"

import time
status_changed_at = time.time()

import datetime
from elasticsearch import Elasticsearch
es = Elasticsearch('beam.soracom.io:18080')

print "- 準備完了"

while True:
    distance = read_distance() # 距離の取得

    if status == 'out':
        if distance <= threshold_distance:
            count+=1
            print "距離(cm): %.1f <= %1.f , 回数: %d / %d" % (distance, threshold_distance, count, threshold_count)
        else:
            count=0
    else:
        if distance > threshold_distance:
            count+=1
            print "距離(cm): %.1f > %1.f , 回数: %d / %d" % (distance, threshold_distance, count, threshold_count)
        else:
            count=0

    if count >= threshold_count:
        status = 'out' if status == 'in' else 'in'
        duration = time.time() - status_changed_at
        status_changed_at = time.time()
        print "- ステータスが '%s'(%s) に変化しました" % (status, '何か物体がある' if status == 'in' else '何も物体がない')
        print "- Beam 経由でデータを送信します"
        print es.index(index="sensor", doc_type="event", body={"imsi":imsi, "status":status, "timestamp":datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%fZ'), "duration":duration})
        count=0

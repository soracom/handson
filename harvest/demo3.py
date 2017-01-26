#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys, time, requests, json
from distance import read_distance # 距離を測る関数

# 第一引数を interval に設定
interval=5 if len(sys.argv)==1 else int(sys.argv[1])

while True:
    start_time = time.time()
    print "- 距離を計測します"
    distance = read_distance()
    if distance:
        print "距離: %.1f cm" % (distance)
        headers = {'Content-Type': 'application/json'}
        payload = {'distance': round(distance*10)/10 }
	print "- データを送信します"
	try:
	        r = requests.post('http://harvest.soracom.io', data=json.dumps(payload), headers=headers, timeout=5)
		print r
	except requests.exceptions.ConnectTimeout:
		print 'ERROR: 接続がタイムアウトしました。"connect_air.sh" は実行していますか？'
		sys.exit(1)
        if r.status_code == 400:
		print 'ERROR: データ送信に失敗しました。Harvest が有効になっていない可能性があります。'
		sys.exit(1)
	print 

    # 指定した秒数に１回実行するためのウェイトを入れる
    wait = start_time + interval - start_time
    if wait > 0:
        time.sleep(wait)

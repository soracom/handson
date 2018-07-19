#!/bin/bash

# 第一引数がデータの送信間隔となる(デフォルトは60秒)
if [ "$1" = "" ]
then
	interval=60
else
	interval=$1
fi

while [ 1 ]
do
	(
		# 温度を読み取り、temp にセット
		temp=$(awk -F= 'END {print $2/1000}' < /sys/bus/w1/devices/28-*/w1_slave)
		payload='{"temperature":'$temp'}' # 送信するJSON文字列を作る
		echo -n "sending payload=$payload "
		# HTTP で POST する
		curl -d $payload http://harvest.soracom.io 
		echo " ... done."
	) &
	sleep $interval
done

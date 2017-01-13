#!/bin/bash
if [ "$1" = "" ]
then
	interval=5
else
	interval=$1
fi

while [ 1 ] 
do
	(
		temp=$(tail -1 /sys/bus/w1/devices/28-*/w1_slave | tr = \ | awk '{print $11/1000}')
		payload='{"temperature":'$temp'}'
		echo -n payload=$payload
		curl -X POST -d $payload http://harvest.soracom.io && echo " OK" || echo " NG"
	) &
	sleep $interval
done

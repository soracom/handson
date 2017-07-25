#!/bin/bash
# set timezone as JST
export TZ=JST-9

# check air & cpu temperature
check_temp(){
  if [ -f /sys/bus/w1/devices/28-*/w1_slave ]
  then
    temp=$(
      tail -1 /sys/bus/w1/devices/28-*/w1_slave | \
      tr = \  | \
      awk '{print $11/1000}'
    )
    echo "Air Temperature: $temp (c)"
  else
    cat <<EOF
ERROR: Could not find temperature sensor DS18B20+
       Please check /boot/config.txt and /etc/modules, and reboot.
-- /boot/config.txt (at bottom)
dtoverlay=w1-gpio-pullup,gpiopin=4

-- /etc/modules (at bottom)
w1-gpio
w1-therm
EOF
  exit 1
  fi

  if [ -f /sys/class/thermal/thermal_zone0/temp ]
  then
    cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000}')
    echo "CPU Temperature: $cpu_temp (c)"
  fi
}

# send temperature data to soracom services (harvest, funnel)
send_temp(){
  cat << EOF | curl -v -d @- -H content-type:application/json http://$target.soracom.io
{
  "datetime": "$(date +"%Y-%m-%d %H:%M:%S")",
  "cpu_temperature": $cpu_temp,
  "temperature": $temp
}
EOF
}

# target could be harvest or funnel
target=$1

# seconds to wait between sending data
interval=$2

# main loop
while [ 1 ]
do
  check_temp
  if [ "$target" != "" ]
  then
    send_temp $target
  fi
  if [ "$interval" = "" ]
  then
    exit 0
  else
    sleep $interval
  fi
done

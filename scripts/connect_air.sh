#!/bin/bash
# USB modem device information
default_vendor=1c9e
default_product=98ff
target_vendor=1c9e
target_product=6801
tty=/dev/ttyUSB2

init_modem()
{
  usb_modeswitch -t <<EOF
DefaultVendor= 0x$1
DefaultProduct= 0x$2
TargetVendor= 0x$3
TargetProduct= 0x$4
MessageEndpoint= not set
MessageContent="55534243123456780000000080000606f50402527000000000000000000000"
NeedResponse=0
ResponseEndpoint= not set
Interface=0x00
EOF
  modprobe usbserial vendor=0x$3 product=0x$4
  modprobe -v option
  echo "$3 $4" > /sys/bus/usb-serial/drivers/option1/new_id
}

dialup()
{
  cat > /etc/wvdial.conf << EOF
[Dialer Defaults]
Init1 = ATZ
Init2 = ATQ0 V1 E1 S0=0 &C1 &D2 +FCLASS=0
Init3 = AT+CGDCONT=1,"IP","$2"
Dial Attempts = 3
Stupid Mode = 1
Modem Type = Analog Modem
Dial Command = ATD
Stupid Mode = yes
Baud = 460800
New PPPD = yes
Modem = $1
ISDN = 0
APN = $2
Phone = *99***1#
Username = $3
Password = $4
Carrier Check = no
Auto DNS = 1
Check Def Route = 1
EOF
  grep replacedefaultroute /etc/ppp/peers/wvdial &> /dev/null || echo replacedefaultroute >> /etc/ppp/peers/wvdial
  echo waiting for modem device
  for i in {1..30}
  do
    [ -e $1 ] && break
    echo -n .
    sleep 1
  done
  [ $i = 30 ] && ( echo modem not found ; exit 1 )
  while [ 1 ] ; do wvdial ; sleep 60 ; done
}

lsusb | grep OMEGA && \
init_modem $default_vendor $default_product $target_vendor $target_product && \
dialup $tty soracom.io sora sora
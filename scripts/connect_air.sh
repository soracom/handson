#!/bin/bash
init_fs01bu()
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

init_ak020()
{
	if (lsusb | grep 15eb:7d0e > /dev/null && [ -e /dev/ttyUSB0 ])
	then
		echo AT+CFUN=1 > /dev/ttyUSB0
		sleep 1
		return 0
	fi
	echo -n "Configuring modem ... "
	cat << EOF > /etc/udev/rules.d/40-ak-020.rules
ACTION=="add", ATTRS{idVendor}=="15eb", ATTRS{idProduct}=="a403", RUN+="/usr/sbin/usb_modeswitch --std-eject --default-vendor 0x15eb --default-product 0xa403 --target-product 0x15eb --target-product 0x7d0e"
ACTION=="add", ATTRS{idVendor}=="15eb", ATTRS{idProduct}=="7d0e", RUN+="/sbin/modprobe usbserial vendor=0x15eb product=0x7d0e"
EOF
	udevadm control --reload
	echo done.
	echo Please re-attach modem or reboot.
	exit 1
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

if [ $UID != 0 ]
then
	echo please execute as root or use sudo command.
	exit 1
fi

if (lsusb | grep 1c9e: > /dev/null)
then
	echo Found FS01BU
	init_fs01bu 1c9e 98ff 1c9e 6801 && \
	dialup /dev/ttyUSB2 soracom.io sora sora
elif (lsusb | grep 15eb: > /dev/null)
then
	echo Found AK-020
	init_ak020 && \
	dialup /dev/ttyUSB0 soracom.io sora sora
else
	echo No supported modem found. Please wait for a while and re-execute script.
	exit 1
fi

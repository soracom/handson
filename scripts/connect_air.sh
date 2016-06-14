#!/bin/bash
init_fs01bu()
{
	if (lsusb | grep 1c9e:6801 > /dev/null && [ -e /dev/ttyUSB2 ])
	then
		return 0
	else
		echo ERROR: modem is not configured or initialized properly.
		echo Please re-attach modem or reboot.
		return 1
	fi
}
init_ak020()
{
	if (lsusb | grep 15eb:7d0e > /dev/null && [ -e /dev/ttyUSB0 ])
	then
		echo AT+CFUN=1 > /dev/ttyUSB0 # This mddem needs to be initialzed with this comamnd.
		sleep 2
		return 0
	else
		echo ERROR: modem is not configured or initialized properly.
		echo Please re-attach modem or reboot.
		return 1
	fi
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

# check UID
if [ $UID != 0 ]
then
	echo please execute as root or use sudo command.
	exit 1
fi

# check required package wvdial
if type wvdial &> /dev/null
then
	:
else
	echo ERROR: wvdial is missing.
	echo Please install it with \"apt-get install -y wvdial\" command.
	exit 1
fi

# check udev rule file
if [ ! -f /etc/udev/rules.d/40-usb-modems.rules ]
then
	echo -n "Adding udev modem configuration ... "
	cat << EOF > /etc/udev/rules.d/40-usb-modems.rules
# Fujisoft FS01BU
ACTION=="add", ATTRS{idVendor}=="1c9e", ATTRS{idProduct}=="98ff", RUN+="/usr/sbin/usb_modeswitch --std-eject --default-vendor 0x1c9e --default-product 0x98ff --target-vendor 0x1c9e --target-product 0x6801 -M 55534243123456780000000080000606f50402527000000000000000000000"
ACTION=="add", ATTRS{idVendor}=="1c9e", ATTRS{idProduct}=="6801", RUN+="/sbin/modprobe usbserial vendor=0x1c9e product=0x6801"
ACTION=="add", ATTRS{idVendor}=="1c9e", ATTRS{idProduct}=="6801", RUN+="echo 1c9e 6801 > /sys/bus/usb-serial/drivers/option1/new_id"

# Abit AK-020
ACTION=="add", ATTRS{idVendor}=="15eb", ATTRS{idProduct}=="a403", RUN+="/usr/sbin/usb_modeswitch --std-eject --default-vendor 0x15eb --default-product 0xa403 --target-product 0x15eb --target-product 0x7d0e"
ACTION=="add", ATTRS{idVendor}=="15eb", ATTRS{idProduct}=="7d0e", RUN+="/sbin/modprobe usbserial vendor=0x15eb product=0x7d0e"
EOF
	udevadm control --reload
	echo done.
	echo Please re-attach modem or reboot.
	exit 1
fi

# main
if (lsusb | grep 1c9e: > /dev/null)
then
	echo Found FS01BU
	init_fs01bu && dialup /dev/ttyUSB2 soracom.io sora sora
elif (lsusb | grep 15eb: > /dev/null)
then
	echo Found AK-020
	init_ak020 && dialup /dev/ttyUSB0 soracom.io sora sora
else
	echo No supported modem found. Please wait for a while and re-execute script.
	exit 1
fi

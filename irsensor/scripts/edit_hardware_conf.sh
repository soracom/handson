sed -ie "s/LIRCD_ARGS=\"\"/LIRCD_ARGS=\"--uinput\"/g" /etc/lirc/hardware.conf
sed -ie "s/DRIVER=\"UNCONFIGURED\"/DRIVER=\"default\"/g" /etc/lirc/hardware.conf
sed -ie "s/DEVICE=\"\"/DEVICE=\"\/dev\/lirc0\"/g" /etc/lirc/hardware.conf
sed -ie "s/MODULES=\"\"/MODULES=\"lirc_rpi\"/g" /etc/lirc/hardware.conf

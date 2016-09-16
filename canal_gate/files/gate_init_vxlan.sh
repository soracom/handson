#!/bin/bash

# usage
function usage(){
  cat << EOF

usage:
 $0 [PHY_IF] [PHY_ADDR] [VXLAN_IF] [VXLAN_ADDR] [VXLAN_NETMASK] [VPG Outer IP 1] [VPG Outer IP 2]

 - PHY_IF : device name of physical interface to interact with VPG, typically "eth0" is used.
 - PHY_ADDR: IP address of physical interface, "outerIpAddress" of API response.
 - VXLAN_IF : device name of vxlan interface, specify "vxlan0" if no other vxlan interface is used.
 - VXLAN_ADDR: IP address of vxlan interface, "innerIpAddress" of API response.
 - VXLAN_NETMASK: Netmask of the device subnet, specify "9" if you do not specify device subnet IP range when creating VPG.
 - VPG Out IPs : "outerIpAddress" of VPGs, "100.64.xxx.4" and "100.64.xxx.132".

ex:
 $0 eth0 10.0.0.254 vxlan0 10.x.y.z 9 100.64.xxx.4 100.64.xxx.132

EOF
}

if [ "$UID" != "0" ]
then
  echo '<ERROR> please execute with root privileges (by root user or with sudo)'
  usage
  exit 1
fi

if [ "$6" = "" ]
then
  echo '<ERROR> insufficient parameters'
  usage
  exit 1
fi

PHY_IF=$1
PHY_ADDR=$2
VXLAN_IF=$3
VXLAN_ADDR=$4
VXLAN_NETMASK=$5
shift 5
PEERS=$*

VXLAN_PORT=4789
VXLAN_ID=10

rmmod vxlan
modprobe vxlan udp_port=$VXLAN_PORT

echo "- Creating vxlan interface $VXLAN_IF"
ip link add $VXLAN_IF type vxlan local $PHY_ADDR id $VXLAN_ID port $VXLAN_PORT $VXLAN_PORT dev $PHY_IF
echo

echo "- Flushing previously added fdb entries"
bridge fdb show dev $VXLAN_IF > /tmp/fdb_entries.txt
echo

while read entry; do
  bridge fdb delete $entry dev $VXLAN_IF
done < /tmp/fdb_entries.txt

# Configure IP address for the vxlan interface
if [ "x$VXLAN_ADDR" != "x" ]; then
  echo "- Setting IP address of $VXLAN_IF to $VXLAN_ADDR"
  ifconfig ${VXLAN_IF} ${VXLAN_ADDR}/$VXLAN_NETMASK up
  echo
fi

# Register peers
for PEER in $PEERS
do
  echo "- Registering $PEER as a peer"
  bridge fdb append 00:00:00:00:00:00 dev ${VXLAN_IF} dst $PEER
done

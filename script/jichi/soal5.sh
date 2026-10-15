#!/bin/bash

ip addr add 192.235.3.1/24 dev eth3 2>/dev/null
ip link set eth3 up

pkill -9 dhcrelay 2>/dev/null
dhcrelay -i eth1 -i eth2 -i eth3 -i eth4 192.235.4.10
echo "== JICHI RELAY READY =="


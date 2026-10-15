#!/bin/bash

if [ -f /var/lib/dhcp/dhcpd.leases ]; then
    grep -E "^lease|^  hardware ethernet|^  client-hostname|^  binding state" /var/lib/dhcp/dhcpd.leases
fi

grep "^lease" /var/lib/dhcp/dhcpd.leases 2>/dev/null | sort -u
#!/bin/bash

systemctl enable isc-dhcp-relay 2>/dev/null || update-rc.d isc-dhcp-relay enable 2>/dev/null
service isc-dhcp-relay status
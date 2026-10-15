#!/bin/bash

systemctl enable isc-dhcp-server 2>/dev/null || update-rc.d isc-dhcp-server enable 2>/dev/null
service isc-dhcp-server status
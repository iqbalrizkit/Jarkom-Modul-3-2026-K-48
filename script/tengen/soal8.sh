#!/bin/bash

tcpdump -i eth0 -nvv -s 0 'port 67 or port 68'
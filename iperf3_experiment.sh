#!/bin/bash
iperf3 -c $1 -i 5 -t 3600 -R -J > iperf3.downlink.tcp.json
iperf3 -c $1 -i 5 -t 3600 -J > iperf3.uplink.tcp.json
iperf3 -c $1 -u -i 5 -b 800M -t 28800 -R -J > iperf3.downlink.udp.json
iperf3 -c $1 -u -i 5 -b 100M -t 28800 -J > iperf3.uplink.udp.json


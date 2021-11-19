#!/bin/bash
iperf3 -c $1 -i 5 -t 240 -R -J > iperf3.downlink.tcp.json
iperf3 -c $1 -i 5 -t 240 -J > iperf3.uplink.tcp.json
iperf3 -c $1 -u -i 5 -b 800M -t 240 -R -J > iperf3.downlink.udp.json
iperf3 -c $1 -u -i 5 -b 100M -t 240 -J > iperf3.uplink.udp.json


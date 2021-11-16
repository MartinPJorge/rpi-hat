#!/bin/bash
iperf3 -c 10.5.99.101 -u -i 5 -b 10M -t 28800 -J > iperf3.uplink.json
iperf3 -c 10.5.99.101 -u -i 5 -b 150M -t 28800 -R -J > iperf3.downlink.json

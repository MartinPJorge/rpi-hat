#!/bin/bash

#
# NOTE: this script assumes time synchronization!!! between server and client
#

OFFSET=40 # additional seconds tcpdump waits for


if [ $# -lt 5 ]; then
    echo "synced-iperf.sh server_ip tcp interval duration out outp if [bw]"
    echo "  server_ip - IP of iperf server, 0 for a server iperf"
    echo "  tcp - 1 for TCP, other for UDP"
    echo "  interval- interval with which meas. are reported"
    echo "  duration - for how long the iperf works"
    echo "  out - path to JSON to store meas."
    echo "  outp - path to PCAP to store meas."
    echo "  if - interface where PCAPs are obtained"
    echo "  [bw] - BW in UDP iperf"
    exit 1
fi

server_ip=$1
tcp=$2
interval=$3
duration=$4
out=$5
outp=$6
if=$7
bw=""

if [ $# -eq 8 ]; then
    bw=$8
fi



###################
# TRIGGER TCPDUMP #
###################
sudo tcpdump -G $(( duration + OFFSET )) -W 1 -i $if -w $outp &




##########
# SERVER #
##########
if [ $server_ip -eq 0 ]; then
    sudo iperf3 -s --one-off -J > $out
fi


##########
# CLIENT #
##########
if [ $server_ip -eq 0 ]; then
    if [ $tcp -eq 1 ]; then
        # TCP server iperf
        sudo iperf3 -c -i $interval -t $duration -J > $out
    else
        # UDP server iperf
        sudo iperf3 -c -u -i $interval -t $duration -J -b $bw > $out
    fi
fi


################
# KILL TCPDUMP #
################
#sudo kill -9 `ps aux | grep "sudo tcpdump" | grep -oe "[0-9]\+" | head -n1`

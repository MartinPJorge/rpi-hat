#!/bin/bash


serial="/dev/ttyUSB3"
wireless_if="wwan0"
APN='5tonic'


# issue AT commands 
echo -e 'AT+CGDCONT=1,"IP","5tonic\r' > $serial
echo -e 'AT+CNBP=0x7FFFFFFFFFFFFFFF,0x00000000000000420001E7FFFFDF3FFF,0x000000000000003F,0x00000000000000000000000000000000,0x00000000000000000000000000000000\r' > $serial
echo -e 'AT+CNMP=38\r' > $serial
echo -e 'AT+COPS=2\r' > $serial
echo -e 'AT+COPS=1,2,"21405",7\r' > $serial


# issue QMI client to start connection
sudo qmicli -d /dev/cdc-wdm0\
    --device-open-net="net-raw-ip|net-no-qos-header"\
    --wds-start-network="apn='"$APN"',ip-type=4"\
    --client-no-release-cid


# obtain IP through DHCP
sudo udhcpc -q -f -n -i $wireless_if


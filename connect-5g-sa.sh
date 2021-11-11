#!/bin/bash


serial="/dev/ttyUSB3"
wireless_if="wwan0"
APN='Internet'


# issue AT commands 
echo -e 'AT+CGDCONT=1,"IP",""\r' > $serial
echo -e 'AT+CNBP=0x7FFFFFFFFFFFFFFF,0x00000000000000000000000000000000,0x000000000000003F,0x00000000003FFE63000601E2090808D7,0x00000000003FFE63000601E2090808D7\r' > $serial
echo -e 'AT+CNMP=71\r' > $serial
echo -e 'AT+COPS=2\r' > $serial
echo -e 'AT+COPS=1,2,"21405",13\r' > $serial



# issue QMI client to start connection
sudo qmicli -d /dev/cdc-wdm0\
        --device-open-net="net-raw-ip|net-no-qos-header"\
        --wds-start-network="apn='"$APN"',ip-type=4"\
        --client-no-release-cid\
        --device-open-sync

# obtain IP through DHCP
sudo udhcpc -q -f -n -i $wireless_if


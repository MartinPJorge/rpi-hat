#!/bin/bash


serial="/dev/ttyUSB3"
wireless_if="wwan0"
APN='5gsa02'
OP_WAIT=60 # time to wait operator selection sync


# Ensure raw IP
sudo ip link set dev wwan0 down
echo 'Y' | sudo tee /sys/class/net/wwan0/qmi/raw_ip
sudo ip link set dev wwan0 up


# issue AT commands 
echo 'AT+CGDCONT=1,"IP","5gsa02"'
echo -e 'AT+CGDCONT=1,"IP","5gsa02"\r' > $serial
sleep 2
echo 'AT+CNBP=0x7FFFFFFFFFFFFFFF,0x00000000000000000000000000000000,0x000000000000003F,0x00000000000040000000000000000000,0x00000000000040000000000000000000'
echo -e 'AT+CNBP=0x7FFFFFFFFFFFFFFF,0x00000000000000000000000000000000,0x000000000000003F,0x00000000000040000000000000000000,0x00000000000040000000000000000000\r' > $serial
sleep 2
echo 'AT+CNMP=71'
echo -e 'AT+CNMP=71\r' > $serial
sleep 2
echo 'AT+COPS=2'
echo -e 'AT+COPS=2\r' > $serial
sleep 2
echo 'AT+COPS=1,2,"240680",12'
echo -e 'AT+COPS=1,2,"240680",12\r' > $serial
echo "Waiting $OP_WAIT sec for the operator selection..."
sleep $OP_WAIT


# issue QMI client to open connection
sudo qmicli -d /dev/cdc-wdm0\
    --device-open-net="net-raw-ip|net-no-qos-header"\
    --wds-start-network="apn='5gsa02',ip-type=4"\
    --client-no-release-cid

# Issue QMI client to start connection
sudo qmi-network /dev/cdc-wdm0 start

# obtain IP through DHCP
sudo udhcpc -q -f -i $wireless_if


# rpi-hat
Gather script utils for a RPi hat with LTE/5G connectivity.

The used model is SIM8200EA-M2 5G HAT for Raspberry Pi, 5G/4G/3G Support, Snapdragon X55, Multi Mode Multi Band:

[https://www.waveshare.com/wiki/SIM8200EA-M2_5G_HAT](https://www.waveshare.com/wiki/SIM8200EA-M2_5G_HAT)


## Set up 4G, 5G NSA, 5G SA connection
Depending on the connectivity desired, just trigger these commands:
```bash
# 4G connection
./connect-4g.sh
# 5G NSA connection
connect-5g-nsa.sh
# 5G SA connection
connect-5g-sa.sh
```
these scripts will connect the `wireless_if` with the `APN` specified
inside te script internal variables


## RPi hat monitoring 
The `monitoring.sh` script gathers monitoring metrics of the RPi.
It uses `top` to obtain memory, disk, and CPU monitoring.
However, it assumes that `top` loads a configuration showing the individual
CPU %. Hence, follow this steps:
 1. `top`
 2. type `1` to switch to individual CPU
 3. type `W` to write such configuration under `.config/procps/toprc`

Then you can execute `monitor.sh` as a script.

These are the parameters you can tune:
```bash
FREQ=5 # monitoring frequency in seconds
OUT="/tmp/monitor.csv" # file where monitoring is stored
TOP_TMP="/tmp/top_tmp.txt" # top command temporal records
```
a `.csv` file is stored under `$OUT` with the following data:


| paramater | description |
|-----------|-------------|
| `unix_epoch` | UNIX epoch in seconds since 1970 |
| `mem_total` | total memory [MiB] |
| `mem_free` | free memory [MiB] |
| `mem_used` | used memory [MiB] |
| `mem_buff_cache` | buff/cached reported by top [MiB] |
| `swap_total` | total swap memory [MiB] |
| `swap_free` | free swap memory [MiB] |
| `swap_used` | used swap memory [MiB] |
| `swap_avail_mem` | available swap memory [MiB] |
| `temperature` | RPi temperature |
| `cpui_us` | % CPU time spent in user space |
| `cpui_sy` | % CPU time spent in kernel space |
| `cpui_ni` | % CPU time spent on low priority processes |
| `cpui_id` | % CPU time spent idle |
| `cpui_wa` | % CPU time spent in wait (on disk) |
| `cpui_hi` | % CPU time spent servicing/handling hardware interrupts |
| `cpui_si` | % CPU time spent servicing/handling software interrupts |
| `cpui_st` | steal time % CPU time in involuntary wait by virtual cpu while hypervisor is servicing another processor (or) % CPU time stolen from a virtual machine |



## Requirements

### NFS client
Mount the NFS client to store data on a remote NFS server.

Add the line below to the `/etc/fstab` to mount NFS on bootup.
```bash
# MOUNT the NFS to store data
10.5.5.5:/var/nfsshare/nova-storage/datasets/5g-dive-integration   /mnt   nfs    auto  0  0
```

### Static route
Add an static route to use ethernet connection (10.5.5.0)
to send NFS data:
```bash
# @/etc/network/interfaces

auto eth0
	iface eth0 inet static
#	address 192.168.0.1
#	netmask 255.255.255.0
	address 10.5.98.1
	netmask 255.255.0.0
	dns-nameservers 8.8.8.8
	up ip r add 10.5.5.5 via 10.5.0.1 ## <- add this

```

### USB meter UM34C power/voltage
We collected electricity-related measurements from one of the
RPis using an UM34C (see `Instruction_UM34C.pdf`).

We use the following scenario
```txt

[RPi]
  |
[UM34C]  ))BT))  [RPi2]
                 [rd-usb]
```
where an external RPi2 collects the bluetooth (BT) measurements
of the UM34C using the `rd-usb` repo (contained as submodule here).

### RPi2 bluetooth data collection
This (link)[https://howchoo.com/pi/bluetooth-raspberry-pi]
is useful to install the required libraries.

First we do BT pairing:
```bash
hciconfig hci0 reset
invoke-rc.d bluetooth restart
hcitool scan
  > Scanning ...
  >     00:BA:57:57:CA:C4	UM34C
  >     F8:34:41:A9:D9:9E	lora-desktop
rfcomm bind 0 00:BA:57:57:CA:C4
```
this will create `/dev/rfcomm0`, from where `rd-usb`
app will read the reported values.

### Change DB storage location
```python3
# utils/config.py

# data_path = user_data_dir("rd-usb", False)
data_path = '/mnt/rd-usb'
```
where `mnt/rd-usb` points to a NFS mounted directory.

### Run web app
Then run the application under `rd-usb`:
```bash
sudo python3 web.py --on-receive-interval 5 --on-receive ../json-to-csv.sh
```
Then enter from the web browser to the webpage set up on port `5000`:
 1. go to `serial`
 2. specify `/dev/rfcomm0` in the form field 
 3. select the `UM34C` device up
 4. click on `connect`

It will appear the web interface with the monitoring information.



## PTP time synchronization
We use a PTP syncronization to have a sync. timestamping
in the measurements. One master, and different slaves.

### PTP master
We run the PTP master on Ubuntu 20.04.3 LTS.
There we resort to a service to start the PTP master.

Create a PTP service in `/etc/systemd/system/ptpd-5gdive.service`:
```txt
[Unit]
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/exec-ptpd-screen.sh

[Install]
WantedBy=default.target
```
now create the script invoked by the PTP service at `/usr/local/bin/exec-ptpd-screen.sh`:
```txt
#!/bin/bash

ptpd -C -M -i ens3 -u 10.5.98.1 # add the list of slaves IPs
```

Next step is to give the files the proper privileges:
```bash
sudo chmod 744 /usr/local/bin/exec-ptpd-screen.sh
sudo chmod 664 /etc/systemd/system/ptpd-5gdive.service
```

Now we enable our service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable ptpd-5gdive.service
```


### PTP slave
The PTP slaves are running on Raspbian GNU/Linux 10 (buster).

These guys PTP clients are configured in bootup as follows in the `/etc/network/interfaces`:
```txt
auto eth0
    ## SOME CONFIG
	up screen -S ptpd -d -m sudo ptpd -C --slaveonly -i eth0 -u 10.5.4.30
```

That way, a screen session named `ptpd` is created on bootup to obtain
synchronization



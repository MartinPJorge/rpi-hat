# rpi-hat
Gather script utils for a RPi hat with LTE/5G connectivity

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

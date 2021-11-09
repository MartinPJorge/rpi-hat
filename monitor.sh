#!/bin/bash

FREQ=5 # monitoring frequency in seconds
OUT="/tmp/monitor.csv" # file where monitoring is stored
TOP_TMP="/tmp/top_tmp.txt" # top command temporal records



# Obtain the number of CPUs
CPUs=`top -b -n1 | grep "%Cpu" | wc -l`


if [ ! -f $OUT ]; then
    # Create the CSV header
    csv_header="unix_epoch,mem_total,mem_free,mem_used,mem_buff_cache,swap_total,swap_free,swap_used,swap_avail_mem,temperature"

    # Create placeholders for each CPU metrics
    for i in `seq 0 1 $(( CPUs - 1 ))`; do
        csv_header=$csv_header",cpu"$i"_us"
        csv_header=$csv_header",cpu"$i"_sy"
        csv_header=$csv_header",cpu"$i"_ni"
        csv_header=$csv_header",cpu"$i"_id"
        csv_header=$csv_header",cpu"$i"_wa"
        csv_header=$csv_header",cpu"$i"_hi"
        csv_header=$csv_header",cpu"$i"_si"
        csv_header=$csv_header",cpu"$i"_st"
    done

    echo $csv_header >> $OUT
fi



#####################
## MONITORING LOOP ##
#####################
while [ 1 ]; do
    # timestamp
    monitored=`date +%s`

    # get top metrics
    top -b -n1 > $TOP_TMP


    mem_total=`grep "MiB Mem" $TOP_TMP |\
                grep -o "[0-9]\+\.[0-9]\+ total" | cut -f1 -d' '`
    mem_free=`grep "MiB Mem" $TOP_TMP |\
                grep -o "[0-9]\+\.[0-9]\+ free" | cut -f1 -d' '`
    mem_used=`grep "MiB Mem" $TOP_TMP |\
                grep -o "[0-9]\+\.[0-9]\+ used" | cut -f1 -d' '`
    mem_buff_cache=`grep "MiB Mem" $TOP_TMP |\
                grep -o "[0-9]\+\.[0-9]\+ buff\/cache" | cut -f1 -d' '`
    swap_total=`grep "MiB Swap" $TOP_TMP |\
                grep -o "[0-9]\+\.[0-9]\+ total" | cut -f1 -d' '`
    swap_free=`grep "MiB Swap" $TOP_TMP |\
                grep -o "[0-9]\+\.[0-9]\+ free" | cut -f1 -d' '`
    swap_used=`grep "MiB Swap" $TOP_TMP |\
                grep -o "[0-9]\+\.[0-9]\+ used" | cut -f1 -d' '`
    swap_avail_mem=`grep "MiB Swap" $TOP_TMP |\
                grep -o "[0-9]\+\.[0-9]\+ avail Mem" | cut -f1 -d' '`
    temperature=`vcgencmd measure_temp | cut -f2 -d'=' | cut -d"'" -f1`

    # Append all data in one line
    monitored=$monitored","$mem_total","$mem_free","$mem_used","$mem_buff_cache
    monitored=$monitored","$swap_total","$swap_free","$swap_used
    monitored=$monitored","$swap_avail_mem","$temperature



    # Retrieve metrics for each CPU
    for i in `seq 0 1 $(( CPUs - 1 ))`; do
        cpu_us=`grep "Cpu$i" $TOP_TMP |\
                    grep -o "[0-9]\+\.[0-9]\+ us" | cut -f1 -d' '`
        cpu_sy=`grep "Cpu$i" $TOP_TMP |\
                    grep -o "[0-9]\+\.[0-9]\+ sy" | cut -f1 -d' '`
        cpu_ni=`grep "Cpu$i" $TOP_TMP |\
                    grep -o "[0-9]\+\.[0-9]\+ ni" | cut -f1 -d' '`
        cpu_id=`grep "Cpu$i" $TOP_TMP |\
                    grep -o "[0-9]\+\.[0-9]\+ id" | cut -f1 -d' '`
        cpu_wa=`grep "Cpu$i" $TOP_TMP |\
                    grep -o "[0-9]\+\.[0-9]\+ wa" | cut -f1 -d' '`
        cpu_hi=`grep "Cpu$i" $TOP_TMP |\
                    grep -o "[0-9]\+\.[0-9]\+ hi" | cut -f1 -d' '`
        cpu_si=`grep "Cpu$i" $TOP_TMP |\
                    grep -o "[0-9]\+\.[0-9]\+ si" | cut -f1 -d' '`
        cpu_st=`grep "Cpu$i" $TOP_TMP |\
                    grep -o "[0-9]\+\.[0-9]\+ st" | cut -f1 -d' '`

        # Append CPU info
        monitored=$monitored","$cpu_us","$cpu_sy","$cpu_ni","$cpu_id","$cpu_wa
        monitored=$monitored","$cpu_hi","$cpu_si","$cpu_st
    done
    

    echo $monitored
    echo $monitored >> $OUT
    sleep $FREQ
done



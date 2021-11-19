#!/bin/bash


if [ $# -ne 1 ]; then
    echo "at-monitor OUT"
    exit 1
fi

serial="/dev/ttyUSB3"
CPSI_FREQ=5
OUT=$1
QMI_TMP="/tmp/qmi-tmp.txt"
COMMAND_INTER=0.01 # how much [s] wait between commands

# Create the QMI file with all priviledge
touch $QMI_TMP
sudo chmod 666 $QMI_TMP
# Create the OUT file with all priviledge
touch $OUT
sudo chmod 666 $OUT



# First issue the periodic reporting
echo -e 'AT+CPSI=0\r' > $serial          # disable
echo -e "AT+CPSI=$CPSI_FREQ\r" > $serial # enable




# Create the CSV header
csv_header="unix_epoch,operation_mode,mcc,mnc,tac,scellid,pcellid"
csv_header=$csv_header",frequencyband,earfcn,dlbw,ulbw,rsrq,rsrp"
csv_header=$csv_header",rssi,rssnr,earfcn_ssb,rssi_me,ber_me,cpmu_temp"
csv_header=$csv_header",voltage,qmi_rssi,qmi_rsrq,qmi_rsrp,qmi_snr"
csv_header=$csv_header",qmi_lte_tunned_rxchain0,qmi_lte_tunned_rxchain1"
csv_header=$csv_header",qmi_lte_power_rxchain0,qmi_lte_power_rxchain1"
csv_header=$csv_header",qmi_lte_ecio_rxchain0,qmi_lte_ecio_rxchain1"
csv_header=$csv_header",qmi_lte_phase_rxchain0,qmi_lte_phase_power_rxchain1"
csv_header=$csv_header",qmi_nr_tunned_rxchain0,qmi_nr_tunned_rxchain1"
csv_header=$csv_header",qmi_nr_power_rxchain0,qmi_nr_power_rxchain1"
csv_header=$csv_header",qmi_nr_ecio_rxchain0,qmi_nr_ecio_rxchain1"
csv_header=$csv_header",qmi_nr_phase_rxchain0,qmi_nr_phase_power_rxchain1"
sudo echo $csv_header > $OUT




# Retrieve periodic data
while read line; do
    echo LEO-$line

    ############################
    # AT+CPSI output - UE info #
    ############################
    if [[ $line =~ ^\+CPSI\: ]]; then
        echo $line

        # Print prior data
        now=`date +%s`
        csv_line=$(( now - CPSI_FREQ ))
        csv_line=$csv_line,$operation_mode,$mcc,$mnc,$tac,$scellid,$pcellid
        csv_line=$csv_line,$frequencyband,$earfcn,$dlbw,$ulbw,$rsrq,$rsrp
        csv_line=$csv_line,$rssi,$rssnr,$earfcn_ssb,$rssi_me,$ber_me,$cpmu_temp
        csv_line=$csv_line,$voltage



        sudo echo $csv_line >> $OUT







        # Clear variables
        operation_mode=""
        mcc=""
        mnc=""
        tac=""
        scellid=""
        pcellid=""
        frequencyband=""
        earfcn=""
        dlbw=""
        ulbw=""
        rsrq=""
        rsrp=""
        rssi=""
        rssnr=""
        earfcn_ssb=""
        rssi_me=""
        ber_me=""
        cpmu_temp=""
        voltage=""
        qmi_rssi=""
        qmi_rsrq=""
        qmi_rsrp=""
        qmi_snr=""
        qmi_lte_tunned_rxchain0=""
        qmi_lte_tunned_rxchain1=""
        qmi_lte_power_rxchain0=""
        qmi_lte_power_rxchain1=""
        qmi_lte_ecio_rxchain0=""
        qmi_lte_ecio_rxchain1=""
        qmi_lte_phase_rxchain0=""
        qmi_lte_phase_power_rxchain1=""
        qmi_nr_tunned_rxchain0=""
        qmi_nr_tunned_rxchain1=""
        qmi_nr_power_rxchain0=""
        qmi_nr_power_rxchain1=""
        qmi_nr_ecio_rxchain0=""
        qmi_nr_ecio_rxchain1=""
        qmi_nr_phase_rxchain0=""
        qmi_nr_phase_power_rxchain1=""





        #######
        # LTE #
        #######
        if [[ $line =~ LTE ]]; then
            if [[ $line =~ (LTE),([0-9a-zA-Z]+),([0-9]+)\-([0-9]+),(0x[0-9A-F]+),([0-9]+),([0-9]+),([0-9A-Z\-]+),([0-9]+),([0-9]+),([0-9]+),([\-0-9]+),([\-0-9]+)([\-0-9]+),([\-0-9]+) ]]; then

                operation_mode=${BASH_REMATCH[1]}
                mcc=${BASH_REMATCH[2]}
                mnc=${BASH_REMATCH[3]}
                tac=${BASH_REMATCH[4]}
                scellid=${BASH_REMATCH[5]}
                pcellid=${BASH_REMATCH[6]}
                frequencyband=${BASH_REMATCH[7]}
                earfcn=${BASH_REMATCH[8]}
                dlbw=${BASH_REMATCH[9]}
                ulbw=${BASH_REMATCH[9]}
                rsrq=${BASH_REMATCH[10]}
                rsrp=${BASH_REMATCH[11]}
                rssi=${BASH_REMATCH[12]}
                rssnr=${BASH_REMATCH[13]}
            fi


            
            #################################
            # Obtain QMI TX/RX measurements #
            #################################
            sudo qmicli -d /dev/cdc-wdm0\
                -nas-get-tx-rx-info=lte --device-open-sync > $QMI_TMP
            qmi_lte_tunned_rxchain0=`cat $QMI_TMP | grep tuned |\
                grep -oe "'[a-zA-Z0-9]\+' | head -n1"`
            qmi_lte_tunned_rxchain1=`cat $QMI_TMP | grep tuned |\
                grep -oe "'[a-zA-Z0-9]\+' | head -n2 | tail -n1"`
            # dBm
            qmi_lte_power_rxchain0=`cat $QMI_TMP | grep Power |\
                grep -oe "[-0-9]\+[.0-9]* | head -n1"`
            qmi_lte_power_rxchain1=`cat $QMI_TMP | grep Power |\
                grep -oe "[-0-9]\+[.0-9]* | head -n2 | tail -n1"`
            # dBm
            qmi_lte_ecio_rxchain0=`cat $QMI_TMP | grep ECIO |\
             grep -oe "[-0-9]\+[.0-9]* | head -n1"`
            qmi_lte_ecio_rxchain1=`cat $QMI_TMP | grep ECIO |\
                grep -oe "[-0-9]\+[.0-9]* | head -n2 | tail -n1"
            # degrees
            qmi_lte_phase_rxchain0=`cat $QMI_TMP | grep Phase |\
             grep -oe "[-0-9]\+[.0-9]* | head -n1"`
            qmi_lte_phase_power_rxchain1=`cat $QMI_TMP | grep Phase |\
                grep -oe "[-0-9]\+[.0-9]* | head -n2 | tail -n1"
        fi


        #########
        # 5G SA #
        #########
        if [[ $line =~ NR5G_SA ]]; then
            if [[ $line =~ (NR5G_SA),([a-zA-Z0-9]+),([0-9]+)\-([0-9]+),(0x[A-F0-9]+),([0-9]+),([0-9]+),([a-zA-Z_0-9]+),([0-9]+),([\-0-9]+),([\-0-9]+),([0-9]+) ]]; then

                operation_mode=${BASH_REMATCH[1]}
                mcc=${BASH_REMATCH[2]}
                mnc=${BASH_REMATCH[3]}
                tac=${BASH_REMATCH[4]}
                scellid=${BASH_REMATCH[5]}
                pcellid=${BASH_REMATCH[6]}
                earfcn=${BASH_REMATCH[7]}
                earfcn_ssb=${BASH_REMATCH[8]}
                rsrp=${BASH_REMATCH[9]}
                rsrq=${BASH_REMATCH[10]}
                rssnr=${BASH_REMATCH[11]}
            fi

            #################################
            # Obtain QMI TX/RX measurements #
            #################################
            # TODO - check if is nr5g what should be below
            echo $QMI_TMP
            sudo qmicli -d /dev/cdc-wdm0 --nas-get-tx-rx-info=5gnr --device-open-sync > $QMI_TMP
            qmi_nr_tunned_rxchain0=`cat $QMI_TMP | grep tuned |\
                grep -oe "'[a-zA-Z0-9]\+' | head -n1"`
            qmi_nr_tunned_rxchain1=`cat $QMI_TMP | grep tuned |\
                grep -oe "'[a-zA-Z0-9]\+' | head -n2 | tail -n1"`
            # dBm
            qmi_nr_power_rxchain0=`cat $QMI_TMP | grep Power |\
                grep -oe "[-0-9]\+[.0-9]* | head -n1"`
            qmi_nr_power_rxchain1=`cat $QMI_TMP | grep Power |\
                grep -oe "[-0-9]\+[.0-9]* | head -n2 | tail -n1"`
            # dBm
            qmi_nr_ecio_rxchain0=`cat $QMI_TMP | grep ECIO |\
             grep -oe "[-0-9]\+[.0-9]* | head -n1"`
            qmi_nr_ecio_rxchain1=`cat $QMI_TMP | grep ECIO |\
                grep -oe "[-0-9]\+[.0-9]* | head -n2 | tail -n1"`
            # degrees
            qmi_nr_phase_rxchain0=`cat $QMI_TMP | grep Phase |\
             grep -oe "[-0-9]\+[.0-9]* | head -n1"`
            qmi_nr_phase_power_rxchain1=`cat $QMI_TMP | grep Phase |\
                grep -oe "[-0-9]\+[.0-9]* | head -n2 | tail -n1"`
        fi
            
        # TODO - other connectivity methods, e.g., 5G NSA



        ##################################
        # Obtain QMI signal measurements #
        ##################################
        sudo qmicli -d /dev/cdc-wdm0\
            --nas-get-signal-info --device-open-sync > $QMI_TMP
        # dBm
        qmi_rssi=`cat $QMI_TMP | grep "RSSI" | grep -oe "[-0-9]\+[.0-9]*"` 
        # dB
        qmi_rsrq=`cat $QMI_TMP | grep "RSRQ" | grep -oe "[-0-9]\+[.0-9]*"`
        # dBm
        qmi_rsrp=`cat $QMI_TMP | grep "RSRP" | grep -oe "[-0-9]\+[.0-9]*"`
        # dB
        qmi_snr=`cat $QMI_TMP | grep "SNR" | grep -oe "[-0-9]\+[.0-9]*"`




        # Trigger other AT commands of interest
        echo -e 'AT+CSQ\r' > $serial # signal quality
        sleep $COMMAND_INTER
        echo -e 'AT+CPMUTEMP\r' > $serial # module temperature
        sleep $COMMAND_INTER
        echo -e 'AT+CBC\r' > $serial # power supply
    fi



    ##################################
    # AT+CSQ output - signal quality #
    ##################################
    if [[ $line =~ ^\+CSQ\:\ ([0-9]+),([0-9]+) ]]; then
        echo $line
        rssi_me=${BASH_REMATCH[1]}
        ber_me=${BASH_REMATCH[2]}

        # TODO - convert values
    fi


    ##########################################
    # AT+CPUTEMP output - module temperature #
    ##########################################
    if [[ $line =~ ^\+CPMUTEMP\:\ ([0-9]+) ]]; then
        echo $line
        cpmu_temp=${BASH_REMATCH[1]}
    fi


    ########################################
    # AT+CBC output - power supply voltage #
    ########################################
    if [[ $line =~ ^\+CBC\:\ ([0-9]+\.[0-9]+)V ]]; then
        echo $line
        voltage=${BASH_REMATCH[1]}
    fi

    
done < $serial



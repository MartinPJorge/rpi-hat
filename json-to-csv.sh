#!/bin/bash


DATASET="/mnt/power-measurements.csv"
json_file_tmp=$1
python3 ../json-to-csv.py $json_file_tmp >> $DATASET
rm $json_file_tmp



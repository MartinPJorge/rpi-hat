#!/usr/bin/python3

import json
import sys



if __name__ == '__main__':
    with open(sys.argv[1]) as json_file:
        data = json.load(json_file)
    for measurement in data:
        measure_csv_line = ''
        for k in measurement.keys():
            measure_csv_line += f'{measurement[k]},'
        measure_csv_line = measure_csv_line[:-1]

        print(measure_csv_line)


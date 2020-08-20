#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

list_conf=$1
dir="data"
ds="./scripts/docker"

for ft in $dir/*/*{raw,d,wiff}; do
    if [ -f $ft ]; then

        file_name=$(basename $ft)

        for cnf in $list_conf; do

            if [[ "$cnf" == *"ms1"* ]]; then
                # extract ms1 data
                $ds/mzml_make.sh $file_name $cnf
                $ds/ms1_image.sh $file_name
            fi

            if [[ "$cnf" == *"ms2"* ]]; then
                # extract ms2 data
                $ds/mzml_make.sh $file_name $cnf
                $ds/ms2_table.sh $file_name 
            fi
        done
    fi
done

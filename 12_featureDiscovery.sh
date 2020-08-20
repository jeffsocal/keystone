#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

list_conf=$1
dir="data"
ds="./scripts/docker"

for ft in $dir/*/*.ms1.mzml; do
    if [ -f $ft ]; then

        file_name=$(basename $ft)

        # find features
        $ds/features_find.sh $file_name $list_conf
        
        # extract data to table
        $ds/features_table.sh $file_name 

        # map ms2 scans to m1 features
        $ds/features_map.sh $file_name 

    fi
done

#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

list_conf=$1
ds="./scripts/docker"

for ft in $dir/*/*.ms2.mzml; do
    if [ -f $ft ]; then

        file_name=$(basename $ft)

        # search for peptide ids
        $ds/comet_run.sh $file_name $list_conf

        # peptide validation
        $ds/peptide_prophet.sh $file_name 

        # extract peptide data to table
        $ds/peptide_table.sh $file_name 

        # protein validation
        $ds/protein_prophet.sh $file_name 

        # extract protein data to table
        $ds/protein_table.sh $file_name 


    fi
done

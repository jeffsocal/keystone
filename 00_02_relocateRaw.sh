#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

dir=data

echo
echo "RELOCATE RAW -> ../data_raw"
echo

mkdir -p data_raw

for ft in $dir/*/*{raw,d,wiff}
do
    if [ -f $ft ]; then

        dn=$(dirname $ft)
        bn=$(basename $ft)
        rp=$(realpath $dir/..)
        fn="${bn%.*}"

        mv data/$fn/$bn data_raw/
        
    fi
done

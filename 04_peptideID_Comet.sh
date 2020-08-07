#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

cfs=$1
dir=data

dimg="biocontainers/comet:v2016011_cv5 comet"

echo
echo "PEPTIDE IDENTIFICATION"
echo

for ft in $dir/*/*ms2.mzml
do
    if [ -f $ft ]; then

        dn=$(dirname $ft)
        bn=$(basename $ft)
        rp=$(realpath $dir/..)
        fn="${bn%.*.*}"

        for cnf in $cfs
        do

            echo

            docker run --rm -e WINEDEBUG=-all \
                -v $rp:/mzd \
                $dimg \
                /mzd/data/$fn/$bn \
                -P/mzd/configs/$cnf

        done
    fi
done
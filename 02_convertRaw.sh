#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

cfs=$1
dir=data

dimg_a="chambm/pwiz-skyline-i-agree-to-the-vendor-licenses wine msconvert"
dimg_b="jeffsocal/tidy-mzr Rscript"

echo
echo "CONVERT RAW -> MZML"
echo

for ft in $dir/*/*{raw,d,wiff}
do
    if [ -f $ft ]; then

        dn=$(dirname $ft)
        bn=$(basename $ft)
        rp=$(realpath $dir/..)
        fn="${bn%.*}"

        for cnf in $cfs
        do

            echo

            docker run --rm -e WINEDEBUG=-all \
                -v $rp:/mzd \
                $dimg_a \
                /mzd/data/$fn/$bn \
                -o /mzd/data/$fn \
                -c /mzd/configs/$cnf

            if [[ "$cnf" == *"ms1"* ]]; then
                docker run --rm \
                    -v $rp:/mzd \
                    $dimg_b \
                    mzd/scripts/R/createRDS_mzr_ms1image.R \
                    --mzml=mzd/data/$fn/$fn.ms1.mzml
            fi

            if [[ "$cnf" == *"ms2"* ]]; then
                docker run --rm \
                    -v $rp:/mzd \
                    $dimg_b \
                    mzd/scripts/R/createRDS_mzr_ms2scans.R \
                    --mzml=mzd/data/$fn/$fn.ms2.mzml
            fi

        done
    fi
done

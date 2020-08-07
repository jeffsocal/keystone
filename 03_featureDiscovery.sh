#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

cfs=$1
dir=data

dimg_a="hroest/openms-executables-2.2"
dimg_b="tidy-mzr Rscript"

echo
echo "FEATURE DISCOVERY"
echo

for ft in $dir/*/*ms1.mzml
do
    if [ -f $ft ]; then

        dn=$(dirname $ft)
        bn=$(basename $ft)
        rp=$(realpath $dir/..)
        fn="${bn%.*.*}"

        echo
        docker run --rm -e WINEDEBUG=-all \
            -v $rp:/mzd \
            $dimg_a \
            FeatureFinderCentroided \
            -ini /mzd/configs/$cfs \
            -in /mzd/data/$fn/$bn \
            -out /mzd/data/$fn/$fn.ms1.feaXML

        docker run --rm \
                -v $rp:/mzd \
                $dimg_b \
                mzd/scripts/R/createRDS_feaxml.R \
                --xml=mzd/data/$fn/$fn.ms1.feaXML

    fi
done
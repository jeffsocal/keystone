#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

dir=data

dimg_a="biocontainers/tpp:v5.2_cv1 PeptideProphetParser"
dimg_b="tidy-mzr Rscript"

echo
echo "PEPTIDE VALIDATION"
echo

for ft in $dir/*/*ms2.mzml
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
            /mzd/data/$fn/$fn.ms2.pep.xml

        docker run --rm \
            -v $rp:/mzd \
            $dimg_b \
            mzd/scripts/R/createRDS_pepxml.R \
            --xml=mzd/data/$fn/$fn.ms2.pep.xml

    fi
done
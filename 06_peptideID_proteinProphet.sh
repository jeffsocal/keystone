#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

dir=data

dimg_a="biocontainers/tpp:v5.2_cv1 ProteinProphet"
dimg_b="tidy-mzr Rscript"

echo
echo "PROTEIN VALIDATION"
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
            /mzd/data/$fn/$fn.ms2.pep.xml \
            /mzd/data/$fn/$fn.ms2.prot.xml

        docker run --rm \
            -v $rp:/mzd \
            $dimg_b \
            mzd/scripts/R/createRDS_protxml.R \
            --xml=mzd/data/$fn/$fn.ms2.prot.xml

    fi
done
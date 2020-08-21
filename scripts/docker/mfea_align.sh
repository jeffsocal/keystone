#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

path_proj=$(realpath ./)

dcmd="docker run --rm"
dimg="jeffsocal/tidy-mzr Rscript"
rscp="align.R"

echo
echo "ALIGNING FEATURES"

$dcmd \
    -v $path_proj/data:/mzdata \
    -v $path_proj/scripts/annealr:/R \
    $dimg \
    R/$rscp \
    --input="/mzdata" \
    --exp="/R" 
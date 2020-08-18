#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

file_name=$1 # the base file name

path_proj=$(realpath ./)
file_base="${file_name%.*.*}"

dcmd="docker run --rm"
dimg="jeffsocal/tidy-mzr Rscript"
rscp="createRDS_feaxml.R"

echo
echo "CONVERT featureXML -> RDS"

$dcmd \
    -v $path_proj/data:/mzdata \
    -v $path_proj/scripts/R:/R \
    $dimg \
    R/$rscp \
    --xml=/mzdata/$file_base/$file_base.ms1.featureXML

#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

file_name=$1 # the base file name

path_proj=$(realpath ./)
file_base="${file_name%.*.*}"

dcmd="docker run --rm"
dimg="jeffsocal/tidy-mzr Rscript"
rscp="map_ms1features_ms2scans.R"

echo
echo "MAP features:scans -> RDS"

$dcmd \
    -v $path_proj/data:/mzdata \
    -v $path_proj/scripts/R:/R \
    -v $path_proj/scripts/annealr:/annealr \
    $dimg \
    R/$rscp \
    --ref=/mzdata/$file_base/$file_base.ms1.fea.rds \
    --scn=/mzdata/$file_base/$file_base.ms2.rds \
    --exp="/annealr"

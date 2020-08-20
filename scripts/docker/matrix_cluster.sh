#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

tol_mz=$1 # mz tolerance (daltions)
tol_lc=$2 # lc tolerance (seconds)
n_cpus=$3 # cpus

path_proj=$(realpath ./)
file_base="${file_name%.*.*}"

dcmd="docker run --rm"
dimg="jeffsocal/tidy-signal"
rscp="cluster.R"

echo
echo "CLUSTERING FEATURES"

$dcmd \
    -v $path_proj/data:/mzdata \
    -v $path_proj/scripts/annealR:/R \
    $dimg \
    R/$rscp \
    --input=/mzdata \
    --exp=/R \
    --mztol=$tol_mz \
    --lctol=$tol_lc \
    --cpu=$n_cpus
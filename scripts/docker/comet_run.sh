#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

file_name=$1 # the base file name
conf_name=$2 # the COMET Search Engine config file

path_proj=$(realpath ./)
file_base="${file_name%.*.*}"

dcmd="docker run --rm"
dimg="biocontainers/comet:v2016011_cv5 comet"

echo
echo "COMET SEARCH"

$dcmd \
    -v $path_proj/data:/mzdata \
    -v $path_proj/configs:/mzconf \
    -v $path_proj/fasta:/fasta \
    $dimg \
    /mzdata/$file_base/$file_name \
    -P/mzconf/$conf_name

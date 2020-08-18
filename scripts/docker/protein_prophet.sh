#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

file_name=$1 # the base file name

path_proj=$(realpath ./)
file_base="${file_name%.*.*}"

dcmd="docker run --rm"
dimg="biocontainers/tpp:v5.2_cv1 ProteinProphet"

echo
echo "ProteinProphet"

$dcmd \
    -v $path_proj/data:/mzdata \
    $dimg \
    /mzdata/$file_base/$file_base.ms2.pep.xml \
    /mzdata/$file_base/$file_base.ms2.prot.xml
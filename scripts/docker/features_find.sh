#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

file_name=$1 # the base file name
conf_name=$2 # the OpenMS:FeatureFinderCentroided config file

path_proj=$(realpath ./)
file_base="${file_name%.*.*}"

dcmd="docker run --rm -e WINEDEBUG=-all"
dimg="hroest/openms-executables-2.2"

echo
echo "FeatureFinderCentroided"

$dcmd \
    -v $path_proj/data:/mzdata \
    -v $path_proj/configs:/mzconf \
    $dimg \
    FeatureFinderCentroided \
    -ini /mzconf/$conf_name \
    -in /mzdata/$file_base/$file_name \
    -out /mzdata/$file_base/$file_base.ms1.featureXML

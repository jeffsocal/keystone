#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

file_name=$1 # the base file name
conf_name=$2 # the Proteo Wizard config file

path_proj=$(realpath ./)
file_base="${file_name%.*}"

dcmd="docker run --rm -e WINEDEBUG=-all"
dimg="chambm/pwiz-skyline-i-agree-to-the-vendor-licenses wine msconvert"

echo
echo "CONVERT RAW -> MZML"

$dcmd \
    -v $path_proj/data:/mzdata \
    -v $path_proj/configs:/mzconf \
    $dimg \
    /mzdata/$file_base/$file_name \
    -o /mzdata/$file_base \
    -c /mzconf/$conf_name

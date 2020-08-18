#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019
# pipeline repository
# github jeffsocal/keystone v 1.23

# dependencies
# docker pull chambm/pwiz-skyline-i-agree-to-the-vendor-licenses
# docker pull biocontainers/tpp:v5.2_cv1
# docker pull biocontainers/comet
# docker pull jeffsocal/tidy-mzr

echo 
echo " EXTRACT ------------------------------"
./11_convertRaw.sh "extract_ms1.ini extract_ms2.ini"

echo
echo " FEATURE DISCOVERY --------------------"
./12_featureDiscovery.sh "feature_finder_centroided.ini"

echo
echo " SEQUENCE IDENTIFICATION --------------"
./13_peptideID_Comet.sh "comet.params"

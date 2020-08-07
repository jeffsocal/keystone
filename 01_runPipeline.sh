#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019
# pipeline repository
# github jeffsocal/keystone v 1.23

# dependencies
# docker pull chambm/pwiz-skyline-i-agree-to-the-vendor-licenses
# docker pull biocontainers/tpp:v5.2_cv1
# docker pull biocontainers/comet

echo 
echo " EXTRACT ------------------------------"
./02_convertRaw.sh "extract_ms1.ini extract_ms2.ini"

echo
echo " FEATURE DISCOVERY --------------------"
./03_featureDiscovery.sh "feature_finder_centroided.ini"

echo
echo " SEQUENCE IDENTIFICATION --------------"
./04_peptideID_Comet.sh "comet.params"

echo
echo " SEQUENCE VALIDATION ------------------"
./05_peptideID_peptideProphet.sh

echo
echo " PROTEIN VALIDATION -------------------"
./06_peptideID_proteinProphet.sh


# # meld
# ############################################################
# ## cluster
# 03_meld/04_cluster.r --path=$1 --lcsec=30 --mzda=0.1

# ## align
# 03_meld/05_align.r --path=$1 --method=loess

# ## normalize
# 03_meld/06_normalize.r --path=$1 --method=randomForest

# ## impute
# 03_meld/05_impute.r --path=$1 --method=missForest

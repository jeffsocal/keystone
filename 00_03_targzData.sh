#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

arch=$1
dir=data

echo
echo "COMPRESS DATA -> data.tar.gz"
echo

tar --exclude='*.p*xml' --exclude='*.fea*XML'  --exclude='*.ms2.mzml' -czvf $arch.tar.gz data
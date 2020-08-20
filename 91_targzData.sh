#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

arch=$1
dir=data

echo
echo "COMPRESS DATA -> data.tar.gz"
echo

tar --exclude='*xml' \
    --exclude='*.fea*XML'  \
    --exclude='*mzml' \
    --exclude='*raw' \
    -czvf $arch.tar.gz data
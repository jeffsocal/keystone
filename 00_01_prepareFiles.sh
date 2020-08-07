#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019
# pipeline repository
# github jeffsocal/keystone v 1.23

dir=data

# preparation: place each raw file into a seperate directory
###########################################################
for fp in $dir/*.{raw,d,wiff}
do

    if [ -f $fp ]; then

        bn=$(basename $fp)
        fn="${bn%.*}"

        mkdir -p $dir/${fn}
        mv $fp $dir/${fn}/
    fi

done
#!/bin/bash

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

ds="./scripts/docker"

# initial cluster of molecular features
$ds/mfea_cluster.sh 0.05 120 8

# align molecular features
$ds/mfea_align.sh

# final cluster of molecular features
$ds/mfea_cluster.sh 0.025 240 8

# normalize intensity values of molecular features
$ds/mfea_normalize.sh

# keystone
quantitative proteomics analysis pipeline

This repository represents an effort to combine current best-in-class implementations for proteomics analysis and translation into a single succinct pipeline for quantitative experiments all implemented in publicly available docker containers. The object of this effort is to start with raw LCSM data and end with R data objects ready for analysis and downstream predictive modeling.

## Install docker
[docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

### pull down the docker images
```
docker pull chambm/pwiz-skyline-i-agree-to-the-vendor-licenses
docker pull hroest/openms-executables-2.2
docker pull biocontainers/tpp:v5.2_cv1
docker pull biocontainers/comet
docker pull jeffsocal/tidy-mzR
```

## Setup
#### Clone this repository AS the project space
```
 project_name
 -- configs
 -- data
 -- docs
 -- fasta
 -- scripts
 ---- R
 ------ lib
 -- 00_prepareFiles.sh  
 -- 01_runPipeline.sh
 -- 11_convertRaw.sh
 -- 12_featureDiscovery.sh
 -- 13_proteinIDs.sh
 -- 91_targzData.sh
```

## Download a fasta protein sequence database
```
cd fasta
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip uniprot_sprot.fasta.gz
```

## Modify
 - the configuration files in the config directory
 - the 01_runPipeline.sh shell script to fit your needs

## Run the pipeline
```
# cd to your parent directory and rename the project
cd path_to_dir
mv keystone my_project
cd my_project
# copy raw LCMS data into the data directory
mv path_to_data data
# prepare the project which will move all raw data into a self named directory
./00_01_prepareFiles.sh
# start the pipeline
./01_runPipeline.sh
# if you are running this on a remote server it is advised to nohup the process
nohup ./01_runPipeline > pipeline.log &
```

## Explore the results
All of the data generated by the pipeline will be contained within each sub directory as such:
```
my_project/
  |--data/
       |--data_file_000/
            |--data_file_000.raw                  # the original data file
            |--data_file_000.ms1.fea.rds          # ms1 molecular features R data object
            |--data_file_000.ms1.featureXML       # OpenMS feature discovery xml
            |--data_file_000.ms1.mzml             # pwiz extracted ms1 scans
            |--data_file_000.ms2.mzml             # pwiz extracted ms2 scans top 300 peaks
            |--data_file_000.ms2.rds              # ms2 scans R data object
            |--data_file_000.ms2.pep.rds          # ms2 peptide IDs R data object
            |--data_file_000.ms2.pep.xml          # peptide xml IDs w/ peptideProphet validation
            |--data_file_000.ms2.prot.rds         # ms2 protein IDs R data object
            |--data_file_000.ms2.prot.xml         # protein xml IDs w/ proteinProphet validation
```

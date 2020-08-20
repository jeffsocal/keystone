# Jeff Jones
# SoCal Bioinformatics Inc. 2019

rm(list=ls())
library(xml2)
suppressMessages(library(tidyverse))
options(warn=-1)
source("./R/lib/progtimer.R")

help_text <- "
 NAME
    createRDS_mzml.R

 SYNOPSIS
    createRDS_mzml.R --mzml=<path_pepmzml> --fdr=0.05 --rank=1

 DESCRIPTION
    extract scan data for downstream analysis

 COMMAND LINE

    --mzml <path_pepmzml>

 EXAMPLE

    Rscript createRDS_mzml.R --mzml=<path_to.pepmzml>

"

###############################################################################
# USER INPUT
path_mzml                      <- NULL

for (arg in commandArgs()){
    arg_value <- as.character(sub("--[a-z]*\\=", "", arg))
    if( grepl("--mzml", arg) ) path_mzml <- arg_value
    if( grepl("--help", arg) ) stop(help_text)
}

###############################################################################
# INPUT VALIDATION
message <- NULL
if(is.null(path_mzml)) message <- stop("ERROR\n", "  no mzml file declared\n")
if(!grepl(".*mzml$", path_mzml, ignore.case = T)) message <- paste0(message, "  mz file (--mzml) not a supported format\n")
# if(is.null(path_rds))
#     path_rds = paste0(path_mzml, ".rds")
# if(!grepl(".rds$", path_rds)) message <- paste0(message, "  rds file (--rds) not a supported format\n")

if(!is.null(message)) stop("ERROR\n", message)

path_rds <- sub("\\.mzml$", ".rds", path_mzml)

cat("pepmzml to rds started\n")
cat(" mzml file:                        ", path_mzml, "\n")
cat(" rds file:                         ", path_rds, "\n")
# cat(" fdr cut off:                     ", fdr_cutf, "\n")
# cat(" max rank:                        ", max_rank, "\n")

#
# Read in the data
#
dat <- read_xml(path_mzml)

# 
# get scan data
#

xml_scans <- dat %>% 
              xml_find_all(".//d1:spectrum")

d_scans <- xml_scans %>% 
              xml_attrs() %>% 
              bind_rows() %>%
              relocate(index) %>%
              rename(scan_index = index)

pb <- progtimer(nrow(d_scans), 'reading mzml file')

d_scan_info <- list()
for( ix in 1:nrow(d_scans) ){

    pb$tick()

    this_sn <- xml_scans[ix]

    d_scan_info[[ix]] <- this_sn %>% xml_find_all("d2:cvParam") %>%
                xml_attrs() %>% 
                bind_rows() %>%
                bind_rows(
                    this_sn %>% xml_find_all("d2:scanList/d2:scan/d2:cvParam") %>% xml_attrs() %>% bind_rows()
                ) %>%
                bind_rows(
                    this_sn %>% xml_find_all("d2:precursorList/d2:precursor/d2:selectedIonList/d2:selectedIon/d2:cvParam") %>% xml_attrs() %>% bind_rows()
                ) %>%
                bind_rows(
                    this_sn %>% xml_find_all("d2:precursorList/d2:precursor/d2:activation/d2:cvParam") %>% xml_attrs() %>% bind_rows()
                ) %>%
                mutate(scan_index = ix) %>%
                relocate(scan_index)
}

d_scan_info <- d_scan_info %>%
                    bind_rows() %>%
                    select(scan_index, name, value) %>%
                    mutate(name = gsub("\\s+|\\-", "_", name)) %>%
                    mutate(name = gsub("\\/", "", name)) %>%
                    filter(grepl("base|ion_|time|title|filter|peak|energy|ms_level|charge", name)) %>%
                    spread(name, value)
                            

saveRDS(d_scan_info, path_rds)
cat(" data written to file ...\n")

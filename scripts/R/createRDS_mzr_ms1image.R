# Jeff Jones
# SoCal Bioinformatics Inc. 2019

rm(list=ls())
library(mzR)
library(tidyverse)
options(warn=-1)
source("mzd/scripts/R/lib/ggmzr.R")

help_text <- "
 NAME
    createRDS_mzr_ms1image.R

 SYNOPSIS
    createRDS_mzr_ms1image.R --mzml=<path_pepmzml> 

 DESCRIPTION
    extract scan data for downstream analysis

 COMMAND LINE

    --mzml <path_pepmzml>

 EXAMPLE

    Rscript createRDS_mzr_ms1image.R --mzml=<path_to.pepmzml>

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
if(is.null(path_mzml)) message <- stop("ERROR\n", "  no mzmzml file declared\n")
if(!grepl(".*ms1.mzml$", path_mzml, ignore.case = T)) message <- paste0(message, "  mz file (--mzml) not a supported format\n")

if(!is.null(message)) stop("ERROR\n", message)

path_png <- sub("\\.ms1.mzml$", ".ms1.image.png", path_mzml)

cat("pepmzml to rds started\n")
cat(" mzml file:                        ", path_mzml, "\n")
cat(" rds file:                         ", path_png, "\n")

#
# Read in the data
#
xml_ms1 <- path_mzml %>% openMSfile()

lc_range <- 'max'
mz_range <- 'max'

p_map <- ggmzr(xml_ms1)

ggsave(path_png, plot=p_map, width=5, height=3)
cat(" image written to                  ", path_png, "\n")

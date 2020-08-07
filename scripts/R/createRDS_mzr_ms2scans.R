# Jeff Jones
# SoCal Bioinformatics Inc. 2019

rm(list=ls())
library(mzR)
library(tidyverse)
options(warn=-1)

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
if(!grepl(".*ms2.mzml$", path_mzml, ignore.case = T)) message <- paste0(message, "  mz file (--mzml) not a supported format\n")
# if(is.null(path_rds))
#     path_rds = paste0(path_mzml, ".rds")
# if(!grepl(".rds$", path_rds)) message <- paste0(message, "  rds file (--rds) not a supported format\n")

if(!is.null(message)) stop("ERROR\n", message)

path_rds <- sub("\\.mzml$", ".rds", path_mzml)

cat("pepmzml to rds started\n")
cat(" mzml file:                        ", path_mzml, "\n")
cat(" rds file:                         ", path_rds, "\n")

#
# Read in the data
#
d_scan_info <- path_mzml %>%
                openMSfile() %>% 
                header() %>% 
                as_tibble() %>%
                select(
                    scan_index = seqNum,
                    acquisition_num = acquisitionNum,
                    ms_level = msLevel,
                    polarity,
                    n_peaks = peaksCount,
                    total_ion_current = totIonCurrent,
                    rt_time_sec = retentionTime,
                    basepeak_mz = basePeakMZ,
                    basepeak_int = basePeakIntensity,
                    collision_energy = collisionEnergy,
                    mz_low = lowMZ,
                    mz_high = highMZ,
                    precursor_scanno = precursorScanNum,
                    precursor_mz = precursorMZ,
                    precursor_z = precursorCharge,
                    precursor_int = precursorIntensity,
                    merged_scan = mergedScan,
                    merged_scan_no = mergedResultScanNum,
                    merged_scan_start = mergedResultStartScanNum,
                    merged_scan_end = mergedResultEndScanNum,
                    ion_injection_time = injectionTime,
                    filter_string = filterString,
                    spectrum_id = spectrumId,
                    centroided,
                    ionmobility_drift_time = ionMobilityDriftTime,
                    isolation_target_mz = isolationWindowTargetMZ,
                    isolation_lower_mz = isolationWindowLowerOffset,
                    isolation_upper_mz = isolationWindowUpperOffset,
                    scan_window_lower_limit = scanWindowLowerLimit,
                    scan_window_upper_limit = scanWindowUpperLimit
                )


saveRDS(d_scan_info, path_rds)
cat(" data written to file ...\n")

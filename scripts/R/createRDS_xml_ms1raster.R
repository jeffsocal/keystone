# Jeff Jones
# SoCal Bioinformatics Inc. 2019

rm(list=ls())
library(xml2)
suppressMessages(library(tidyverse))
options(warn=-1)
source("./R/lib/progtimer.R")

help_text <- "
 NAME
    createRDS_mzml_ms1raster.R

 SYNOPSIS
    createRDS_mzml_ms1raster.R --mzml=<path_pepmzml> --fdr=0.05 --rank=1

 DESCRIPTION
    extract scan data for downstream analysis

 COMMAND LINE

    --mzml <path_pepmzml>

 EXAMPLE

    Rscript createRDS_mzml_ms1raster.R --mzml=<path_to.pepmzml>

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

path_rds <- sub("\\.ms1.mzml$", ".ms1.raster.rds", path_mzml)

cat("pepmzml to rds started\n")
cat(" mzml file:                        ", path_mzml, "\n")
cat(" rds file:                         ", path_rds, "\n")

#
# Read in the data
#
dat <- read_xml(path_mzml)

# 
# get scan data mz & int
#
xml_scans <- dat %>% 
              xml_find_all(".//d1:spectrum")

d_scans <- xml_scans %>% 
              xml_attrs() %>% 
              bind_rows() %>%
              mutate(index = as.numeric(index) + 1) %>%
              relocate(index) %>%
              rename(scan_index = index)

d_traces <- tibble(
                    scan_data = dat %>% 
                    xml_find_all(".//d1:spectrum//d2:binary") %>%
                    xml_text()
                ) %>%
                mutate(
                    trace = rep(c("mz","int"), nrow(d_scans)),
                    index = rep(1:nrow(d_scans), 2) %>% sort(),
                ) 


pb <- progtimer(nrow(d_scans), 'reading mzml file')

d_scan_info <- list()
for( ix in 1:nrow(d_scans) ){

    pb$tick()

    this_sn <- xml_scans[ix]

    d_scan_info[[ix]] <- this_sn %>% xml_find_all("d2:cvParam") %>%
                xml_attrs() %>% 
                bind_rows() %>%
                bind_rows(
                    this_sn %>% xml_find_all("d2:scanList/d2:scan/d2:cvParam") %>% 
                    xml_attrs() %>% bind_rows()
                ) %>%
                mutate(scan_index = ix) %>%
                relocate(scan_index) 
}

d_scan_info <- d_scan_info %>%
                bind_rows() %>%
                select(scan_index, name, value) %>%
                mutate(name = gsub("\\s+", "_", name)) %>%
                mutate(name = gsub("\\/", "", name)) %>%
                spread(name, value) %>%
                mutate(
                    base_peak_intensity = as.numeric(base_peak_intensity),
                    base_peak_mz = as.numeric(base_peak_mz),
                    highest_observed_mz = as.numeric(highest_observed_mz),
                    ion_injection_time = as.numeric(ion_injection_time),
                    lowest_observed_mz = as.numeric(lowest_observed_mz),
                    scan_start_time = as.numeric(scan_start_time) * 60,
                    total_ion_current = as.numeric(total_ion_current)
                )

d_scans <- d_scans %>%
            full_join(d_scan_info, by="scan_index")

d_traces <- d_traces %>%
            spread(trace, scan_data)

mz_range <- c(min(d_scan_info$lowest_observed_mz),
              max(d_scan_info$highest_observed_mz))


pb <- progressbar(nrow(d_scans), 'smooth mz')

spec_int <- list()
spec_mz <- c()
for( ix in 1:nrow(d_scans) ){

    pb$tick()

    t_mz <- d_traces$mz[ix] %>% 
            base64_dec() %>%
            memDecompress(type='gzip') %>%
            readBin("numeric", n=5000)

    t_in <- d_traces$int[ix] %>% 
            base64_dec() %>%
            memDecompress(type='gzip') %>%
            readBin("numeric", n=5000)

    spec <- ksmooth(t_mz, 
                    t_in, 
                    'normal', 
                    n.points=diff(mz_range)*200, 
                    range.x = mz_range, 
                    bandwidth = 0.01)

    spec_mz <- spec$x
    spec_int[[ix]] <- as.integer(floor(spec$y))
  }

spec_mtrx <- matrix(unlist(spec_int), byrow=TRUE, nrow=length(spec_int) )

l_out <- list(
    scan_info = d_scans,
    matrix = spec_mtrx,
    matrix_labels = list(
                        mz = spec_mz,
                        lc = d_scans$scan_start_time
                        )
)

saveRDS(l_out, path_rds)
cat(" data written to                  ", path_rds, "\n")

# Jeff Jones
# SoCal Bioinformatics Inc. 2019

rm(list=ls())
require(xml2)
library(tidyverse)
options(warn=-1)
source("mzd/scripts/R/lib/progtimer.R")

help_text <- "
 NAME
    createRDS_pepxml.R

 SYNOPSIS
    createRDS_pepxml.R --xml=<path_pepxml>

 DESCRIPTION
    extract peptide id data from PeptideProphet pepXML files for downstream analysis

 COMMAND LINE

    --xml <path_pepxml>


 EXAMPLE

    Rscript createRDS_pepxml.R --xml=<path_to.pepXML>

"

###############################################################################
# USER INPUT
path_xml                      <- NULL

for (arg in commandArgs()){
    arg_value <- as.character(sub("--[a-z]*\\=", "", arg))
    if( grepl("--xml", arg) ) path_xml <- arg_value
    if( grepl("--help", arg) ) stop(help_text)
}

###############################################################################
# INPUT VALIDATION
message <- NULL
if(is.null(path_xml)) message <- stop("ERROR\n", "  no pepXML file declared\n")
if(!grepl(".*ms2.pep.xml$", path_xml, ignore.case = T)) message <- paste0(message, "  mz file (--xml) not a supported format\n")

if(!is.null(message)) stop("ERROR\n", message)

path_rds <- sub("\\.xml$", ".rds", path_xml)

cat("pepXML to rds started\n")
cat(" xml file:                        ", path_xml, "\n")
cat(" rds file:                        ", path_rds, "\n")

#
# Read in the data
#
dat <- read_xml(path_xml)

# 
# get scan data
#

xml_scans <- dat %>% 
              xml_find_all(".//d1:spectrum_query")

d_scans <- xml_scans %>% 
              xml_attrs() %>% 
              bind_rows() %>%
              relocate(index) %>%
              rename(scan_index = index)

d_pep <- list()
d_pph <- list()

pb <- progtimer(nrow(d_scans), 'reading xml file')

for ( ix in 1:nrow(d_scans) ) {

    pb$tick()

    this_ix <- xml_scans[ix]
    this_sh <- this_ix %>% xml_find_all(".//d1:search_hit")
    this_sc <- this_ix %>% xml_find_all(".//d1:search_score")
    this_md <- this_ix %>% xml_find_all(".//d1:modification_info")

    rep_m <- length(this_sh)
    rep_n <- length(this_sc) / rep_m

    this_pp <- this_ix %>% xml_find_all(".//d1:peptideprophet_result")
    this_pr <- this_pp %>% xml_find_all(".//d1:parameter")

    #
    # pull out modified peptides
    d_mod <- list()
    for( ish in 1:length(this_sh) ){
        this_md <- this_sh[ish] %>% xml_find_all(".//d1:modification_info")
        if(length(this_md) > 0){
            d_mod[[ish]] <- this_md %>% xml_attrs() %>% bind_rows() %>% mutate(hit_rank = ish)
        }
    }

    d_mod <- d_mod %>% bind_rows()

    #
    # sequence ids, values and  scores
    #
    d_pep[[ix]] <- this_sh %>% 
                       xml_attrs() %>% 
                       bind_rows() %>%
                       bind_cols(
                            this_sc %>% 
                                    xml_attrs() %>% 
                                    bind_rows() %>%
                                    mutate(row_id = rep(1:rep_m, rep_n) %>% sort()) %>% 
                                    mutate(value = as.numeric(value)) %>%
                                    spread(name, value) 
                       ) %>%
                       mutate(scan_index = ix) %>%
                       relocate(scan_index) %>%
                       mutate(hit_rank = as.numeric(hit_rank)) 
                       
    if( nrow(d_mod) > 0 )
        d_pep[[ix]] <- d_pep[[ix]] %>% left_join(d_mod, by="hit_rank")


    if( length(this_pp) == 0)
        next

    rep_m <- length(this_pp)
    rep_n <- length(this_pr) / rep_m

    #
    # peptideProphet values and scores - rank 1 only
    #
    d_pph[[ix]] <- this_pp %>% 
                       xml_attrs() %>% 
                       bind_rows() %>%
                       bind_cols(
                            this_pr %>% 
                                    xml_attrs() %>% 
                                    bind_rows() %>%
                                    mutate(row_id = rep(1:rep_m, rep_n) %>% sort()) %>% 
                                    mutate(value = as.numeric(value)) %>%
                                    spread(name, value) 
                       ) %>%
                       mutate(scan_index = ix)  %>%
                       relocate(scan_index)
                       
}

d_pep <- d_pep %>% 
                bind_rows() %>%
                mutate(num_tot_proteins = as.numeric(num_tot_proteins)) %>%
                mutate(num_matched_ions = as.numeric(num_matched_ions)) %>%
                mutate(calc_neutral_pep_mass = as.numeric(calc_neutral_pep_mass)) %>%
                mutate(massdiff = as.numeric(massdiff)) %>%
                mutate(num_tol_term = as.numeric(num_tol_term)) %>%
                mutate(num_missed_cleavages = as.numeric(num_missed_cleavages)) %>%
                mutate(num_matched_peptides = as.numeric(num_matched_peptides))

d_pph <- d_pph %>% 
                bind_rows()

l_out <- list(
    scans = d_scans,
    peptides = d_pep,
    peptideProphet = d_pph
)

saveRDS(l_out, path_rds)
cat(" data written to                  ", path_rds, "\n")

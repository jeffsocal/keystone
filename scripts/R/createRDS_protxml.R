# Jeff Jones
# SoCal Bioinformatics Inc. 2019

rm(list=ls())
library(xml2)
suppressMessages(library(tidyverse))
options(warn=-1)
source("./R/lib/progtimer.R")

help_text <- "
 NAME
    createRDS_protxml.R

 SYNOPSIS
    createRDS_protxml.R --xml=<path_protxml>

 DESCRIPTION
    extract protein id data from ProteinProphet protxml files for downstream analysis

 COMMAND LINE

    --xml <path_protxml>

 EXAMPLE

    Rscript createRDS_protxml.R --xml=<path_to.protxml>

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
if(is.null(path_xml)) message <- stop("ERROR\n", "  no prot.xml file declared\n")
if(!grepl(".*ms2.prot.XML$", path_xml, ignore.case = T)) message <- paste0(message, "  mz file (--xml) not a supported format\n")
# if(is.null(path_rds))
#     path_rds = paste0(path_xml, ".rds")
# if(!grepl(".rds$", path_rds)) message <- paste0(message, "  rds file (--rds) not a supported format\n")

if(!is.null(message)) stop("ERROR\n", message)

path_rds <- sub("\\.xml$", ".rds", path_xml)

cat("protxml to rds started\n")
cat(" xml file:                        ", path_xml, "\n")
cat(" rds file:                        ", path_rds, "\n")

#
# Read in the data
#
dat <- read_xml(path_xml)

# 
# get protein group data
#

xml_pgroups <- dat %>% 
              xml_find_all(".//d1:protein_group")

d_pgroups <- xml_pgroups %>% 
              xml_attrs() %>% 
              bind_rows() %>%
              mutate(probability = as.numeric(probability))

d_prot <- list()
d_pron <- list()
d_peps <- list()

pb <- progtimer(nrow(d_pgroups), 'reading xml file')

nx <- 0
# iterate through all protein groups
for ( ix in 1:nrow(d_pgroups) ) {

    pb$tick()

    this_ix <- xml_pgroups[ix]
    this_pr <- this_ix %>% xml_find_all(".//d1:protein")

    # data table for the protein group
    d_prot[[ix]] <- this_pr %>% 
                    xml_attrs() %>% 
                    bind_rows()

    for ( ixx in 1:length(this_pr) ) {

        nx <- nx + 1

        this_ixx <- this_pr[ixx]

        v_pd <- this_ixx %>% 
                        xml_find_all(".//d1:annotation") %>% 
                        xml_attr('protein_description')

        v_pn <- this_ixx %>% 
                        xml_attr('protein_name')    

        d_peps[[nx]] <- this_ixx %>% 
                xml_find_all(".//d1:peptide") %>% 
                xml_attrs() %>% 
                bind_rows() %>%
                mutate(protein_name = v_pn)

        d_pron[[nx]] <- tibble(
            protein_name = v_pn,
            protein_description = v_pd
        )

    }
}

d_prot <- d_prot %>% 
                bind_rows() %>%
                mutate(
                    n_indistinguishable_proteins = as.numeric(n_indistinguishable_proteins),
                    probability = as.numeric(probability),
                    percent_coverage = as.numeric(percent_coverage),
                    total_number_peptides = as.numeric(total_number_peptides),
                    total_number_distinct_peptides = as.numeric(total_number_distinct_peptides),
                    pct_spectrum_ids = as.numeric(pct_spectrum_ids),
                    confidence = as.numeric(confidence)
                )

d_peps <- d_peps %>% 
                bind_rows() %>%
                mutate(
                    charge = as.numeric(charge),
                    initial_probability = as.numeric(initial_probability),
                    nsp_adjusted_probability = as.numeric(nsp_adjusted_probability),
                    fpkm_adjusted_probability = as.numeric(fpkm_adjusted_probability),
                    weight = as.numeric(weight),
                    n_sibling_peptides = as.numeric(n_sibling_peptides),
                    calc_neutral_pep_mass = as.numeric(calc_neutral_pep_mass)
                )

d_pron <- d_pron %>% bind_rows()

l_out <- list(
    proteins = d_prot,
    peptides = d_peps,
    protein_names = d_pron
)

saveRDS(l_out, path_rds)
cat(" data written to                  ", path_rds, "\n")

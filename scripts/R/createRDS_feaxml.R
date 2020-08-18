# Jeff Jones
# SoCal Bioinformatics Inc. 2019

rm(list=ls())
require(xml2)
library(tidyverse)
options(warn=-1)

help_text <- "
 NAME
    createRDS_feaxml.R

 SYNOPSIS
    createRDS_feaxml.R --xml=<path_featureXML>

 DESCRIPTION
    extract features from OpenMS::FeatureFinderCentroided

 COMMAND LINE

    --xml <path_featureXML>

 EXAMPLE

    Rscript createRDS_feaxml.R --xml=<path_to.featureXML>

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
if(is.null(path_xml)) message <- stop("ERROR\n", "  no mzXML file declared\n")
if(!grepl(".fea.*XML$", path_xml, ignore.case = T)) message <- paste0(message, "  mz file (--xml) not a supported format\n")

if(!is.null(message)) stop("ERROR\n", message)

path_rds <- sub("\\.fea.*XML$", ".fea.rds", path_xml)

cat("featureXML to rds started\n")
cat(" xml file:                        ", path_xml, "\n")
cat(" rds file:                        ", path_rds, "\n")

#
# Read in the data
#
cat(" reading xml file ...")
dat <- read_xml(path_xml)


pair_lcmz <- dat %>% xml_find_all(".//position") %>% xml_double() %>% split( c("lc", "mz"))
pair_quality <- dat %>% xml_find_all(".//quality") %>% xml_double() %>% split( c("lc", "mz"))

d_features <- tibble(
    elution_sec = pair_lcmz[[1]], 
    mass_charge = pair_lcmz[[2]],
    charge = dat %>% xml_find_all(".//charge") %>% xml_integer(),
    intensity = dat %>% xml_find_all(".//intensity") %>% xml_double(),
    quality_overall = dat %>% xml_find_all(".//overallquality") %>% xml_double(),
    quality_elution_sec = pair_quality[[1]], 
    quality_mass_charge = pair_quality[[2]],
)

d_feature_qual <- dat %>% 
          xml_find_all(".//feature/UserParam") %>% 
          xml_attrs() %>% 
          bind_rows() %>%
          mutate(index = rep(1:nrow(d_features), 6) %>% sort()) %>%
          select(index, name, value) %>%
          spread(name, value)

d_fea <- d_features %>%
                    bind_cols(d_feature_qual) %>% 
                    select(-index)


cat("\n")
saveRDS(d_fea, path_rds)
cat(" data written to file ...\n")

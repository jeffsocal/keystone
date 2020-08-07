# Jeff Jones
# SoCal Bioinformatics Inc. 2019

rm(list=ls())
library(mzR)
library(tidyverse)

file_path <- "../../data"
file_name <- "yeast_ltqo_061220_000"

m_ms1 <- paste0(file_path, "/", 
                file_name, "/", 
                file_name, "ms1.mzml") %>%
    openMSfile()


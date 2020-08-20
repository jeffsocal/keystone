# Jeff Jones
# SoCal Bioinformatics Inc. 2019
#
# 
options(warn=-1)

help_text <- "
 NAME
    map_ms1features_ms2scans.R

 SYNOPSIS
    map_ms1features_ms2scans.R --ref=<path_ms1.fea.rds> --scn=<path_ms2.rds>

 DESCRIPTION
    cluster ids with ms1 features so that accounting of search 
    utility (how many features were id'd) can be assessed, etc.

 COMMAND LINE

    --ref <path to ms1 features> \
    --scn <path to ms2 scans> \
    --mztol <tolerance_mz_daltons> \          # m/z clustering tolerance (default: 0.1 daltons)
    --lctol <tolerance_rt_sec> \              # rt clustering tolerance (default: 10 sec)
    --chunk <data_segments>                   # data segmenting for large files (default: 64)

 EXAMPLE

    Rscript pepxml2csv.R --xml=<path_to.pepXML>

 DEPENDS ON 
   github.com/jeffsocal/annealer

   set docker -v path_to_annealer:/annealer
   --exp='/annealer'
"

###############################################################################
# USER INPUT
outf <- fea_df <- scn_df        <- NULL
mz_tol                          <- 0.05          	# in daltons
lc_tol  		                    <- 120       	   # in seconds
cs_tol  		                    <- 0            	# no tolerance on charge state
cpu_cores		                 <- 1
chunk_size		                 <- 64
exe_path                        <- "."

for (arg in commandArgs()){
    arg_value <- as.character(sub("--[a-z]*\\=", "", arg))
    if( grepl("--ref", arg) ) fea_df <- arg_value
    if( grepl("--scn", arg) ) scn_df <- arg_value
    if( grepl("--chunk", arg) ) chunk_size <- arg_value
    if( grepl("--exp", arg) ) exe_path <- arg_value
    if( grepl("--cpu", arg) ) cpu_cores <- arg_value
    if( grepl("--help", arg) ) stop(help_text)
}

source(paste0(exe_path, "/lib/input.R"))
source(paste0(exe_path, "/lib/cdist.R"))
source(paste0(exe_path, "/lib/pwdelta.R"))
source(paste0(exe_path, "/lib/mzedelta.R"))
source(paste0(exe_path, "/lib/mzemap.R"))
###############################################################################
# INPUT VALIDATION
message <- NULL
if(is.null(fea_df)) message <- paste0(message, "  no reference file declared\n")
if(is.null(scn_df)) message <- paste0(message, "  no cluster file declared\n")

if(!is.null(message)) stop("ERROR\n", message)

if(!file.exists(fea_df)) message <- paste0(message, "  reference file (--nf) not found\n")
if(!file.exists(scn_df)) message <- paste0(message, "  cluster file (--mf) not found\n")
if(!grepl("rds|csv$", fea_df)) message <- paste0(message, "  reference file (--mf) not a supported format\n")
if(!grepl("rds|csv$", scn_df)) message <- paste0(message, "  cluster file (--mf) not a supported format\n")

if(!is.null(message)) stop("ERROR\n", message)

cat("cluster ms1-ms2 started\n")
cat(" reference file:                  ", fea_df, "\n")
cat(" cluster file:                    ", scn_df, "\n")

path_rds <- sub("\\..*$", ".msn.map.rds", fea_df)

###############################################################################
# FUNCTION: cluster based on a 2d value coordinate

cat(" mapping ... \n")

out_df <- mzemap(
    tables = list(
        reference = readData(fea_df),
        multiples = readData(scn_df)),
    mz_tol  = mz_tol,
    lc_tol  = lc_tol,
    cs_tol  = cs_tol,
    chunk_size = chunk_size,
    cores = cpu_cores
) 

saveData(out_df, path_rds)

cat(" data written to                  ", path_rds, "\n")


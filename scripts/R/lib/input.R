# Jeff Jones
# SoCal Bioinformatics Inc. 2019
#
# read and merge data

bigData <- function(file_paths = NULL, message = "merging data"){
  df <- c()
  pb <- progressbar(length(file_paths), message)
  for( this_file_path in file_paths ){
    pb$tick()
    df <- df %>% bind_rows(this_file_path %>% readRDS())
  }
  return(df)
}
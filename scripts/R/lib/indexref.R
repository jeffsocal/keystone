# Jeff Jones
# SoCal Bioinformatics Inc. 2019
#
# progress timer wrapper

# create an index reference
indexref <- function(df, string = 'index_'){
    df_n <- ceiling(log10(df %>% nrow()))
    df <- df %>%
        mutate(index_ref = paste0(string, str_pad(row_number(), df_n, "left","0")))
}
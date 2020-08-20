# Jeff Jones
# SoCal Bioinformatics Inc. 2019
#
# create 3d images of lcms data from an mzml

suppressMessages(library(tidyverse, mzr))

ggmzr <- function(o_mzr,
                  lc_range = 'max',
                  mz_range = 'max',
                  denoise = 5e-4,
                  pxl_mz = 512,
                  pxl_lc = 1024){
    
    d_ms1 <- o_mzr %>% 
        header() %>% 
        as_tibble() 
    
    if( lc_range == 'max' )
        lc_range = range(d_ms1$retentionTime)
    
    if( mz_range == 'max' )
        mz_range = range(d_ms1$lowMZ, d_ms1$highMZ)
    
    max_int <- d_ms1$basePeakIntensity %>% max()
    
    d_ms1 <- d_ms1 %>%
        filter(retentionTime >= min(lc_range) & retentionTime <= max(lc_range))
    
    m_map <- get3Dmap(o_mzr, 
                      scans = d_ms1$seqNum, 
                      lowMz = min(mz_range), 
                      highMz = max(mz_range), 
                      resMz = diff(mz_range) / pxl_mz)
    
    v_rt <- d_ms1$retentionTime
    rt_range <- range(v_rt)
    
    n_map <- matrix(nrow = pxl_lc, ncol=ncol(m_map))
    for ( i in 1:ncol(m_map) ){
        
        spec <- ksmooth(v_rt, 
                        m_map[,i], 
                        'normal', 
                        n.points= pxl_lc, 
                        range.x = rt_range, 
                        bandwidth = 6)
        n_map[,i] <- spec$y
    }
    
    
    n_map[1,1] <- max_int
    wna <- which(is.na(n_map))
    n_map[wna] <- 0
    n_map <- n_map - denoise*max(n_map)
    wna <- which(n_map < 2)
    n_map[wna] <- 1
    n_map <- log2(n_map)
    
    d_map <- n_map %>%
        as.data.frame() %>%
        mutate(lc = spec$x) 
    
    cnames <- as.character(
        1:(ncol(d_map)-1) * 
            ( (diff(mz_range)) / (ncol(d_map)-1) ) + 
            min(mz_range)
    )
    colnames(d_map) <- c(cnames, 'lc')
    
    d_map <- d_map %>%
        gather(all_of(cnames), key="mz", value="int") %>%
        as_tibble() %>%
        mutate(mz = as.numeric(mz)) 
    
    p_map <- d_map %>%
        ggplot() +
        geom_raster(aes(mz, lc, fill=int), interpolate = T) +
        scale_fill_gradientn(colors=c('#000010', '#000030', '#00007F', '#0000FF', '#007FFF', '#00FFFF',
                                      '#7FFF7F', '#FFFF00', '#FF7F00','#FF0000','#7F0000')) +
        theme(
            axis.line=element_blank(),
            axis.text.x=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            legend.position = 'NA',
            panel.background=element_blank(),
            panel.border=element_blank(),
            panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),
            plot.background=element_blank(),
            axis.ticks.length = unit(0, "mm"),
            panel.spacing = unit(0, "cm"),
            plot.margin = margin(0, 0, 0, 0, "cm")) +
        scale_x_continuous(expand = c(0, 0)) +
        scale_y_continuous(expand = c(0, 0))
    
    return(p_map)
}
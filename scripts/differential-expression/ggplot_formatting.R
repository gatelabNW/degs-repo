# Natalie Piehl
# Gate Lab
# Northwestern University
# October 25, 2021
# 
# Hold convenient plotting functions for ggplot2 objects
# Functions from Emma Tapp at Stanford University
# 
#################################################################################################################
library(ggplot2)
library(ggrepel)
library(ggthemes)
library(grid)
# Create publication theme plotting function
theme_Publication_blank <- function(base_size=12, base_family="") { #12 For ALDR paper
  require(grid)
  require(ggthemes)
  (theme_foundation(base_size=base_size, base_family=base_family)
    + theme(plot.title = element_text(size = rel(1.2), hjust = 0.5),
            text = element_text(),
            panel.background = element_rect(fill = "transparent",colour = NA),
            plot.background = element_rect(fill = "transparent",colour = NA),
            panel.border = element_rect(colour = NA, fill = "transparent"),
            axis.title = element_text(size = rel(1)),
            axis.title.y = element_text(angle=90,margin=margin(0,10,0,0)),
            axis.title.x = element_text(margin=margin(10,0,0,0)),
            axis.text = element_text(), 
            axis.line = element_line(colour="black"),
            axis.ticks = element_line(size = 0.3),
            axis.line.x = element_line(size = 0.3, linetype = "solid", colour = "black"),
            axis.line.y = element_line(size = 0.3, linetype = "solid", colour = "black"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            legend.key = element_rect(colour = NA, fill="transparent"),
            legend.position = "bottom",
            #legend.direction = "horizontal",
            #legend.box = "horizontal",
            #legend.key.size= unit(0.2, "cm"),
            legend.margin = unit(10, "pt"),
            #legend.title = element_text(face="italic"),
            plot.margin=unit(c(10,5,5,5),"mm"),
            strip.background=element_rect(colour="#d8d8d8",fill="#d8d8d8")
            # strip.text = element_text(face="bold")
    ))
  
} 

# Create panel size setting function
set_panel_size <- function(p=NULL, g=ggplotGrob(p), file=NULL, 
                           margin = unit(1,"mm"),
                           width=unit(7, "inch"), 
                           height=unit(5, "inch")){
  
  panels <- grep("panel", g$layout$name)
  panel_index_w<- unique(g$layout$l[panels])
  panel_index_h<- unique(g$layout$t[panels])
  nw <- length(panel_index_w)
  nh <- length(panel_index_h)
  
  if(getRversion() < "3.3.0"){
    
    # the following conversion is necessary
    # because there is no `[<-`.unit method
    # so promoting to unit.list allows standard list indexing
    g$widths <- grid:::unit.list(g$widths)
    g$heights <- grid:::unit.list(g$heights)
    
    g$widths[panel_index_w] <-  rep(list(width),  nw)
    g$heights[panel_index_h] <- rep(list(height), nh)
    
  } else {
    
    g$widths[panel_index_w] <-  rep(width,  nw)
    g$heights[panel_index_h] <- rep(height, nh)
    
  }
  
  if(!is.null(file))
    ggplot2::ggsave(file %>% gsub('%', '%%', .), g,
                    width = convertWidth(sum(g$widths) + margin,
                                         unitTo = "in", valueOnly = TRUE),
                    height = convertHeight(sum(g$heights) + margin,
                                           unitTo = "in", valueOnly = TRUE), useDingbats=F)
  
  invisible(g)
}
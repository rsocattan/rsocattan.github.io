



library(tis)
library(cowplot)
library(readxl)
library(xlsx)
library(urca)
library(dynlm)

library(heatmaply)
library(kableExtra)
library(reshape)
library(reshape2)
library(plotly)

library(Hmisc)
library(dplyr)
require(gridExtra)
library(tibble)

library(hrbrthemes)
library(viridis)
library(plotly)
#library(d3heatmap)

require(gplots)
require(RColorBrewer)
require(heatmaply)
library(data.table)
library(ggplot2)
library(magrittr)
library(plyr)
library(ggpubr)

library(tidyverse)
library(ggraph)
library("ggplot2")
library("plyr")
library("scales")
library("likert")
library("ggsci")
library("sfcr")



# the data
knitr::opts_chunk$set(echo=TRUE)
load(paste0(getwd(),"/SNADATA.RData"))

getwd()

#PLOTS

# SANKEY RSC-----

RESOURCES2<-RESOURCES

#TRANSFERS
#lapply(FLOWS, function(x) which(x$governo<0))
TRANSFERS<-RESOURCES2$PENS_ADJ+RESOURCES2$CASH_TRANSF +RESOURCES2$OTHER_TRANSF+RESOURCES2$SOC_BEN+RESOURCES2$CONT_SOC_EMP


#TAXES
#lapply(FLOWS, function(x) which(x$governo>0))
TAXES<-RESOURCES2$SOC_CONT+RESOURCES2$INC_WEALTH_TX+RESOURCES2$NET_TY 



# WEALTH
RESOURCES2$IED_profits$Years<-seq(2000,2017)
WEALTH<-RESOURCES2$DIVIDENDS+ RESOURCES2$DESEMB_FBKF+RESOURCES2$NAT_RESOURCE +RESOURCES2$IED_profits





#OTHERS
OTHERS<-RESOURCES2$K_TRANSD+RESOURCES2$NET_K_TRANS +RESOURCES2$PENS_ADJ

#merging
RESOURCES2$TRANSFERS<-TRANSFERS
RESOURCES2$WEALTH <-WEALTH
RESOURCES2$OTHERS<-OTHERS
RESOURCES2$TAXES<-TAXES


# EXPORTs
RESOURCES2$EXPORTS$firmas<-RESOURCES2$EXPORTS$total


#PLOTTING
# renaming subcols
for(i in 1:length(RESOURCES2)){
  
  colnames(RESOURCES2[[i]])<-c("Total",
                              "Goods",
                              "RoW",
                              "Domestic",
                              "Government",
                              "Banks",
                              "Firms",
                              "Households",
                              "Years")
  
  
}





noshow<-c("Total",
          "Goods",
          "Domestic",
          "Years")


cats<-c("EXPORTS",
        "MPORTS",
        # "INVESTMENT",
        #  "CONSUMPTION",
        "GDP",
        "WAGES",
        "INTERESTS",
        "TRANSFERS",
        "TAXES",
        "WEALTH",
        "OTHERS")




links2<-data.frame(lapply(RESOURCES2, function(x) x[18,]) %>%
                     
                     reshape::melt() %>%
                     
                     filter(variable %nin% noshow) %>%
                     
                     filter(L1 %in% cats)%>%
                     
                     filter(!value=="0") %>%
                     
                     mutate(source=L1,
                            target=variable) %>%
                     
                     select(source,target, value))





# From these flows we need to create a node data frame: it lists every entities involved in the flow
nodes2 <- data.frame(
  name=c(as.character(colnames(RESOURCES2$EXPORTS)[c(3,5,6,7,8)]), 
         as.character(cats)) %>% unique()
)



# With networkD3, connection must be provided using id, not using real name like in the links dataframe.. So we need to reformat it.
links2$IDsource <- match(links2$source, nodes2$name)-1 
links2$IDtarget <- match(links2$target, nodes2$name)-1




plot_ly(
  type = "sankey",
  arrangement = "snap",
  node = list(
    label = nodes2$name,
    pad = 10), # 10 Pixel
  link = list(
    source = links2$IDsource,
    target = links2$IDtarget,
    value = links2$value))










# SANKEY USES -----
# USES
USES2<-USES


#TRANSFERS
#lapply(FLOWS, function(x) which(x$governo<0))
TRANSFERS<-USES2$PENS_ADJ+USES2$CASH_TRANSF +USES2$OTHER_TRANSF+USES2$SOC_BEN+USES2$CONT_SOC_EMP


#TAXES
#lapply(FLOWS, function(x) which(x$governo>0))
TAXES<-USES2$SOC_CONT+USES2$INC_WEALTH_TX+USES2$NET_TY 



# WEALTH
USES2$IED_profits$Years<-seq(2000,2017)
WEALTH<-USES2$DIVIDENDS+ USES2$DESEMB_FBKF+USES2$NAT_RESOURCE +USES2$IED_profits





#OTHERS
OTHERS<-USES2$K_TRANSD+USES2$NET_K_TRANS +USES2$PENS_ADJ

#merging
USES2$TRANSFERS<-TRANSFERS
USES2$WEALTH <-WEALTH
USES2$OTHERS<-OTHERS
USES2$TAXES<-TAXES


# TRADE
USES2$EXPORTS$row <-USES2$EXPORTS$total
USES2$MPORTS$firmas<-USES2$MPORTS$total



#PLOTTING
# renaming subcols
for(i in 1:length(USES2)){
  
  colnames(USES2[[i]])<-c("Total",
                              "Goods",
                              "RoW",
                              "Domestic",
                              "Government",
                              "Banks",
                              "Firms",
                              "Households",
                              "Years")
  
  
}



lapply(USES2,function(x) colnames(x))

noshow<-c("Total",
          "Goods",
          "Domestic",
          "Years")


cats2<-c("EXPORTS",
        "MPORTS",
         "INVESTMENT",
          "CONSUMPTION",
      #  "GDP",
        "WAGES",
        "INTERESTS",
        "TRANSFERS",
        "TAXES",
        "WEALTH",
        "OTHERS")




links3<-data.frame(lapply(USES2, function(x) x[18,]) %>%
                     
                     reshape::melt() %>%
                     
                     filter(variable %nin% noshow) %>%
                     
                     filter(L1 %in% cats2)%>%
                     
                     filter(!value=="0") %>% 
                     
                     mutate(source=variable,
                            target=L1) %>%
                     
                     select(source,target, value))






# From these flows we need to create a node data frame: it lists every entities involved in the flow
nodes3 <- data.frame(
  name=c(as.character(cats2),
         as.character(colnames(USES2$EXPORTS)[c(3,5,6,7,8)])
         ) %>% unique()
)



# With networkD3, connection must be provided using id, not using real name like in the links dataframe.. So we need to reformat it.
links3$IDsource <- match(links3$source, nodes3$name)-1 
links3$IDtarget <- match(links3$target, nodes3$name)-1



plot_ly(
  type = "sankey",
  arrangement = "snap",
  node = list(
    label = nodes3$name,
    pad = 10), # 10 Pixel
  link = list(
    source = links3$IDsource,
    target = links3$IDtarget,
    value = links3$value))






#SANKEY BIND -----

# BINDING

links3a<-links3

links3a$target<-paste0(links3$target,".U")

links4<-rbind(links2,links3a)[,c(1:3)]

links

# With networkD3, connection must be provided using id, not using real name like in the links dataframe.. So we need to reformat it.
links4$IDsource <- match(links4$source, c(nodes2$name,
                                          nodes3$name,
                                          links3a$target))-1 
links4
links4$IDtarget <- match(links4$target, c(nodes2$name,
                                          nodes3$name,
                                          links3a$target))-1



# reescaling second targets
links4$IDtarget[31:nrow(links4)]<-as.numeric(links4$target[31:nrow(links4)])+4


# renaming target cols

links4$target<- sub(".U","",links4$target)

 

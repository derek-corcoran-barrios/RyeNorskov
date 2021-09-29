library(tidyverse)
library(sf)

RyeNoskov <- read_sf("ShapeFiles/RyeNoerskov.shp") %>% 
  st_transform(crs = "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs")

Sites <- read_sf("Sampling/Experimental.shp")

ggplot() + geom_sf(data = RyeNoskov) + geom_sf(data =Sites, aes(color = Class))

library(stars)


Classes <- readRDS("FinalStack.rds") 

Classes <- Classes %>% 
  st_as_stars() %>% 
  stars::st_contour() %>% 
  sf::st_cast(to = "MULTILINESTRING") %>% 
  st_as_sf(crs = raster::projection(ClassRaster))

Squares <- Sites %>% st_buffer(dist = 7.5, endCapStyle = "SQUARE")

ggplot() + geom_sf(data = Classes, aes(color = vegetation_density)) + geom_sf(data = Squares, aes(color = Class))




Squares <- Squares %>% group_split(Class)


AllData <- list()

Nums <- c(4,4,4)

for(x in 1:3){
  Test <- st_distance(Squares[[x]], Squares[[x]]) %>% 
    as.matrix()
  
  
  Test <- Test %>% 
    as.data.frame() %>% 
    mutate_all(as.numeric) %>% 
    tibble::rowid_to_column() 
  
  
  Test$ID <- Squares[[x]] %>% pull(ID)
  
  Test <- Test %>% relocate(ID, .before = everything()) 
  
  Test[Test == 0] <- NA
  
  Mins <- apply(Test[,-c(1,2)],1,min,na.rm=TRUE)
  
  First <- Test$ID[Mins == max(Mins)]
  
  AllData[[x]] <- Squares[[x]] %>% 
    mutate(Rank = NA, Rank = as.numeric(Rank)) %>% 
    tibble::rowid_to_column() %>% 
    relocate(rowid, .before = everything())
  
  AllData[[x]]$Rank <- ifelse(AllData[[x]]$ID == First, 1, NA)
  
  ToRank <- Nums[x]
  
  Dist <- Test[,-c(1,2)]
  
  for(i in 1:ToRank){
    Used <- AllData[[x]] %>% dplyr::filter(!is.na(Rank)) %>% pull(rowid)
    Unused <- AllData[[x]] %>% dplyr::filter(is.na(Rank)) %>% pull(rowid)
    
    Temp <- Dist[Used, Unused]
    rownames(Temp) <- Used
    colnames(Temp) <- Unused
    
    dmax <- max(apply(Temp,2,min,na.rm=TRUE))
    
    Cond <- which(Temp == dmax, arr.ind = TRUE)[1,] %>% as.numeric()
    
    AllData[[x]]$Rank <- ifelse(AllData[[x]]$rowid == Unused[Cond[2]], (i + 1), AllData[[x]]$Rank)
    print(paste(i, "of", ToRank, ", distance =", dmax))
  }
  
  AllData[[x]] <- dplyr::filter(AllData[[x]], !is.na(Rank))
  
}



AllData <- AllData %>% reduce(bind_rows)

ggplot() + geom_sf(data =AllData, aes(color = Class))

Classes <- Classes %>% st_transform(crs = st_crs(AllData))


Adds <- list(c(15,0), c(0,15), c(-15,0), c(0,-15))

Areas <- list()

for(i in 1:nrow(AllData)){
  Temp <- AllData[i,]
  Centroid <- st_centroid(Temp)
  Tb_sfc = st_geometry(Centroid)
  
  x = 0
  
  while (x <= 0) {
    Tb_shift_circle = Tb_sfc + Adds[[sample(1:4, 1)]]
    Tb_shift_circle = st_as_sf(Tb_shift_circle, crs = st_crs(Temp)) %>% 
      st_buffer(dist = 5) %>% 
      rename(geometry = x)
    x = min(c(min(as.numeric(st_distance(Tb_shift_circle, Classes))), as.numeric(st_distance(Tb_shift_circle, Temp))))
  }
  
  CopyColumns <- Temp %>% as.data.frame() %>% dplyr::select(-geometry)
  Tb_shift_circle <- Tb_shift_circle %>% cbind(CopyColumns)
  Areas[[i]] <- rbind(Temp, Tb_shift_circle)
  CopyColumns <- Areas[[i]] %>% as.data.frame() %>% dplyr::select(-geometry) %>% dplyr::distinct()
  Areas[[i]] <- Areas[[i]] %>% st_union() %>% st_as_sf(crs = st_crs(AllData))
  Areas[[i]] <- Areas[[i]] %>% cbind(CopyColumns)
}

Areas <- Areas %>% reduce(rbind)

sf::write_sf(Areas, "Sampling/Ranked.shp")

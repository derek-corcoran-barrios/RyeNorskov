RyeNoskov <- read_sf("ShapeFiles/RyeNoerskov.shp") %>% 
  st_transform(crs = "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs")

Sites <- read_sf("Sampling/Experimental.shp")

ggplot() + geom_sf(data = RyeNoskov) + geom_sf(data =Sites, aes(color = Class))

Squares <- Sites %>% st_buffer(dist = 20, endCapStyle = "SQUARE")

plot(Squares)

SquaresA <- Squares %>% dplyr::filter(Class == "A")

plot(SquaresA["ID"])

plot(SquaresA["Class"])


Test <- st_distance(dplyr::filter(Sites, Class == "A"), Sites) %>% 
  as.matrix()

Test[lower.tri(Test, diag = T)] <- NA



Test <- Test %>% 
  as.data.frame() %>% 
  mutate_all(as.numeric) %>% 
  tibble::rowid_to_column() %>% 
  dplyr::select(-V1)

Test$ID <- dplyr::filter(Sites, Class == "A") %>% pull(ID)

Test <- Test %>% relocate(ID, .before = everything()) 

Mins <- apply(Test[,-1],1,min,na.rm=TRUE)

First <- Test$rowid[Mins == max(Mins)]

AllData <- dplyr::filter(Sites, Class == "A") %>% mutate(Rank = NA, Rank = as.numeric(Rank))

ToRank <- 4

for(i in 1:ToRank){
  Used <- AllData %>% dplyr::filter(!is.na(Rank)) %>% pull(rowid)
  Unused <- AllData %>% dplyr::filter(is.na(Rank)) %>% pull(rowid)
  
  Temp <- Dist[Used, Unused]
  rownames(Temp) <- Used
  colnames(Temp) <- Unused
  
  dmax <- max(apply(Temp,2,min,na.rm=TRUE))
  
  Cond <- which(Temp == dmax, arr.ind = TRUE)[1,] %>% as.numeric()
  
  AllData$Rank <- ifelse(AllData$rowid == Unused[Cond[2]], (i + 1), AllData$Rank)
  AllData$Dataset <- ifelse(AllData$rowid == Unused[Cond[2]], "Ranked", AllData$Dataset)
  print(paste(i, "of", ToRank, ", distance =", dmax))
}

## Load packages

library(raster)
library(sf)

## Read in shapefiles to crop and mask

RyeNoskov <- read_sf("ShapeFiles/RyeNoerskov.shp") %>% st_transform(crs = "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs")

VegDens <- list.files(path = "O:/Nat_Ecoinformatics-tmp/au634851/dk_lidar_backup_2021-06-28/vegetation_density", pattern = "vrt", full.names = T) %>% 
  raster() %>% 
  crop(RyeNoskov) %>% 
  mask(RyeNoskov)

canopy_height <- list.files(path = "O:/Nat_Ecoinformatics-tmp/au634851/dk_lidar_backup_2021-06-28/canopy_height", pattern = "vrt", full.names = T) %>% 
  raster() %>% 
  crop(RyeNoskov) %>% 
  mask(RyeNoskov)

openness_mean <-  list.files(path = "O:/Nat_Ecoinformatics-tmp/au634851/dk_lidar_backup_2021-06-28/openness_mean", pattern = "vrt", full.names = T) %>% 
  raster() %>% 
  crop(RyeNoskov) %>% 
  mask(RyeNoskov)

TWI <-  list.files(path = "O:/Nat_Ecoinformatics-tmp/au634851/dk_lidar_backup_2021-06-28/twi", pattern = "vrt", full.names = T) %>% 
  raster() %>% 
  crop(RyeNoskov) %>% 
  mask(RyeNoskov)

Vars <- stack(VegDens, canopy_height, openness_mean, TWI)

Vars <- readAll(Vars)

saveRDS(Vars, "Variables.rds")

 

Site selection for Rye Nørskov
================

## Datasets to be used

In order to include Vegetation complexity and wetness in the
startification the following layers were used:

  - vegetation height
    (“O:/Nat\_Ecoinformatics-tmp/au634851/dk\_lidar\_backup\_2021-06-28/canopy\_height”)
  - vegetation density
    (“O:/Nat\_Ecoinformatics-tmp/au634851/dk\_lidar\_backup\_2021-06-28/vegetation\_density”)
  - vegetation openness
    ("“O:/Nat\_Ecoinformatics-tmp/au634851/dk\_lidar\_backup\_2021-06-28/openness\_mean”)
  - TWI
    ("“O:/Nat\_Ecoinformatics-tmp/au634851/dk\_lidar\_backup\_2021-06-28/twi”)

Which resulted in this stack

![](README_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

## Packages used

The `raster` package was used for layer processing, sf for managing
shapefiles and the package `GeoStratR` was used for the stratification
of the site,

## Raster preparation

The preparation of rasters was made in the ‘Prepare\_rasters.r’ in order
to get all the rasters in the same resolution and crs

## Stratification

The `Stratify` function from GeoSratR was used in order to test the best
stratification from 2 to 10 groups, with the following results

In the graph bellow we can see that the number of classes that best
captures the variablity is 3 as seen in the following graph

![](README_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

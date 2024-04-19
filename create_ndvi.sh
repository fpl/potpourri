#!/bin/sh
# 
# A quick and dirty script to generate L8 NDVI in batch starting from
# uncompress directories.
# NDVI = (B5-B4)/(B5+B4)
#

for i in LC*00
do
	gdalbuildvrt -separate ${i}/${i}.vrt ${i}/${i}_B4.TIF $i/${i}_B5.TIF
	pkndvi -i ${i}/${i}.vrt -o ${i}/${i}.ndvi -b 0 -b 1 -r ndvi -min -1 -max 1 -of ENVI -ot Float32
done


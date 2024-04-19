#! /usr/bin/python
# 
# This simple script is derived from rgb2pct.py
# The only difference is that it does not apply dithering to the initial
# image, so its use is limited to the case when # colors << 65535, tipically
# even << 256.
#

try:
    from osgeo import gdal
except ImportError:
    import gdal

import sys
import os.path
import numpy as np

def Usage():
    print('Usage: rgb2idx.py suource_file dest_file')
    sys.exit(1)

def rgb2idx ( r,g,b,im,ct ):
    red = r.ReadAsArray(0,0,r.XSize,r.YSize)
    green = g.ReadAsArray(0,0,g.XSize,g.YSize)
    blue = b.ReadAsArray(0,0,b.XSize,b.YSize)
    _im = im.ReadAsArray(0,0,im.XSize,im.YSize)
    ar = np.array(red.tolist())
    ag = np.array(green.tolist())
    ab = np.array(blue.tolist())
    _r = ar.flatten()
    _g = ag.flatten()
    _b = ab.flatten()
    rset = set(_r)
    bset = set(_b)
    gset = set(_g)
    ctsize = len(rset)*len(bset)*len(gset)
    print "Max color table size: ", ctsize
    idx = {}
    for v in range(r.YSize):
        for u in range(r.XSize):
            idx[red[v,u] << 16 | green[v,u] << 8 | blue[v,u]] = 1
    i = 0
    for col in idx:
       idx[col] = i+1
       i = i+1
    for v in range(r.YSize):
        for u in range(r.XSize):
            _im[v,u] = idx[red[v,u] << 16 | green[v,u] << 8 | blue[v,u]]
    im.WriteArray(_im)

    for col in idx:
        cb = int(col & 0x0000FF)
        cg = int(col & 0x00FF00)>>8
        cr = int(col & 0xFF0000)>>16
        print idx[col],": ",cr,cg,cb
        ct.SetColorEntry(idx[col],(cr,cg,cb,255))

color_count = 256
format = 'GTiff'
src_filename = None
dst_filename = None

gdal.AllRegister()
argv = gdal.GeneralCmdLineProcessor( sys.argv )
if argv is None:
    sys.exit( 0 )

# Parse command line arguments.
i = 1
while i < len(argv):
    arg = argv[i]

    if src_filename is None:
        src_filename = argv[i]
    elif dst_filename is None:
        dst_filename = argv[i]
    else:
        Usage()

    i = i + 1

if dst_filename is None:
    Usage()
    
# Open source file

src_ds = gdal.Open( src_filename )
if src_ds is None:
    print('Unable to open %s' % src_filename)
    sys.exit(1)

if src_ds.RasterCount < 3:
    print('%s has %d band(s), need 3 for inputs red, green and blue.' \
          % (src_filename, src_ds.RasterCount))
    sys.exit(1)

# Ensure we recognise the driver.

dst_driver = gdal.GetDriverByName(format)
if dst_driver is None:
    print('"%s" driver not registered.' % format)
    sys.exit(1)

# Generate palette

ct = gdal.ColorTable()

# Create the working file.  We have to use TIFF since there are few formats
# that allow setting the color table after creation.

if format == 'GTiff':
    tif_filename = dst_filename
else:
    import tempfile
    tif_filedesc,tif_filename = tempfile.mkstemp(suffix='.tif')

gtiff_driver = gdal.GetDriverByName( 'GTiff' )

tif_ds = gtiff_driver.Create( tif_filename,
                              src_ds.RasterXSize, src_ds.RasterYSize, 1)


# ----------------------------------------------------------------------------
# We should copy projection information and so forth at this point.

tif_ds.SetProjection( src_ds.GetProjection() )
tif_ds.SetGeoTransform( src_ds.GetGeoTransform() )
if src_ds.GetGCPCount() > 0:
    tif_ds.SetGCPs( src_ds.GetGCPs(), src_ds.GetGCPProjection() )

# ----------------------------------------------------------------------------
# Actually transfer and index the data, with a simple CT.

err = rgb2idx( src_ds.GetRasterBand(1),
               src_ds.GetRasterBand(2),
               src_ds.GetRasterBand(3),
               tif_ds.GetRasterBand(1),
               ct )
tif_ds.GetRasterBand(1).SetRasterColorTable( ct )

tif_ds = None

if tif_filename != dst_filename:
    tif_ds = gdal.Open( tif_filename )
    dst_driver.CreateCopy( dst_filename, tif_ds )
    tif_ds = None

    os.close(tif_filedesc)
    gtiff_driver.Delete( tif_filename )


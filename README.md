[![Build Status](https://travis-ci.org/DiamondLightSource/hdf5filters.svg?branch=master)](https://travis-ci.org/DiamondLightSource/hdf5filters)

hdf5filters
===========

A collection of HDF5 compression filters, wrapped in a cmake build system.

The implementation of the compression algorithms and filter code are imported
from various open-source projects, without modifications.

The purpose of this module is to pull together a selection of high performance
compression algorithms with implementations of [HDF5 dynamically loadable filters](https://support.hdfgroup.org/HDF5/doc/Advanced/DynamicallyLoadedFilters/)
and provide a sensible (cmake based) build system.

LZ4
---

Extremely Fast Compression algorithm: http://www.lz4.org

Code: https://github.com/lz4/lz4

Log:

| Date           | version | SHA                                      | 
| -------------- | ------- | ---------------------------------------- |
| 29 April 2017  | v1.7.5  | 7bb64ff2b69a9f8367de9ab483cdadf42b4c1b65 |


h5lzfilter
----------

Dynamically loadable HDF5 filter using LZ4 compression.

Code: https://github.com/nexusformat/HDF5-External-Filter-Plugins/tree/master/LZ4/src

Log:

| Date           | version | SHA                                      | 
| -------------- | ------- | ---------------------------------------- |
| 29 April 2017  | N/A     | 863db280bcb3a120849bcedd75426af6f55dce12 |


bitshuffle
----------

Filter for improving compression of typed binary data. Includes implementation
of a HDF5 dynamically loadable filter.

Code: https://github.com/kiyo-masui/bitshuffle

Log:

| Date           | version    | SHA                                      | 
| -------------- | ---------- | ---------------------------------------- |
| 29 April 2017  | 0.3.3.dev1 | 762e5d7ef27ccc3d975546cc281609fb6464b563 |


Blosc
-----

Filter utilizing the Blosc meta compressor. Blosc is an external dependency
and this module only includes the HDF5 dynamically loadable filter code.
Blosc combines a number of popular compression algorithms like LZ4, Snappy,
zlib, etc and enable multi-threaded and highly optimized use of these.

Code: https://github.com/blosc/hdf5-blosc

Log:

| Date           | version    | SHA                                      | 
| -------------- | ---------- | ---------------------------------------- |
| 12 July 2018   | N/A        | efa7653f0735cd03e7e9efb94f3ebcbcbec42889 |


Build and install
=================

Requirements: HDF5 C library and headers version >= 1.8.11

Recommendation: build on/for a processor with Intel AVX2 support for best 
performance. The following flags can be used to control what optimisations are 
enabled:

* CMAKE_BUILD_TYPE=Release will enable compiler optimizations: -O3
* CMAKE_BUILD_TYPE=RelWithDebInfo will enable compiler optimizations: -O2
* USE_SSE2=ON will enable SSE2 extensions: -msse2 (default: ON)
* USE_AVX2=ON will enable AVX2 extensions: -mavx2 (default: OFF - use gcc >= 4.8)

```
cd hdf5filters
mkdir -p cmake-build
cd cmake-build
cmake -DHDF5_ROOT=/path/to/hdf5/installation/ \
      -DBLOSC_ROOT_DIR=/path/to/blosc/installation \
      -DCMAKE_INSTALL_PREFIX=/path/to/install/destination \
      -DCMAKE_BUILD_TYPE=Release \ 
      -DUSE_AVX2=ON \
      ..
make
make install
```

The compression libs are installed into the `CMAKE_INSTALL_PREFIX/lib` dir and the HDF5 filters
are installed into the `CMAKE_INSTALL_PREFIX/h5plugin` dir.

Usage
=====

Set the environment variable HDF5_PLUGIN_PATH to point to the `CMAKE_INSTALL_PREFIX/h5plugin` 
dir. Use semicolon to list multiple dirs. Then use HDF5 (>= 1.8.11) applications as
per usual and the filters will automatically be loaded when required.

```
export HDF5_PLUGIN_PATH=/path/to/hdf5filters/installation/h5plugin
```

Using the HDF5 tools with filters
---------------------------------

The HDF5 (>=1.8.12) tool h5repack can be used to decompress a compressed dataset.

First check out the '/data' dataset in compressed.h5 and notice the
FILTER_ID = 320004 is the HDF5 lz4 filter:

```
h5dump -Hp compressed.h5 
HDF5 "compressed.h5" {
GROUP "/" {
   DATASET "data" {
      DATATYPE  H5T_STD_I64LE
      DATASPACE  SIMPLE { ( 1000 ) / ( 1000 ) }
      STORAGE_LAYOUT {
         CHUNKED ( 1000 )
         SIZE 4018
      }
      FILTERS {
         UNKNOWN_FILTER {
            FILTER_ID 32004
            
            COMMENT HDF5 lz4 filter; see http://www.hdfgroup.org/services/contributions.html
         }
      }
      FILLVALUE {
         FILL_TIME H5D_FILL_TIME_ALLOC
         VALUE  0
      }
      ALLOCATION_TIME {
         H5D_ALLOC_TIME_INCR
      }
   }
}
}
```

To decompress the '/data' dataset in the file compressed.h5 to bloated.h5:


```
h5repack -f data:NONE compressed.h5 bloated.h5
```

Now check the result:

```h5dump -Hp bloated.h5 
HDF5 "bloated.h5" {
GROUP "/" {
   DATASET "data" {
      DATATYPE  H5T_STD_I64LE
      DATASPACE  SIMPLE { ( 1000 ) / ( 1000 ) }
      STORAGE_LAYOUT {
         CHUNKED ( 1000 )
         SIZE 8000
      }
      FILTERS {
         NONE
      }
      FILLVALUE {
         FILL_TIME H5D_FILL_TIME_ALLOC
         VALUE  0
      }
      ALLOCATION_TIME {
         H5D_ALLOC_TIME_INCR
      }
   }
}
}
```

Compressing with blosc and h5repack
------------------------------------

For a test you might want to try to compress a raw, uncompressed data file from an experiment
in order to get an idea of what level of compression can be achieved:

The input data is an uncompressed 3D stack of images in a chunked dataset:

```
h5dump -pH input.h5 
HDF5 "input.h5" {
GROUP "/" {
   DATASET "data" {
      DATATYPE  H5T_STD_U16LE
      DATASPACE  SIMPLE { ( 100, 1536, 2048 ) / ( H5S_UNLIMITED, 1536, 2048 ) }
      STORAGE_LAYOUT {
         CHUNKED ( 1, 1536, 2048 )
         SIZE 629145600
      }
      FILTERS {
         NONE
      }
      FILLVALUE {
         FILL_TIME H5D_FILL_TIME_IFSET
         VALUE  0
      }
      ALLOCATION_TIME {
         H5D_ALLOC_TIME_INCR
      }
   }
}
}
```

Compress and check the output file.

Note that 32001 is the Blosc User Defined (UD) filter code:

```
export HDF5_PLUGIN_PATH=/dls_sw/prod/tools/RHEL7-x86_64/hdf5filters/0-6-1/prefix/avx2-hdf5_1.10/h5plugin
h5repack -L -f UD=32001,0,7,0,0,0,0,1,1,1 input.h5 out.h5
h5dump -pH out.h5 
HDF5 "out.h5" {
GROUP "/" {
   DATASET "data" {
      DATATYPE  H5T_STD_U16LE
      DATASPACE  SIMPLE { ( 100, 1536, 2048 ) / ( H5S_UNLIMITED, 1536, 2048 ) }
      STORAGE_LAYOUT {
         CHUNKED ( 1, 1536, 2048 )
         SIZE 8839621 (71.173:1 COMPRESSION)       <== decent compression ratio
      }
      FILTERS {
         USER_DEFINED_FILTER {
            FILTER_ID 32001
            COMMENT blosc
            PARAMS { 2 2 2 6291456 1 1 1 }        <== blosc filter parameters
         }
      }
      FILLVALUE {
         FILL_TIME H5D_FILL_TIME_IFSET
         VALUE  0
      }
      ALLOCATION_TIME {
         H5D_ALLOC_TIME_INCR
      }
   }
}
}
```


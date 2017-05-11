[![Build Status](https://travis-ci.org/dls-controls/hdf5filters.svg?branch=master)](https://travis-ci.org/dls-controls/hdf5filters)

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


Build and install
=================

Requirements: HDF5 C library and headers version >= 1.8.11

Recommendation: build on/for a processor with Intel AVX2 support for best 
performance. Setting the CMAKE_BUILD_TYPE=Release will enable optimizations.

```
cd hdf5filters
mkdir -p cmake-build
cd cmake-build
cmake -DHDF5_ROOT=/path/to/hdf5/installation/ \
      -DCMAKE_INSTALL_PREFIX=/path/to/install/destination \
      -DCMAKE_BUILD_TYPE=Release \
      ..
make
make install
```

The compression libs are installed into the PREFIX/lib dir and the HDF5 filters
are installed into the PREFIX/h5plugin dir.

Usage
=====

Set the environment variable HDF5_PLUGIN_PATH to point to the PREFIX/h5plugin dir.
Use semicolon to list multiple dirs. Then use HDF5 (>= 1.8.11) applications as
per usual and the filters will automatically be loaded when required.

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

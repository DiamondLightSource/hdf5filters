cmake_minimum_required(VERSION 2.8)
project(hdf5filters C)

#set(CMAKE_CXX_STANDARD 98)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

IF (HDF5_ROOT)
    message(STATUS "HDF5_ROOT set: " ${HDF5_ROOT})
    set( ENV{HDF5_ROOT} ${HDF5_ROOT} )
    find_path( HDF5_INCLUDE_DIRS
            NAMES hdf5.h
            PATHS ${HDF5_ROOT}/include
            NO_DEFAULT_PATH )
    find_library( HDF5_LIBRARIES
            NAMES hdf5
            PATHS ${HDF5_ROOT}/lib
            NO_DEFAULT_PATH )
ELSE(HDF5_ROOT)
    # If no HDF5_ROOT variable has been set then we just
    # use the built-in FindHDF5.cmake...
    find_package(HDF5 1.8.11
            COMPONENTS C)
ENDIF(HDF5_ROOT)


set(LZ4_SRC_DIR ${hdf5filters_SOURCE_DIR}/lz4)
add_subdirectory(lz4)
add_subdirectory(h5lzfilter)
add_subdirectory(bitshuffle)

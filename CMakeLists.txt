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

#====== Handling rpath ============================
# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 

SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)


# the RPATH to be used when installing, but only if it's not a system directory
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
ENDIF("${isSystemDir}" STREQUAL "-1")
#======================================================

set(CMAKE_C_FLAGS_RELEASE "-O3 -msse2 -mavx")
set(LZ4_SRC_DIR ${hdf5filters_SOURCE_DIR}/lz4)
add_subdirectory(lz4)
add_subdirectory(h5lzfilter)
add_subdirectory(bitshuffle)

add_executable(demo demo.c)
target_link_libraries(demo ${HDF5_LIBRARIES})
include_directories(${HDF5_INCLUDE_DIRS})

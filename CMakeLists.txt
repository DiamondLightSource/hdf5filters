cmake_minimum_required(VERSION 2.8)
project(hdf5filters C)

#set(CMAKE_CXX_STANDARD 98)
set(CMAKE_MODULE_PATH ${hdf5filters_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# === Find HDF5 ===
message("Looking for HDF5 headers and libraries")
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
message("-- hdf5 include dir: ${HDF5_INCLUDE_DIRS}")
message("-- hdf5 libraries:   ${HDF5_LIBRARIES}")
# === Find Blosc ===

find_package(Blosc)

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

message("Options:")
option(USE_AVX2 "Use the AVX2 optimisations with the -mavx2 compiler flag" OFF)
option(USE_SSE2 "Use the SSE2 optimisations with the -msse2 compiler flag" ON)

set(CFLAGS_OPT "")
if (USE_AVX2)
    set(CFLAGS_OPT "${CFLAGS_OPT} -mavx2")
endif(USE_AVX2)
if (USE_SSE2)
    set(CFLAGS_OPT "${CFLAGS_OPT} -msse2")
endif(USE_SSE2)

set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${CFLAGS_OPT}")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELEASE} ${CFLAGS_OPT}")

message("-- Using SSE2 flags: ${USE_SSE2}")
message("-- Using AVX2 flags: ${USE_AVX2}")

message("Configuring plugins")

set(LZ4_SRC_DIR ${hdf5filters_SOURCE_DIR}/lz4)
add_subdirectory(lz4)
add_subdirectory(h5lzfilter)
add_subdirectory(bitshuffle)
if (BLOSC_FOUND)
    add_subdirectory(hdf5-blosc)
endif ()


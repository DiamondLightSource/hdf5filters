file(GLOB HDF5_BLOSC_PLUGIN_SOURCES src/blosc_filter.c src/blosc_plugin.c)

include_directories(${BLOSC_INCLUDE_DIRS} ${HDF5_INCLUDE_DIRS})

add_library(H5Zblosc SHARED ${HDF5_BLOSC_PLUGIN_SOURCES})
target_link_libraries(H5Zblosc ${BLOSC_LIBRARIES} ${HDF5_LIBRARIES})
    
install(TARGETS H5Zblosc DESTINATION h5plugin)


file(GLOB H5LZ_FILTER_LIB_SOURCES *.c)
include_directories(${LZ4_SRC_DIR} ${HDF5_INCLUDE_DIRS})

set(CMAKE_C_STANDARD 99)

add_library(h5lz4 SHARED ${H5LZ_FILTER_LIB_SOURCES})
target_link_libraries(h5lz4 lz4)

install(TARGETS h5lz4 DESTINATION lib)

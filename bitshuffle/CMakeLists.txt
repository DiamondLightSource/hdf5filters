file(GLOB BITHSUFFLE_LIB_SOURCES
        bitshuffle.c
        bitshuffle_core.c
        iochain.c
        bshuf_h5filter.c bshuf_h5plugin.c
        )
file(GLOB BITSHUFFLE_PUBLIC_HEADERS bitshuffle.h )
include_directories(${LZ4_SRC_DIR} ${HDF5_INCLUDE_DIRS})

set(CMAKE_C_STANDARD 99)

add_library(h5bshuf SHARED ${BITHSUFFLE_LIB_SOURCES})
target_link_libraries(h5bshuf lz4 ${HDF5_LIBRARIES})

install(TARGETS h5bshuf DESTINATION lib)
install(FILES ${BITHSUFFLE_PUBLIC_HEADERS} DESTINATION include)

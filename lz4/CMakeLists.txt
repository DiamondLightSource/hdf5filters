file(GLOB LIB_SOURCES *.c)
file(GLOB LZ4_PUBLIC_HEADERS lz4.h lz4hc.h lz4frame.h )

set(CMAKE_C_FLAGS_RELEASE "-O3 -mavx2")

add_library(lz4 SHARED ${LIB_SOURCES})
install(TARGETS lz4 DESTINATION lib)
install(FILES ${LZ4_PUBLIC_HEADERS} DESTINATION include)

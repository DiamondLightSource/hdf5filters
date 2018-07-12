# Usage:
#
#  find_package(Blosc)
#
#  Use the BLOSC_ROOT_DIR variable to hint where to find Blosc before running
#  the find_package function.
#
# Output variables:
#
#  BLOSC_FOUND              System has Blosc libs/headers
#  BLOSC_LIBRARIES          The Blosc libraries
#  BLOSC_INCLUDE_DIRS       The location of Blosc headers

message ("\nLooking for Blosc headers and libraries")

if (BLOSC_ROOT_DIR) 
    message (STATUS "Root dir: ${BLOSC_ROOT_DIR}")
endif ()

find_package(PkgConfig)
IF (PkgConfig_FOUND)
    message("using pkgconfig")
    pkg_check_modules(PKGCFG_BLOSC blosc)
ENDIF(PkgConfig_FOUND)

set(BLOSC_DEFINITIONS ${PKGCFG_BLOSC_CFLAGS_OTHER})

find_path(BLOSC_INCLUDE_DIR 
	NAMES
		blosc.h
    PATHS 
		${BLOSC_ROOT_DIR}/include
        ${PKGCFG_BLOSC_INCLUDEDIR} 
        ${PKGCFG_BLOSC_INCLUDE_DIRS}
)

find_library(BLOSC_LIBRARY
    NAMES 
		blosc
    PATHS 
		${BLOSC_ROOT_DIR}/lib 
        ${PKGCFG_BLOSC_LIBDIR} 
        ${PKGCFG_BLOSC_LIBRARY_DIRS}
)

include(FindPackageHandleStandardArgs)

# handle the QUIETLY and REQUIRED arguments and set BLOSC_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(BLOSC 
	DEFAULT_MSG
    BLOSC_LIBRARY 
	BLOSC_INCLUDE_DIR
)

mark_as_advanced(BLOSC_INCLUDE_DIR BLOSC_LIBRARY)

if (BLOSC_FOUND)
	set(BLOSC_INCLUDE_DIRS ${BLOSC_INCLUDE_DIR})
	set(BLOSC_LIBRARIES ${BLOSC_LIBRARY})
	
    get_filename_component(BLOSC_LIBRARY_DIR ${BLOSC_LIBRARY} PATH)
    get_filename_component(BLOSC_LIBRARY_NAME ${BLOSC_LIBRARY} NAME_WE)
    
    mark_as_advanced(BLOSC_LIBRARY_DIR BLOSC_LIBRARY_NAME)

	message (STATUS "Include directories: ${BLOSC_INCLUDE_DIRS}") 
	message (STATUS "Libraries: ${BLOSC_LIBRARIES}") 
endif ()


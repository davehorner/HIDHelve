cmake_minimum_required(VERSION 2.8)
set(CMAKE_USER_MAKE_RULES_OVERRIDE
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake/default_c_flags.cmake"
)
option(BUILD_SHARED_LIB "Build shared version" OFF)

project(HornersHelves)


IF(WIN32)
   SET(HIDAPI_OSBASE lib/hidapi/windows)
   SET(CMAKE_FIND_LIBRARY_SUFFIXES .lib .dll)
ENDIF()

find_path(HIDAPI_HEADER_DIR hidapi.h
	PATHS lib/hidapi ../hidapi.git
	PATH_SUFFIXES hidapi
	DOC "The location of HIDAPI's header file"
)
include_directories(${HIDAPI_HEADER_DIR})

add_subdirectory(src)

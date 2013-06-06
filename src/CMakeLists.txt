cmake_minimum_required(VERSION 2.8)

add_definitions(-DUNICODE -D_UNICODE)

IF(WIN32)
   SET(HIDAPI_OSBASE ../lib/hidapi/windows)
   SET(CMAKE_FIND_LIBRARY_SUFFIXES .lib .dll)
ENDIF()
include_directories(../lib/hidapi/hidapi)

option(BUILD_SHARED_HIDAPILIB "Build hidapilib shared version" OFF)
if (BUILD_SHARED_HIDAPILIB)
   ADD_LIBRARY(hidapi SHARED ${HIDAPI_OSBASE}/hid.c)
   set(CMAKE_C_STANDARD_LIBRARIES setupapi.lib)
else()
   ADD_LIBRARY(hidapi STATIC ${HIDAPI_OSBASE}/hid.c)
endif()

set(BOOST_ROOT         ../lib/boost)
SET(Boost_USE_STATIC_LIBS ON)
find_package(Boost COMPONENTS program_options regex REQUIRED)

include_directories(${Boost_INCLUDE_DIR})
link_directories(${Boost_LIBRARY_DIR})

#include( ${CMAKE_SOURCE_DIR}/cmake/External-Boost.cmake)
#include_directories(${CMAKE_BINARY_DIR}/src/Boost)
#set(Boost_INCLUDE_DIR ${BOOST_ROOT})

add_executable(HIDHelve hidhelve.cpp)
set(CMAKE_CXX_STANDARD_LIBRARIES setupapi.lib)
target_link_libraries(HIDHelve hidapi log4cplus ${Boost_LIBRARIES})
add_dependencies (HIDHelve hidapi)


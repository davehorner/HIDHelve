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

set(BOOST_ROOT ../lib/boost)
SET(Boost_USE_STATIC_LIBS ON)
find_package(Boost COMPONENTS program_options regex thread system date_time chrono log REQUIRED)
include_directories(${Boost_INCLUDE_DIR})
link_directories(${Boost_LIBRARY_DIR})
message(STATUS "Boost ${Boost_LIBRARY_DIR}")

set(ICU_DEBUG 1)
set(ICU_ROOT ../lib/icu4c)
find_package(ICU 4.4 COMPONENTS uc i18n REQUIRED)
include_directories(${ICU_INCLUDE_DIRS})
#include_directories(${PROJECT_SOURCE_DIR}/lib/icu4c/include)
message(STATUS "ICU ${ICU_LIBRARIES}")

file(GLOB HIDHelve_INCLUDEDIR "${PROJECT_SOURCE_DIR}/include" "${PROJECT_SOURCE_DIR}/include/*.h")
message(STATUS "FIND HEADERS ${HIDHelve_INCLUDEDIR}")

include_directories("${PROJECT_SOURCE_DIR}/include"
                    "${PROJECT_SOURCE_DIR}/src")
add_executable(HIDHelve hidhelve.cpp 
"${PROJECT_SOURCE_DIR}/include/hidhelve_log.h"
"${PROJECT_SOURCE_DIR}/include/hidhelve_version.h")
set(CMAKE_CXX_STANDARD_LIBRARIES setupapi.lib)
target_link_libraries(HIDHelve hidapi ${Boost_LIBRARIES}  ${ICU_LIBRARIES})
add_dependencies (HIDHelve hidapi log4cplus)
install (TARGETS HIDHelve DESTINATION bin)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/icuuc51d.dll
    COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_SOURCE_DIR}/lib/icu4c/bin64/icuuc51d.dll ${CMAKE_CURRENT_BINARY_DIR}/icuuc51d.dll
    MAIN_DEPENDENCY ${PROJECT_SOURCE_DIR}/lib/icu4c/bin64/icuuc51d.dll)

    
add_custom_command(TARGET HIDHelve POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${PROJECT_SOURCE_DIR}/lib/icu4c/bin64/icuuc51d.dll   
    $<TARGET_FILE_DIR:HIDHelve>)

add_custom_command(TARGET HIDHelve POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${PROJECT_SOURCE_DIR}/lib/icu4c/bin64/icuuc51.dll   
   $<TARGET_FILE_DIR:HIDHelve>)

add_custom_command(TARGET HIDHelve POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${PROJECT_SOURCE_DIR}/lib/icu4c/bin64/icudt51.dll   
   $<TARGET_FILE_DIR:HIDHelve>)

add_custom_command(TARGET HIDHelve POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${PROJECT_SOURCE_DIR}/lib/icu4c/bin64/icuin51.dll   
   $<TARGET_FILE_DIR:HIDHelve>)

add_custom_command(TARGET HIDHelve POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${PROJECT_SOURCE_DIR}/lib/icu4c/bin64/icuin51d.dll   
   $<TARGET_FILE_DIR:HIDHelve>)


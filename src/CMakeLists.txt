cmake_minimum_required(VERSION 2.8)

add_definitions(-DUNICODE -D_UNICODE)

if (BUILD_SHARED_LIB)
ADD_LIBRARY(hidapi SHARED ../${HIDAPI_OSBASE}/hid.c)
set(CMAKE_C_STANDARD_LIBRARIES setupapi.lib)
else()
ADD_LIBRARY(hidapi STATIC ../${HIDAPI_OSBASE}/hid.c)
endif()


add_executable(HIDHelve hidhelve.cpp)
set(CMAKE_CXX_STANDARD_LIBRARIES setupapi.lib)
target_link_libraries(HIDHelve hidapi)
add_dependencies (HIDHelve hidapi)

cmake_minimum_required(VERSION 2.8)
project(HornersHelves)

add_subdirectory(src)
add_definitions (-DLOG4CPLUS_STATIC)
add_subdirectory(lib/log4cplus)

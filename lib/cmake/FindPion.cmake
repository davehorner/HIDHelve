# - Try to find Pion
# Once done this will define
#  PION_FOUND - System has Pion
#  PION_INCLUDE_DIRS - The Pion include directories
#  PION_LIBRARY_DIRS - The pion library directories
#  PION_LIBRARIES - The libraries needed to use Pion

# find_package (PkgConfig)
# pkg_check_modules (PC_LIBPION QUIET libpion)
set (PION_DEFINITIONS ${PC_LIBPION_CFLAGS_OTHER})

find_path (Pion_INCLUDE_DIRS
  NAMES pion/config.hpp
  HINTS ${PC_LIBPION_INCLUDEDIR} ${PC_LIBPION_INCLUDE_DIRS} ${PROJECT_SOURCE_DIR}/lib/pion/include
  PATH_SUFFIXES pion )

#find_path (Pion_LIBRARY
#  NAMES pion.lib
#  HINTS ${PC_LIBPION_INCLUDEDIR} ${PC_LIBPION_INCLUDE_DIRS} ${PROJECT_SOURCE_DIR}/lib/pion/bin/Debug_static_Win32  ${PROJECT_SOURCE_DIR}/lib/pion/bin/Release_static_Win32
#  PATH_SUFFIXES pion
#)

find_library (Pion_LIBRARY
  NAMES pion
  HINTS ${PC_LIBPION_LIBDIR} ${PC_LIBPION_LIBRARY_DIRS}  ${PROJECT_SOURCE_DIR}/lib/pion/bin/Release_static_Win32  ${PROJECT_SOURCE_DIR}/lib/pion/bin/Debug_static_Win32
)

set (Pion_LIBRARIES ${Pion_LIBRARY})
foreach(_pion_my_lib ${Pion_LIBRARY})
  get_filename_component(_pion_my_lib_path "${_pion_my_lib}" PATH)
  list(APPEND Pion_LIBRARY_DIRS ${_pion_my_lib_path})
endforeach()
# list(REMOVE_DUPLICATES Pion_LIBRARY_DIRS)

include (FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set PION_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args (Pion DEFAULT_MSG
  Pion_LIBRARIES
  Pion_INCLUDE_DIRS
  Pion_LIBRARY_DIRS
  Pion_LIBRARY)

mark_as_advanced (Pion_LIBRARY)
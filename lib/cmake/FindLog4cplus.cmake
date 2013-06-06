# Locate Log4cplus library
# This module defines
#  LOG4CPLUS_FOUND, if false, do not try to link to Log4cplus
#  LOG4CPLUS_LIBRARIES
#  LOG4CPLUS_INCLUDE_DIR, where to find log4cplus.hpp

FIND_PATH(LOG4CPLUS_INCLUDE_DIR log4cplus/logger.h
  HINTS
  ${LOG4CPLUS_DIR}
  $ENV{LOG4CPLUS_ROOT}
  $ENV{LOG4CPLUS_DIR}
  PATH_SUFFIXES 
  include
  include/log4cplus
  PATHS
  ~/Library/Frameworks
  /Library/Frameworks
  /usr/local
  /usr
  /sw # Fink
  /opt/local # DarwinPorts
  /opt/csw # Blastwave
  /opt
)

FIND_LIBRARY(LOG4CPLUS_RELEASE_LIBRARY
  NAMES 
  LOG4CPLUS
  log4cplusS.lib
  log4cplusUS.lib
  HINTS
  $ENV{LOG4CPLUS_DIR}
  PATH_SUFFIXES lib64 lib
  PATHS
  ${LOG4CPLUS_DIR}/msvc8/Win32/log4cplus_static.Release_Unicode/
  ${LOG4CPLUS_DIR}/bin
  ~/Library/Frameworks
  /Library/Frameworks
  /usr/local
  /usr
  /sw
  /opt/local
  /opt/csw
  /opt
)
FIND_LIBRARY(LOG4CPLUS_DEBUG_LIBRARY_WC
  NAMES
  log4cplusSD.lib
  log4cplus_static.lib
  HINTS
  $ENV{LOG4CPLUS_DIR}
  PATH_SUFFIXES lib64 lib
  PATHS
  ${LOG4CPLUS_DIR}/msvc8/Win32/log4cplus_static.Release/
  ${LOG4CPLUS_DIR}/msvc8
  ${LOG4CPLUS_DIR}/bin/x64
  ~/Library/Frameworks
  /Library/Frameworks
  /usr/local
  /usr
  /sw
  /opt/local
  /opt/csw
  /opt
)
FIND_LIBRARY(LOG4CPLUS_DEBUG_LIBRARY_UNICODE
  NAMES 
  log4cplusUSD.lib
  log4cplus_static.lib
  HINTS
  $ENV{LOG4CPLUS_DIR}
  PATH_SUFFIXES lib64 lib
  PATHS
  ${LOG4CPLUS_DIR}/bin/x64
  ${LOG4CPLUS_DIR}/msvc8/Win32/log4cplus_static.Debug_Unicode/
  ~/Library/Frameworks
  /Library/Frameworks
  /usr/local
  /usr
  /sw
  /opt/local
  /opt/csw
  /opt
)

SET(LOG4CPLUS_LIBRARIES_WC debug ${LOG4CPLUS_DEBUG_LIBRARY_WC} optimized ${LOG4CPLUS_RELEASE_LIBRARY} CACHE STRING "Log4cplus Libraries")
SET(LOG4CPLUS_LIBRARIES_UNICODE debug ${LOG4CPLUS_DEBUG_LIBRARY_UNICODE} optimized ${LOG4CPLUS_RELEASE_LIBRARY} CACHE STRING "Log4cplus Libraries")
SET(LOG4CPLUS_LIBRARIES ${LOG4CPLUS_LIBRARIES_UNICODE})

INCLUDE(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set LOG4CPLUS_FOUND to TRUE if 
# all listed variables are TRUE
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Log4cplus DEFAULT_MSG LOG4CPLUS_LIBRARIES LOG4CPLUS_INCLUDE_DIR)

MARK_AS_ADVANCED(LOG4CPLUS_INCLUDE_DIR LOG4CPLUS_LIBRARIES LOG4CPLUS_DEBUG_LIBRARY_UNICODE LOG4CPLUS_RELEASE_LIBRARY)

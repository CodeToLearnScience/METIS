cmake_minimum_required(VERSION 3.10)
project(METIS VERSION 5.2.1 LANGUAGES C)

# Detect if METIS is being used as a subproject
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  set(METIS_IS_TOPLEVEL TRUE)
else()
  set(METIS_IS_TOPLEVEL FALSE)
endif()

# Options
set(SHARED FALSE CACHE BOOL "build a shared library")
option(METIS_BUILD_PROGRAMS "Build METIS programs" ${METIS_IS_TOPLEVEL})

if(MSVC)
  set(METIS_INSTALL_DEFAULT FALSE)
else()
  set(METIS_INSTALL_DEFAULT ${METIS_IS_TOPLEVEL})
endif()
option(METIS_INSTALL "Install METIS library and headers" ${METIS_INSTALL_DEFAULT})

# Configure libmetis library.
if(SHARED)
  set(METIS_LIBRARY_TYPE SHARED)
else()
  set(METIS_LIBRARY_TYPE STATIC)
endif(SHARED)

# Handle GKlib dependency
if(NOT DEFINED GKLIB_PATH)
  # If GKLIB_PATH is not provided, fetch GKlib automatically
  message(STATUS "GKLIB_PATH not set, fetching GKlib automatically...")
  include(FetchContent)
  
  FetchContent_Declare(
    GKlib
    GIT_REPOSITORY https://github.com/KarypisLab/GKlib.git
    GIT_TAG        master
  )
  
  # Don't install GKlib when METIS is installed
  set(GK_INSTALL OFF CACHE BOOL "" FORCE)
  
  FetchContent_MakeAvailable(GKlib)
  
  # Set GKLIB_PATH to the fetched GKlib source directory
  set(GKLIB_PATH ${gklib_SOURCE_DIR})
  
  # Add GKlib include directory (GKlib headers are in the root, not in an include subdir)
  include_directories(${gklib_SOURCE_DIR})
  
  # GKlib builds a library target named GKlib
  # We'll link against it in libmetis
endif()

# Use CMAKE_CURRENT_SOURCE_DIR instead of CMAKE_SOURCE_DIR for subproject compatibility
include(${CMAKE_CURRENT_SOURCE_DIR}/conf/gkbuild.cmake)

# Configure METIS types (idx_t and real_t widths)
# Generate metis.h with type width definitions
set(IDXTYPEWIDTH "32" CACHE STRING "Width of idx_t (32 or 64)")
set(REALTYPEWIDTH "32" CACHE STRING "Width of real_t (32 or 64)")

# Create xinclude directory and generate metis.h with width definitions
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/xinclude)
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/xinclude/metis.h
  "#define IDXTYPEWIDTH ${IDXTYPEWIDTH}\n#define REALTYPEWIDTH ${REALTYPEWIDTH}\n")
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/include/metis.h METIS_H_CONTENT)
file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/xinclude/metis.h "${METIS_H_CONTENT}")

# Include the generated header directory
include_directories(${CMAKE_CURRENT_BINARY_DIR}/xinclude)

# METIS' custom options
#option(IDX64 "enable 64 bit ints" OFF)
#option(REAL64 "enable 64 bit floats (i.e., double)" OFF)
#if(IDX64)
#  set(METIS_COPTIONS "${METIS_COPTIONS} -DIDXTYPEWIDTH=64")
#else()
#  set(METIS_COPTIONS "${METIS_COPTIONS} -DIDXTYPEWIDTH=32")
#endif(IDX64)
#if(REAL64)
#  set(METIS_COPTIONS "${METIS_COPTIONS} -DREALTYPEWIDTH=64")
#else()
#  set(METIS_COPTIONS "${METIS_COPTIONS} -DREALTYPEWIDTH=32")
#endif(REAL64)
#
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${METIS_COPTIONS}")


# Add include directories using CMAKE_CURRENT_SOURCE_DIR
# Only include build/xinclude if it exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/build/xinclude)
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/build/xinclude)
endif()

# GKLIB_PATH handling for backward compatibility
# When GKLIB_PATH is set externally (traditional build), use include/lib subdirs
# When we fetched GKlib, includes were already added above
if(DEFINED GKLIB_PATH AND NOT gklib_SOURCE_DIR)
  include_directories(${GKLIB_PATH}/include)
  link_directories(${GKLIB_PATH}/lib)
endif()

include_directories(${CMAKE_INSTALL_PREFIX}/include)
link_directories(${CMAKE_INSTALL_PREFIX}/lib)

# Recursively look for CMakeLists.txt in subdirs.
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/build/xinclude)
  add_subdirectory(build/xinclude)
endif()
add_subdirectory(include)
add_subdirectory(libmetis)
if(METIS_BUILD_PROGRAMS)
  add_subdirectory(programs)
endif()

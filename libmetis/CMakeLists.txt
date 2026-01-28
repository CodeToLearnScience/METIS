# Add this directory for internal users.
include_directories(.)

# Find sources.
file(GLOB metis_sources *.c)

# Build libmetis.
add_library(metis ${METIS_LIBRARY_TYPE} ${metis_sources})

# Add alias for namespaced target (best practice for FetchContent)
add_library(METIS::metis ALIAS metis)

# Set target properties for modern CMake usage
set_target_properties(metis PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION 2
  PUBLIC_HEADER "${CMAKE_CURRENT_BINARY_DIR}/../xinclude/metis.h"
)

# Define include directories for the target
# Use the generated header in xinclude for build, original for install
target_include_directories(metis PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/../xinclude>
  $<INSTALL_INTERFACE:include>
)

# Link with required libraries
target_link_libraries(metis PUBLIC m)
if(DEFINED GKLIB_PATH)
  target_link_libraries(metis PUBLIC GKlib)
endif()

# Installation
if(METIS_INSTALL)
  include(GNUInstallDirs)
  
  install(TARGETS metis
    EXPORT metis-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  )
  
  # Export targets for find_package support
  install(EXPORT metis-targets
    FILE METISTargets.cmake
    NAMESPACE METIS::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/METIS
  )
  
  # Create config file for find_package support
  include(CMakePackageConfigHelpers)
  
  write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/METISConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
  )
  
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/METISConfig.cmake.in")
    configure_package_config_file(
      "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/METISConfig.cmake.in"
      "${CMAKE_CURRENT_BINARY_DIR}/METISConfig.cmake"
      INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/METIS
      NO_CHECK_REQUIRED_COMPONENTS_MACRO
    )
    
    install(FILES
      "${CMAKE_CURRENT_BINARY_DIR}/METISConfig.cmake"
      "${CMAKE_CURRENT_BINARY_DIR}/METISConfigVersion.cmake"
      DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/METIS
    )
  endif()
endif()

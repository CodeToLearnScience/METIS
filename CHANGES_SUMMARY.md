# METIS FetchContent Integration - Changes Summary

## Overview
METIS has been enhanced to support CMake's FetchContent module, making it easy to use as a dependency in modern CMake projects 

## Files Modified

### 1. CMakeLists.txt (Root)
**Changes:**
- Added subproject detection via `CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR`
- Added `METIS_BUILD_PROGRAMS` option (defaults to ON for top-level, OFF for subproject)
- Changed `METIS_INSTALL` to be an option with smart defaults
- Updated all paths to use `CMAKE_CURRENT_SOURCE_DIR` instead of `CMAKE_SOURCE_DIR`
- Made `build/xinclude` directory optional
- Made `GKLIB_PATH` optional (backward compatibility)
- Added `include` subdirectory to build process

**Impact:** METIS can now be used as a subproject without building unnecessary binaries

### 2. libmetis/CMakeLists.txt
**Changes:**
- Created `METIS::metis` alias target for namespaced usage
- Added modern target properties (VERSION, SOVERSION, PUBLIC_HEADER)
- Implemented proper `target_include_directories()` with BUILD_INTERFACE and INSTALL_INTERFACE
- Updated `target_link_libraries()` to use PUBLIC/PRIVATE correctly
- Added CMake package export (`METISTargets.cmake`)
- Added `METISConfig.cmake` and `METISConfigVersion.cmake` generation
- Used `GNUInstallDirs` for standard installation paths
- Made GKlib dependency optional

**Impact:** METIS now provides a modern CMake target with proper transitive dependencies

### 3. include/CMakeLists.txt
**Changes:**
- Simplified to just a comment
- Header installation moved to libmetis/CMakeLists.txt via PUBLIC_HEADER

**Impact:** Cleaner organization, header installed with library target

### 4. programs/CMakeLists.txt
**Changes:**
- Changed `target_link_libraries()` to use `PRIVATE` visibility
- Made GKlib dependency optional
- Used `GNUInstallDirs` for installation paths

**Impact:** Programs properly link as executables without exposing internal dependencies

### 5. conf/gkbuild.cmake
**Changes:**
- Replaced `CMAKE_SOURCE_DIR` with `CMAKE_CURRENT_LIST_DIR` for check_thread_storage.c

**Impact:** Works correctly when METIS is a subproject

## Files Created

### 6. cmake/METISConfig.cmake.in
**Purpose:** CMake package configuration template for `find_package(METIS)` support

**Content:**
- Finds dependencies (Threads)
- Includes METISTargets.cmake
- Checks required components

### 7. examples/CMakeLists.txt.fetchcontent
**Purpose:** Example CMake file showing FetchContent usage

**Content:**
- Complete example of FetchContent_Declare
- Shows how to link against METIS::metis

### 8. examples/example_fetchcontent.c
**Purpose:** Example C program using METIS

**Content:**
- Simple graph partitioning example
- Demonstrates header inclusion and linking

### 9. examples/README.md
**Purpose:** Comprehensive documentation for FetchContent usage

**Content:**
- Basic usage examples
- Configuration options
- Testing instructions
- find_package alternative
- Requirements and notes

### 10. FETCHCONTENT.md
**Purpose:** Complete documentation of FetchContent changes

**Content:**
- Summary of changes
- Usage examples
- CMake options
- List of modified files
- Testing procedures
- Benefits and migration guide

### 11. test_fetchcontent.sh
**Purpose:** Automated test script for FetchContent integration

**Content:**
- Creates temporary test project
- Tests CMake configuration
- Builds and runs test program
- Validates METIS::metis target

### 12. CHANGES_SUMMARY.md
**Purpose:** This file - detailed summary of all changes

## New CMake Targets

- `metis` - Main library target (original name, maintained for compatibility)
- `METIS::metis` - Namespaced alias (recommended for modern usage)

## New CMake Options

- `METIS_BUILD_PROGRAMS` - Control whether to build command-line programs (default: ON for top-level, OFF for subproject)
- `METIS_INSTALL` - Control installation (default: ON for top-level Unix, OFF for subproject)

## Backward Compatibility

All existing build methods continue to work:
- ✅ Traditional `make config && make install`
- ✅ Direct CMake with `GKLIB_PATH`
- ✅ All existing CMake options
- ✅ Static and shared library builds
- ✅ All compiler flags and options

## Testing

Run the test script to verify everything works:
```bash
./test_fetchcontent.sh
```

Or test manually:
```bash
cd examples
mkdir build && cd build
cmake .. -DMETIS_SOURCE_DIR=/path/to/METIS
make
./example
```

## Usage Examples

### As FetchContent Dependency
```cmake
include(FetchContent)
FetchContent_Declare(METIS GIT_REPOSITORY ... GIT_TAG ...)
FetchContent_MakeAvailable(METIS)
target_link_libraries(myapp PRIVATE METIS::metis)
```

### After Installation
```cmake
find_package(METIS REQUIRED)
target_link_libraries(myapp PRIVATE METIS::metis)
```

### Configure Options
```cmake
set(SHARED ON CACHE BOOL "" FORCE)                    # Build shared library
set(METIS_BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)    # Don't build programs
```

## Benefits

1. **Zero Installation** - Use METIS without system-wide installation
2. **Version Control** - Pin exact versions via Git tags
3. **Reproducible** - All dependencies explicitly versioned
4. **Modern CMake** - Follows current best practices
5. **Cross-Platform** - Works on Linux, macOS, Windows
6. **Backward Compatible** - Existing workflows unchanged

## Documentation Added

- `FETCHCONTENT.md` - Main documentation for FetchContent usage
- `examples/README.md` - Detailed examples and usage guide  
- `test_fetchcontent.sh` - Automated testing
- `CHANGES_SUMMARY.md` - This file
- Updated main `README.md` with FetchContent quickstart

## Requirements

- CMake 3.14+ (3.11+ with reduced features)
- C compiler
- Git (for fetching from repository)

## Migration Path

### For End Users
No migration needed - can continue using existing build system OR adopt FetchContent when desired.

### For Developers
Start using `METIS::metis` target name in new code. Old `metis` target still works.

## Future Improvements

Potential enhancements that could be made:
- Add GitHub Actions CI to test FetchContent integration
- Add more example programs
- Add CPack support for package generation
- Add option to fetch GKlib automatically
- Add pkg-config file generation

## Contact

For questions or issues related to FetchContent support, please file an issue on GitHub.

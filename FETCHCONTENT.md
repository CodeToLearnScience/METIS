# METIS CMake FetchContent Support

This document describes the changes made to make METIS available via CMake's FetchContent module.

## Summary of Changes

The METIS build system has been modernized to support being used as a CMake subproject via FetchContent while maintaining backward compatibility with traditional builds.

## Key Improvements

### 1. Modern CMake Target

- Created a proper namespaced target `METIS::metis` that can be used with `target_link_libraries()`
- Target includes proper PUBLIC interface for include directories
- Supports both static and shared library builds

### 2. Subproject Detection

- Automatically detects when METIS is built as a subproject vs. standalone
- Programs are not built by default when used as a subproject (controllable via `METIS_BUILD_PROGRAMS` option)
- Installation is optional and controlled by `METIS_INSTALL` option

### 3. Path Handling

- Uses `CMAKE_CURRENT_SOURCE_DIR` instead of `CMAKE_SOURCE_DIR` for proper subproject support
- Uses `CMAKE_CURRENT_LIST_DIR` in included CMake scripts
- Handles optional `build/xinclude` directory gracefully

### 4. Installation Support

- Uses `GNUInstallDirs` for standard installation paths
- Exports CMake targets for use with `find_package()`
- Creates config files for proper package discovery
- Installs versioned libraries with proper SOVERSION

### 5. Backward Compatibility

- Maintains support for `GKLIB_PATH` variable
- All existing build options still work
- Makefile-based build system unchanged

## Usage with FetchContent

```cmake
cmake_minimum_required(VERSION 3.14)
project(MyProject)

include(FetchContent)

FetchContent_Declare(
  METIS
  GIT_REPOSITORY https://github.com/CodeToLearnScience/METIS.git
  GIT_TAG        main
)

FetchContent_MakeAvailable(METIS)

add_executable(my_app main.c)
target_link_libraries(my_app PRIVATE METIS::metis)
```

## Usage with find_package (after installation)

```cmake
find_package(METIS REQUIRED)
add_executable(my_app main.c)
target_link_libraries(my_app PRIVATE METIS::metis)
```

## CMake Options

- `SHARED` (default: OFF) - Build shared library instead of static
- `METIS_BUILD_PROGRAMS` (default: ON for top-level, OFF for subproject) - Build command-line programs
- `METIS_INSTALL` (default: ON for top-level on Unix, OFF for subproject) - Enable installation
- `GKLIB_PATH` - Path to GKlib installation (for backward compatibility)

## Modified Files

### Core Build Files
- `CMakeLists.txt` - Main build file with subproject detection
- `libmetis/CMakeLists.txt` - Modern target definition and export
- `programs/CMakeLists.txt` - Conditional program building
- `include/CMakeLists.txt` - Simplified (header now installed via target)
- `conf/gkbuild.cmake` - Fixed paths for subproject support

### New Files
- `cmake/METISConfig.cmake.in` - Package config template for find_package()
- `examples/CMakeLists.txt.fetchcontent` - Example FetchContent usage
- `examples/example_fetchcontent.c` - Example program
- `examples/README.md` - Detailed usage documentation
- `FETCHCONTENT.md` - This file

## Testing

### Test as Subproject

```bash
mkdir test_fetch && cd test_fetch
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.14)
project(Test)
include(FetchContent)
FetchContent_Declare(METIS SOURCE_DIR /path/to/METIS)
FetchContent_MakeAvailable(METIS)
add_executable(test test.c)
target_link_libraries(test PRIVATE METIS::metis)
EOF

# Create simple test file
cat > test.c << 'EOF'
#include <metis.h>
#include <stdio.h>
int main() { printf("METIS OK\n"); return 0; }
EOF

cmake . && make && ./test
```

### Test Traditional Build

```bash
make config
make
```

## Benefits

1. **No Installation Required**: Projects can use METIS without system-wide installation
2. **Version Control**: Projects can pin specific METIS versions via Git tags
3. **Reproducible Builds**: All dependencies are explicitly specified
4. **Cross-Platform**: Works on Linux, macOS, and Windows
5. **Modern CMake**: Follows current CMake best practices
6. **Backward Compatible**: Existing build workflows continue to work

## Migration Guide

### For Users

If you previously used:
```cmake
include_directories(/path/to/metis/include)
link_directories(/path/to/metis/lib)
target_link_libraries(myapp metis)
```

Now you can use:
```cmake
FetchContent_Declare(METIS ...)
FetchContent_MakeAvailable(METIS)
target_link_libraries(myapp PRIVATE METIS::metis)
```

The include directories are handled automatically via the target's interface.

### For Maintainers

The changes maintain full backward compatibility. The traditional build process via `make` or direct CMake invocation works exactly as before.

## Requirements

- CMake 3.14 or later (3.11+ with limited features)
- C compiler
- Git (for FetchContent from repositories)

## See Also

- [examples/README.md](examples/README.md) - Detailed examples and usage guide
- [CMake FetchContent documentation](https://cmake.org/cmake/help/latest/module/FetchContent.html)

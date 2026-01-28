# Using METIS with CMake FetchContent

This directory contains examples of how to use METIS in your CMake projects via FetchContent.

## FetchContent Example

FetchContent is a CMake module (available since CMake 3.11, improved in 3.14+) that allows you to download and build dependencies automatically during the CMake configuration step.

### Basic Usage

See [CMakeLists.txt.fetchcontent](CMakeLists.txt.fetchcontent) for a complete example.

```cmake
include(FetchContent)

FetchContent_Declare(
  METIS
  GIT_REPOSITORY https://github.com/YOUR_USERNAME/METIS.git
  GIT_TAG        main
)

FetchContent_MakeAvailable(METIS)

add_executable(my_app main.c)
target_link_libraries(my_app PRIVATE METIS::metis)
```

### Key Features

- **No Installation Required**: METIS is downloaded and built automatically
- **Modern CMake Targets**: Use `METIS::metis` for proper dependency management
- **Automatic Include Paths**: No need to manually specify include directories
- **Subproject Aware**: Programs are not built by default when METIS is a subproject

### Options

You can configure METIS options before calling `FetchContent_MakeAvailable`:

```cmake
# Build as shared library instead of static
set(SHARED ON CACHE BOOL "" FORCE)

# Don't build the METIS command-line programs
set(METIS_BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(METIS)
```

### Testing the Example

To test the provided example:

```bash
cd examples
mkdir build && cd build

# Create a simple CMakeLists.txt for testing
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.14)
project(METISExample)

include(FetchContent)

FetchContent_Declare(
  METIS
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../..
)

FetchContent_MakeAvailable(METIS)

add_executable(example ../example_fetchcontent.c)
target_link_libraries(example PRIVATE METIS::metis)
EOF

cmake ..
make
./example
```

## Alternative: find_package

If you install METIS system-wide, you can also use it with `find_package`:

```cmake
find_package(METIS REQUIRED)
add_executable(my_app main.c)
target_link_libraries(my_app PRIVATE METIS::metis)
```

## Requirements

- CMake 3.14 or later (for best FetchContent support)
- C compiler
- Git (for fetching from repository)

## Notes

- When used as a subproject, METIS programs (gpmetis, ndmetis, etc.) are not built by default
- The `METIS::metis` target provides all necessary include directories and compiler flags
- METIS will automatically link against the math library (`m`) on Unix systems

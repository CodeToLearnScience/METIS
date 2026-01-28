# METIS Quick Reference for CMake FetchContent

## Minimal Example

```cmake
cmake_minimum_required(VERSION 3.14)
project(MyApp)

include(FetchContent)
FetchContent_Declare(METIS
  GIT_REPOSITORY https://github.com/KarypisLab/METIS.git
  GIT_TAG main
)
FetchContent_MakeAvailable(METIS)

add_executable(myapp main.c)
target_link_libraries(myapp PRIVATE METIS::metis)
```

## Common Options

```cmake
# Build as shared library
set(SHARED ON CACHE BOOL "" FORCE)

# Don't build METIS programs
set(METIS_BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)

# Set these BEFORE FetchContent_MakeAvailable
FetchContent_MakeAvailable(METIS)
```

## After Installation

```cmake
find_package(METIS REQUIRED)
target_link_libraries(myapp PRIVATE METIS::metis)
```

## What You Get

- ✅ Automatic downloads and builds METIS
- ✅ Proper include paths via target
- ✅ Math library linked automatically
- ✅ No manual path configuration
- ✅ Works on Linux, macOS, Windows

## Requirements

- CMake 3.14+
- C compiler
- Git

## Documentation

- [FETCHCONTENT.md](FETCHCONTENT.md) - Complete documentation
- [examples/](examples/) - Working examples
- [CHANGES_SUMMARY.md](CHANGES_SUMMARY.md) - Technical details

## Test It

```bash
./test_fetchcontent.sh
```

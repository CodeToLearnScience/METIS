#!/bin/bash
# Quick test script to verify FetchContent compatibility

set -e

echo "=== Testing METIS FetchContent Support ==="

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create temporary test directory
TEST_DIR=$(mktemp -d)
echo "Test directory: $TEST_DIR"

cd "$TEST_DIR"

# Create a simple test project
cat > CMakeLists.txt << EOF
cmake_minimum_required(VERSION 3.14)
project(METISFetchTest C)

include(FetchContent)

# Use local METIS source
FetchContent_Declare(
  METIS
  SOURCE_DIR ${SCRIPT_DIR}
)

# Don't build programs by default
set(METIS_BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(METIS)

# Create a simple test executable  
add_executable(test_app test_main.c)
target_link_libraries(test_app PRIVATE METIS::metis)
EOF

# Create simple test program
cat > test_main.c << 'EOF'
#include <metis.h>
#include <stdio.h>

int main() {
    printf("METIS header included successfully!\n");
    printf("Testing simple graph partitioning...\n");
    
    idx_t nvtxs = 6;
    idx_t ncon = 1;
    idx_t xadj[] = {0, 2, 5, 8, 11, 13, 15};
    idx_t adjncy[] = {1, 3, 0, 2, 4, 1, 3, 5, 0, 2, 4, 1, 5, 2, 4};
    idx_t nparts = 2;
    idx_t objval;
    idx_t part[6];
    
    int ret = METIS_PartGraphKway(&nvtxs, &ncon, xadj, adjncy, NULL, NULL, 
                                   NULL, &nparts, NULL, NULL, NULL, 
                                   &objval, part);
    
    if (ret == METIS_OK) {
        printf("✓ METIS partitioning successful!\n");
        printf("  Edge-cut: %d\n", (int)objval);
        printf("  Partitions: ");
        for (int i = 0; i < nvtxs; i++) {
            printf("%d ", (int)part[i]);
        }
        printf("\n");
        return 0;
    } else {
        printf("✗ METIS partitioning failed!\n");
        return 1;
    }
}
EOF

echo ""
echo "=== Running CMake Configuration ==="
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release

echo ""
echo "=== Building Test ==="
cmake --build build

echo ""
echo "=== Running Test ==="
./build/test_app

echo ""
echo "=== Test Summary ==="
echo "✓ CMake configuration successful"
echo "✓ Build successful"
echo "✓ Test execution successful"
echo "✓ FetchContent integration working!"

# Cleanup
cd ..
rm -rf "$TEST_DIR"

echo ""
echo "All tests passed! METIS is ready for FetchContent use."

cmake_minimum_required (VERSION 3.2)
project (bootstrap-test LANGUAGES C CXX)

# find and fetch the latest OpenBLAS build, and create targets
# for the Nehalem microarchitecture
include ("../OpenBLASBootstrap.cmake")
OpenBLAS_find_archive (BUILD_URL url)
OpenBLAS_init (BUILD_URL "${url}" COMPONENTS NEHALEM)

# Create a test executable
add_executable (bootstrap-test "main.cpp")

# link to OpenBLAS
target_link_libraries (bootstrap-test OpenBLAS::NEHALEM)
target_include_directories (bootstrap-test
    PUBLIC "$<TARGET_PROPERTY:OpenBLAS::NEHALEM,INTERFACE_INCLUDE_DIRECTORIES>"
)

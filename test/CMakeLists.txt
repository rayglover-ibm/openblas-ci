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

if (WIN32)
    # (windows) copy dlls to the target directory
    add_custom_command (TARGET bootstrap-test POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:OpenBLAS::NEHALEM>" "$<TARGET_FILE_DIR:bootstrap-test>"
    )
endif ()

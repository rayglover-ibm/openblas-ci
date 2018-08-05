# OpenBLAS builds
_A collection of OpenBlas builds. See [releases](https://github.com/rayglover-ibm/openblas-ci/releases)_ for downloads.

| Windows | Mac | Linux |
|---------|-----|-------|
| [![Build status](https://ci.appveyor.com/api/projects/status/3iqhqm7xcol1dvxb/branch/master?svg=true)](https://ci.appveyor.com/project/rayglover-ibm/openblas-ci/branch/master) | [![Build Status](https://travis-ci.org/rayglover-ibm/openblas-ci.svg?branch=master)](https://travis-ci.org/rayglover-ibm/openblas-ci) | [![Build Status](https://travis-ci.org/rayglover-ibm/openblas-ci.svg?branch=master)](https://travis-ci.org/rayglover-ibm/openblas-ci) |

## Structure

Each release is split in to specific target platforms (Win/Mac/Linux/etc.), and within each release there are a number of builds corresponding to different toolchains, build configurations and CPU architecture/microarchitecture.

## CMake support

This repository contains `OpenBLASBootstrap.cmake` which provides functions for the discovery, downloading and setup of OpenBLAS in to your CMake project. For example, the following finds the latest available release for the current OS and imports targets corresponding to the requested microarchitecture, Haswell:

```cmake
include ("OpenBLASBootstrap")
OpenBLAS_find_archive (BUILD_URL url)
OpenBLAS_init (BUILD_URL "${url}" COMPONENTS HASWELL)
```

Once the `OpenBLAS` target is available, you can use it in the typical way. For example, to link OpenBLAS to the target `myapp`:

```cmake
target_link_libraries (myapp OpenBLAS::HASWELL)
target_include_directories (myapp
    PUBLIC "$<TARGET_PROPERTY:OpenBLAS::HASWELL,INTERFACE_INCLUDE_DIRECTORIES>"
)
```

To make sure you always use an up to date bootstrap, you could use CMake to download it at configuration time. A full working example of this is available [here](https://github.com/rayglover-ibm/sparse-solvers/blob/211bec856659b0ab68352e0eb27c71f8f8aff364/cmake/BlasUtils.cmake). Alternatively, you could include this repository as a git submodule in the repository containing yout project.

## Bazel support

_TODO (contributions welcome)_

# OpenBLAS builds
_A collection of OpenBlas builds. See [releases](https://github.com/rayglover-ibm/openblas-ci/releases)_ for downloads.

| Windows | Mac | Linux |
|---------|-----|-------|
| [![Build status](https://ci.appveyor.com/api/projects/status/3iqhqm7xcol1dvxb/branch/master?svg=true)](https://ci.appveyor.com/project/rayglover-ibm/openblas-ci/branch/master) | [![Build Status](https://travis-ci.org/rayglover-ibm/openblas-ci.svg?branch=master)](https://travis-ci.org/rayglover-ibm/openblas-ci) | [![Build Status](https://travis-ci.org/rayglover-ibm/openblas-ci.svg?branch=master)](https://travis-ci.org/rayglover-ibm/openblas-ci) |

## Structure

Each release is split in to specific target platforms (Win/Mac/Linux/etc.), and within each release there are a number of builds corresponding to different toolchains, build configurations and CPU architectures.

## CMake support

You can integrate these OpenBLAS builds in to your CMake project. Perhaps the most convenient approach is with [DownloadProject](https://github.com/Crascit/DownloadProject), e.g.:

```cmake
set (downloads_root "https://github.com/rayglover-ibm/openblas-ci/releases/download")
set (version "v0.2.19")
set (platform ${CMAKE_HOST_SYSTEM_NAME})

download_project (
    PROJ  OpenBLAS
    URL   ${downloads_root}/${version}/${platform}.zip
    UPDATE_DISCONNECTED 1
)
find_package (OpenBLAS REQUIRED
    PATHS "${OpenBLAS_SOURCE_DIR}"
)
```

Once the `OpenBLAS` target is available, you can use it in the typical way. For example, to link OpenBLAS to the target `myapp`:

```cmake
target_link_libraries (myapp OpenBLAS)
target_include_directories (myapp PUBLIC
    $<TARGET_PROPERTY:OpenBLAS,INTERFACE_INCLUDE_DIRECTORIES>
)
```

## Bazel support

_TODO (contributions welcome)_

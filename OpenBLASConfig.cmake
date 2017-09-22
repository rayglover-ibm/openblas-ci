cmake_minimum_required (VERSION 2.8)

# options ---------------------------------------------------------------------
set ("OpenBLAS_microarch" "NEHALEM" CACHE STRING "CPU microarchitecture to use")
# -----------------------------------------------------------------------------

set_property (GLOBAL PROPERTY OpenBLAS_ld "${CMAKE_CURRENT_LIST_DIR}")

function (OpenBLAS_import)
    set (oneValueArgs TARGET MICRO_ARCH)
    cmake_parse_arguments (args "" "${oneValueArgs}" "" ${ARGN})

    if ("${args_MICRO_ARCH}" STREQUAL "")
        set (args_MICRO_ARCH "${OpenBLAS_microarch}")
    endif ()

    if (CMAKE_SIZEOF_VOID_P MATCHES "8")
        set (arch "x86-64")
    else ()
        set (arch "x86")
    endif ()

    set (pkgname "OpenBLAS")
    add_library (${args_TARGET} SHARED IMPORTED GLOBAL)

    if (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
        set (platform  "windows")
        set (toolchain "mingw")
        set (libext    "dll")
        set (libdir    "bin")

    elseif (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux")
        set (platform  "linux")
        set (toolchain "gcc")
        set (libext    "so")
        set (libdir    "lib")

    elseif (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
        set (platform  "darwin")
        set (toolchain "gcc")
        set (libext    "dylib")
        set (libdir    "lib")

    else ()
        message (SEND_ERROR "These builds of ${pkgname} dont support ${CMAKE_HOST_SYSTEM_NAME}")
    endif ()

    get_property (ld GLOBAL PROPERTY OpenBLAS_ld)
    get_filename_component (blasbase
        "${ld}/${platform}/${toolchain}/${args_MICRO_ARCH}/${arch}" ABSOLUTE
    )
    set_target_properties (${args_TARGET} PROPERTIES
        IMPORTED_IMPLIB               "${blasbase}/lib/libopenblas.${libext}.a"
        IMPORTED_LOCATION             "${blasbase}/${libdir}/libopenblas.${libext}"
        INTERFACE_INCLUDE_DIRECTORIES "${blasbase}/include"
    )
    message (STATUS
        "Importing ${pkgname} from: ${blasbase}"
    )
endfunction ()

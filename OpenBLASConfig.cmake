cmake_minimum_required (VERSION 3.2)

# options ---------------------------------------------------------------------
set ("OpenBLAS_microarch" "NEHALEM" CACHE STRING "CPU microarchitecture to use")
# -----------------------------------------------------------------------------

set_property (GLOBAL PROPERTY OpenBLAS_ld "${CMAKE_CURRENT_LIST_DIR}")

define_property (TARGET PROPERTY MICROARCH
    BRIEF_DOCS "The microarchitecture this target is optimized for"
    FULL_DOCS  "The microarchitecture this target is optimized for"
)

define_property (TARGET PROPERTY UNIQUE_NAME
    BRIEF_DOCS "The name which uniquely identifies this target"
    FULL_DOCS  "The name which uniquely identifies this target. Can be used as a file name."
)

function (OpenBLAS_import MICROARCH)
    set (tgt "OpenBLAS::${microarch}")

    if (CMAKE_SIZEOF_VOID_P MATCHES "8")
        set (arch "x86-64")
    else ()
        set (arch "x86")
    endif ()

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
        "${ld}/${platform}/${toolchain}/${microarch}/${arch}" ABSOLUTE
    )

    if (NOT TARGET ${tgt})
        message (STATUS "[OpenBLAS] Importing '${tgt}' from: ${blasbase}")
        add_library ("${tgt}" SHARED IMPORTED)

        set_target_properties (${tgt} PROPERTIES
            MICROARCH                     "${microarch}"
            UNIQUE_NAME                   "libopenblas.${platform}-${arch}-${microarch}.${libext}"
            IMPORTED_LOCATION             "${blasbase}/${libdir}/libopenblas.${libext}"
            IMPORTED_IMPLIB               "${blasbase}/lib/libopenblas.${libext}.a"
            INTERFACE_INCLUDE_DIRECTORIES "${blasbase}/include"
        )
    endif ()
endfunction ()

if (OpenBLAS_FIND_COMPONENTS)
    # create targets. Each component corresponds to a specific micro-architecture
    foreach (microarch ${OpenBLAS_FIND_COMPONENTS})
        OpenBLAS_import ("${microarch}")
    endforeach ()
else ()
    # use the option OpenBLAS_microarch
    OpenBLAS_import ("${OpenBLAS_microarch}")
endif ()

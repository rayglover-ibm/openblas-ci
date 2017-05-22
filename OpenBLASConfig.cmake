cmake_minimum_required (VERSION 2.8)

set (pkgname "OpenBLAS")
add_library (${pkgname} SHARED IMPORTED GLOBAL)

set (microarch "NEHALEM")

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

get_filename_component (blasbase
    "${CMAKE_CURRENT_LIST_DIR}/${platform}/${toolchain}/${microarch}/${arch}" ABSOLUTE
)
set_target_properties (${pkgname} PROPERTIES
    IMPORTED_IMPLIB               "${blasbase}/lib/libopenblas.${libext}.a"
    IMPORTED_LOCATION             "${blasbase}/${libdir}/libopenblas.${libext}"
    INTERFACE_INCLUDE_DIRECTORIES "${blasbase}/include"
)

message (STATUS
    "Using ${pkgname} from: ${blasbase}"
)
#
# Utils for retrieving and OpenBLAS builds
#
cmake_minimum_required (VERSION 3.2)
include (CMakeParseArguments)

set (github_releases "https://github.com/rayglover-ibm/openblas-ci/releases/download")
set (github_api      "https://api.github.com/repos/rayglover-ibm/openblas-ci")

#
# Download the contents of the given address to the given
# destination, or fail.
#
macro (download_or_fail addr dest_path)
    file (DOWNLOAD ${addr} ${dest_path} STATUS dlstat LOG dllog)
    list (GET dlstat 0 dlstat_num)
    if (NOT dlstat_num EQUAL 0)
        list (GET dlstat 1 dlstat_err)
        message (FATAL_ERROR "Unsuccessful downloading: ${dlstat_num} ${dlstat_err}. Log:\n${dllog}")
    endif ()
endmacro ()

#
# Get the name of the latest OpenBLAS release available on Github
#
function (OpenBLAS_get_latest_release RELEASE_NAME)
    set (endpoint "${github_api}/releases/latest")
    set (result   "${CMAKE_CURRENT_BINARY_DIR}/OpenBLAS_latestrelease.json")

    message (STATUS "Downloading release metadata from GitHub for OpenBLAS: ${endpoint}")
    download_or_fail (${endpoint} ${result})

    # Find name of the latest release in json
    file (STRINGS ${result} release_info)
    string (REGEX MATCH "\"name\": \"([^\"]*)\"" match "${release_info}")
    set (${RELEASE_NAME} "${CMAKE_MATCH_1}" PARENT_SCOPE)
endfunction ()

#
# Finds exact URL to download OpenBLAS build basing on
# provided parameters. By default will return the latest
# build available for ${CMAKE_SYSTEM_NAME}
#
# Arguments:
#   BUILD_URL    <var_to_save_url>
#   RELEASE_NAME <release_name>         (optional)
#   OS           <windows/linux/darwin> (optional)
#
function (OpenBLAS_find_archive)
    set (oneValueArgs BUILD_URL RELEASE_NAME OS)
    cmake_parse_arguments (args "" "${oneValueArgs}" "" ${ARGN})

    if (NOT args_RELEASE_NAME)
        OpenBLAS_get_latest_release (relname)
    else ()
        set (relname ${args_RELEASE_NAME})
    endif ()

    if (NOT args_OS)
        set (args_OS ${CMAKE_SYSTEM_NAME})
    endif ()

    message (STATUS "Selected OpenBLAS release ${relname}")
    set (${args_BUILD_URL} "${github_releases}/${relname}/${args_OS}.tar.gz" PARENT_SCOPE)
endfunction ()

#
# Downloads prebuilt OpenBLAS binaries from the given url,
# and imports the OpenBLAS targets.
#
# Arguments:
#   BUILD_URL   <var_to_save_url>
#   COMPONENTS  <list of micro-architectures to import> (optional) 
#
function (OpenBLAS_init)
    set (oneValueArgs BUILD_URL)
    set (multiValueArgs COMPONENTS)
    cmake_parse_arguments (args "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # retrieve DownloadProject
    set (src "https://raw.githubusercontent.com/Crascit/DownloadProject/master")
    set (dest "${CMAKE_CURRENT_BINARY_DIR}/tmp.DownloadProject")

    foreach (file
        "DownloadProject.cmake"
        "DownloadProject.CMakeLists.cmake.in")
        download_or_fail ("${src}/${file}" "${dest}/${file}")
    endforeach ()

    # use DownloadProject to initialize OpenBLAS
    include ("${dest}/DownloadProject.cmake")
    download_project (PROJ "OpenBLAS-dl"
        URL "${args_BUILD_URL}"  UPDATE_DISCONNECTED 1
    )
    find_package (OpenBLAS CONFIG REQUIRED
        COMPONENTS ${args_COMPONENTS}
        PATHS "${OpenBLAS-dl_SOURCE_DIR}"
    )
endfunction ()

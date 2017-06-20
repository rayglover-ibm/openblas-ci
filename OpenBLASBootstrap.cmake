#
# Utils for retrieving and OpenBLAS builds
#
cmake_minimum_required (VERSION 3.3)
include (CMakeParseArguments)

set (github_releases "https://github.com/rayglover-ibm/openblas-ci/releases/download")
set (github_api      "https://api.github.com/repos/rayglover-ibm/openblas-ci")

#
# Gets the name of the latest OpenBLAS release available on Github
#
function (OpenBLAS_get_latest_release RELEASE_NAME)
    set (rel_info_api_url "${github_api}/releases/latest")
    set (release_info_file "${CMAKE_CURRENT_BINARY_DIR}/OpenBLAS_info.json")

    if (EXISTS "${release_info_file}")
        file (REMOVE "${release_info_file}")
    endif ()
    
    message (STATUS "Downloading release metadata from GitHub for OpenBLAS: ${rel_info_api_url}")
    file (DOWNLOAD ${rel_info_api_url} ${release_info_file} STATUS stat)
    
    list (GET stat 0 stat_num)
    if (NOT stat_num EQUAL 0)
        message (ERROR "Unsuccessful downloading: ${stat}")
    endif ()

    # Find name of the latest release in json
    file (STRINGS ${release_info_file} release_info)
    string (REGEX MATCH "\"name\": \"([^\"]*)\"" match "${release_info}")
    set (${RELEASE_NAME} "${CMAKE_MATCH_1}" PARENT_SCOPE)
endfunction ()

#
# Finds exact URL to download OpenBLAS build basing on 
# provided parameters.
#
# Arguments:
#   BUILD_URL    <var_to_save_url>
#   RELEASE_NAME <release_name|LATEST>
#
function (OpenBLAS_find_archive)
    set (oneValueArgs BUILD_URL RELEASE_NAME OS)
    cmake_parse_arguments (args "" "${oneValueArgs}" "" ${ARGN})

    if (args_RELEASE_NAME STREQUAL LATEST)
        OpenBLAS_get_latest_release (relname)
    else ()
        set (relname ${args_RELEASE_NAME})
    endif ()

    message (STATUS "Selected OpenBLAS release ${relname}")
    set (${args_BUILD_URL} "${github_releases}/${relname}/${args_OS}.tar.gz" PARENT_SCOPE)
endfunction ()

#
# Downloads prebuilt OpenBLAS binaries from the given url,
# and imports the OpenBLAS targets.
#
# Arguments:
#   BUILD_URL <var_to_save_url>
#   PROJ      <name of the project to create>
#
function (OpenBLAS_init)
    set (oneValueArgs BUILD_URL PROJ)
    cmake_parse_arguments (args "" "${oneValueArgs}" "" ${ARGN})

    # retrieve DownloadProject
    set (src "https://raw.githubusercontent.com/Crascit/DownloadProject/master")
    set (dest "${CMAKE_CURRENT_BINARY_DIR}/tmp.DownloadProject")

    foreach (file
        "DownloadProject.cmake"
        "DownloadProject.CMakeLists.cmake.in")
        file (DOWNLOAD "${src}/${file}" "${dest}/${file}" STATUS "retrieving ${file}")
    endforeach ()

    # use DownloadProject to initialize OpenBLAS
    include ("${dest}/DownloadProject.cmake")
    download_project (PROJ "${args_PROJ}"
        URL "${args_BUILD_URL}"  UPDATE_DISCONNECTED 1
    )
    find_package (OpenBLAS CONFIG REQUIRED
        PATHS "${OpenBLAS_SOURCE_DIR}"
    )
endfunction ()

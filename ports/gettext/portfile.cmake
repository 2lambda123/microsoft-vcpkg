if(VCPKG_TARGET_IS_LINUX AND NOT "tools" IN_LIST FEATURES)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    if (NOT EXISTS "/usr/include/libintl.h")
        message(FATAL_ERROR "When targeting Linux, `libintl.h` is expected to come from the C Runtime Library (glibc). "
                            "Please use \"sudo apt-get install libc-dev\" or the equivalent to install development files."
        )
    endif()
    return()
endif()

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)

#Based on https://github.com/winlibs/gettext

set(GETTEXT_VERSION 0.21)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz"
    FILENAME "gettext-${GETTEXT_VERSION}.tar.gz"
    SHA512 bbe590c5dd3580c75bf30ff768da99a88eb8d466ec1ac9eea20be4cab4357ecf72448e6b81b47425e39d50fa6320ba426632914d7898dfebb4f159abc39c31d1
)
if(VCPKG_TARGET_IS_UWP)
    set(PATCHES uwp_remove_localcharset.patch)
endif()
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${GETTEXT_VERSION}
    PATCHES
        0002-Fix-uwp-build.patch
        0003-Fix-win-unicode-paths.patch
        rel_path.patch
        android.patch
        ${PATCHES}
)
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_PATH "${BISON}" DIRECTORY)
vcpkg_add_to_path("${BISON_PATH}")

set(OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    # This is required. For some reason these do not get correctly identified for release builds. 
    list(APPEND OPTIONS
        ac_cv_func_wcslen=yes
        ac_cv_func_memmove=yes
        #The following are required for a full gettext built (libintl and tools).
        gl_cv_func_printf_directive_n=no #segfaults otherwise with popup window
        ac_cv_func_memset=yes #not detected in release builds 
        ac_cv_header_pthread_h=no
        ac_cv_header_dirent_h=no
    )
endif()

function(build_libintl_and_tools)
    cmake_parse_arguments(arg "" "BUILD_TYPE" "" ${ARGN})
    if(DEFINED arg_BUILD_TYPE)
        set(VCPKG_BUILD_TYPE "${arg_BUILD_TYPE}")
    endif()
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}"
        DETERMINE_BUILD_TRIPLET
        USE_WRAPPERS
        ADD_BIN_TO_PATH    # So configure can check for working iconv
        ADDITIONAL_MSYS_PACKAGES gzip
        OPTIONS
            --enable-relocatable #symbol duplication with glib-init.c?
            --enable-c++
            --disable-java
            ${OPTIONS}
    )
    vcpkg_install_make()
endfunction()

function(build_libintl_only)
    cmake_parse_arguments(arg "" "BUILD_TYPE" "" ${ARGN})
    if(DEFINED arg_BUILD_TYPE)
        set(VCPKG_BUILD_TYPE "${arg_BUILD_TYPE}")
    endif()
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}/gettext-runtime"
    DETERMINE_BUILD_TRIPLET
    USE_WRAPPERS
    ADD_BIN_TO_PATH    # So configure can check for working iconv
    OPTIONS
        --enable-relocatable #symbol duplication with glib-init.c?
        --enable-c++
        --disable-java
        ${OPTIONS}
    )
    vcpkg_install_make(SUBPATH "/intl")
endfunction()

if("tools" IN_LIST FEATURES)
    # Always build tools in release configuration only
    build_libintl_and_tools(BUILD_TYPE "release")
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    if(VCPKG_TARGET_IS_LINUX)
        set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
    elseif(NOT DEFINED VCPKG_BUILD_TPYE OR VCPKG_BUILD_TPYE STREQUAL "debug")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}.release")
        file(RENAME "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}.release")
        build_libintl_only(BUILD_TYPE "debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}.release/debug")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}")
        file(RENAME "${CURRENT_PACKAGES_DIR}.release" "${CURRENT_PACKAGES_DIR}")
    endif()
else()
    build_libintl_only()
endif()

# Handle copyright
file(COPY "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gettext")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/gettext/COPYING" "${CURRENT_PACKAGES_DIR}/share/gettext/copyright")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(GNU_DLL_PATHS lib/ debug/lib/)
set(GNU_DLL_NAME GNU.Gettext.dll) #C# dll?
foreach(DLL_PATH IN LISTS GNU_DLL_PATHS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/${DLL_PATH}${GNU_DLL_NAME}")
       file(REMOVE "${CURRENT_PACKAGES_DIR}/${DLL_PATH}${GNU_DLL_NAME}")
    endif()
endforeach()

vcpkg_copy_pdbs()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/intl")
if("tools" IN_LIST FEATURES AND NOT VCPKG_CROSSCOMPILING)
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gettext")
endif()

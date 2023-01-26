#TODO: Features to add:
# USE_XBLAS??? extended precision blas. needs xblas
# LAPACKE should be its own PORT
# USE_OPTIMIZED_LAPACK (Probably not what we want. Does a find_package(LAPACK): probably for LAPACKE only builds _> own port?)
# LAPACKE Builds LAPACKE
# LAPACKE_WITH_TMG Build LAPACKE with tmglib routines
if(EXISTS "${CURRENT_INSTALLED_DIR}/share/clapack/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if clapack is installed. Please remove clapack:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

x_vcpkg_find_fortran(OUT_OPTIONS Fortran_opts 
                     OUT_OPTIONS_RELEASE Fortran_opts_rel 
                     OUT_OPTIONS_DEBUG Fortran_opts_dbg)

if(Z_VCPKG_IS_INTERNAL_Fortran_INTEL OR VCPKG_DETECTED_CMAKE_Fortran_COMPILER MATCHES "ifort${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    set(PATCHES intel.patch)
endif()


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  "Reference-LAPACK/lapack"
    REF "v${VERSION}"
    SHA512 fc3258b9d91a833149a68a89c5589b5113e90a8f9f41c3a73fbfccb1ecddd92d9462802c0f870f1c3dab392623452de4ef512727f5874ffdcba6a4845f78fc9a
    HEAD_REF master
    PATCHES ${PATCHES}
            cmake-config.patch
            lapacke.patch
            time_test.patch
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(ENV{FFLAGS} "$ENV{FFLAGS} -fPIC") # Should probably be in the toolchain
endif()

set(CBLAS OFF)
if("cblas" IN_LIST FEATURES)
    set(CBLAS ON)
    if("noblas" IN_LIST FEATURES)
        message(FATAL_ERROR "Cannot built feature 'cblas' together with feature 'noblas'. cblas requires blas!")
    endif()
endif()

set(USE_OPTIMIZED_BLAS OFF) 
if("noblas" IN_LIST FEATURES)
    set(USE_OPTIMIZED_BLAS ON)
endif()

# Python3 for testing summary. 
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DUSE_OPTIMIZED_BLAS=${USE_OPTIMIZED_BLAS}"
        "-DCMAKE_REQUIRE_FIND_PACKAGE_BLAS=${USE_OPTIMIZED_BLAS}"
        "-DCBLAS=${CBLAS}"
        "-DCMAKE_POLICY_DEFAULT_CMP0065=NEW"
        "-DCMAKE_POLICY_DEFAULT_CMP0067=NEW"
        "-DCMAKE_POLICY_DEFAULT_CMP0083=NEW"
        ${Fortran_opts}
        "-DBUILD_TESTING:BOOL=ON"
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
    OPTIONS_DEBUG ${Fortran_opts_rel}
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_BLAS
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME lapack-${VERSION} CONFIG_PATH lib/cmake/lapack-${VERSION}) #Should the target path be lapack and not lapack-reference?

set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
endif()
set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
endif()

if(NOT USE_OPTIMIZED_BLAS)
    set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
    endif()
    set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
    endif()
endif()
if("cblas" IN_LIST FEATURES)
    set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/cblas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
    endif()
    set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cblas.pc")
    if(EXISTS "${pcfile}")
        file(READ "${pcfile}" _contents)
        file(WRITE "${pcfile}" "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(RENAME "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack-reference.pc")
if(NOT VCPKG_BUILD_TYPE)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack-reference.pc")
endif()

if(NOT "noblas" IN_LIST FEATURES)
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/blas-reference.pc")
    if(NOT VCPKG_BUILD_TYPE)
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/blas-reference.pc")
    endif()
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# remove debug includes
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_TARGET_IS_WINDOWS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/liblapack.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/liblapack.lib" "${CURRENT_PACKAGES_DIR}/lib/lapack.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/liblapack.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/liblapack.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/lapack.lib")
    endif()
    if(NOT USE_OPTIMIZED_BLAS)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/libblas.lib")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/libblas.lib" "${CURRENT_PACKAGES_DIR}/lib/blas.lib")
        endif()
        if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/libblas.lib")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/libblas.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/blas.lib")
        endif()
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BLA_STATIC ON)
else()
    set(BLA_STATIC OFF)
endif()
set(BLA_VENDOR Generic)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/FindLAPACK.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)


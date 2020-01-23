include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.fftw.org/fftw-3.3.8.tar.gz"
    FILENAME "fftw-3.3.8.tar.gz"
    SHA512 ab918b742a7c7dcb56390a0a0014f517a6dff9a2e4b4591060deeb2c652bf3c6868aa74559a422a276b853289b4b701bdcbd3d4d8c08943acf29167a7be81a38
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        omp_test.patch
        patch_targets.patch
        fftw3_arch_fix.patch
        aligned_malloc.patch
)

if ("openmp" IN_LIST FEATURES)
    set(ENABLE_OPENMP ON)
else()
    set(ENABLE_OPENMP OFF)
endif()

if ("avx" IN_LIST FEATURES)
    set(ENABLE_AVX ON)
    set(ENABLE_SSE ON)
    set(ENABLE_SSE2 ON)
else()
    set(ENABLE_AVX OFF)
endif()

if ("avx2" IN_LIST FEATURES)
    set(ENABLE_AVX2 ON)
    set(ENABLE_FMA ON)
    set(ENABLE_SSE ON)
    set(ENABLE_SSE2 ON)
else()
    set(ENABLE_AVX2 OFF)
    set(ENABLE_FMA OFF)
endif()

if ("sse" IN_LIST FEATURES)
    set(ENABLE_SSE ON)
else()
    set(ENABLE_SSE OFF)
endif()

if ("sse2" IN_LIST FEATURES)
    set(ENABLE_SSE2 ON)
    set(ENABLE_SSE ON)
else()
    set(ENABLE_SSE2 OFF)
endif()

if ("threads" IN_LIST FEATURES)
    set(ENABLE_THREADS ON)
else()
    set(ENABLE_THREADS OFF)
endif()

set(ENABLE_FLOAT_CMAKE fftw3f)
set(ENABLE_LONG_DOUBLE_CMAKE fftw3l)
set(ENABLE_DEFAULT_PRECISION_CMAKE fftw3)

foreach(PRECISION ENABLE_FLOAT ENABLE_LONG_DOUBLE ENABLE_DEFAULT_PRECISION)
    if(PRECISION STREQUAL "ENABLE_LONG_DOUBLE")
        vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS 
            -D${PRECISION}=ON
            -DENABLE_OPENMP=${ENABLE_OPENMP}
            -DENABLE_THREADS=${HAVE_THREADS}
            -DWITH_COMBINED_THREADS=${HAVE_THREADS}
            -DBUILD_TESTS=OFF
        )
    else()
        vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS 
            -D${PRECISION}=ON
            -DENABLE_OPENMP=${ENABLE_OPENMP}
            -DENABLE_SSE=${ENABLE_SSE}
            -DENABLE_SSE2=${ENABLE_SSE2}
            -DENABLE_AVX=${ENABLE_AVX}
            -DENABLE_AVX2=${ENABLE_AVX2}
            -DENABLE_FMA=${ENABLE_FMA}
            -DENABLE_THREADS=${ENABLE_THREADS}
            -DWITH_COMBINED_THREADS=${ENABLE_THREADS}
            -DBUILD_TESTS=OFF
        )
    endif()

    vcpkg_install_cmake()

    vcpkg_copy_pdbs()

    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/${${PRECISION}_CMAKE})
endforeach()

file(READ ${SOURCE_PATH}/api/fftw3.h _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(FFTW_DLL)" "0" _contents "${_contents}")
else()
    string(REPLACE "defined(FFTW_DLL)" "1" _contents "${_contents}")
endif()
file(WRITE ${SOURCE_PATH}/include/fftw3.h "${_contents}")

# Cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fftw3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fftw3/COPYING ${CURRENT_PACKAGES_DIR}/share/fftw3/copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF f4138265b390f1921b9891d6669674d3157887d8 # 1.82.0
    SHA512 cd8c55454fc2cb4d23c2b3f01870e154766fa5a35c07b79d25c2d85dc2675dcb224d9be8a1cdcb7e9a0bd3c17e90141aa4084f67a311a1c327d7ac2439ba196a
    HEAD_REF master
    PATCHES
        fix-CMakeDependency.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSW_BUILD=OFF
        -DCPPAN_BUILD=OFF
        -DSTATIC=${STATIC}
        -DCMAKE_REQUIRED_INCLUDES=${CURRENT_INSTALLED_DIR}/include # for check_include_file()
    MAYBE_UNUSED_VARIABLES
        STATIC
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/leptonica)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/leptonica-license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

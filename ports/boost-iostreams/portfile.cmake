# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/iostreams
    REF boost-${VERSION}
    SHA512 2cd4aaf6c02f7ede5a2066072ec968a08035a44d45cb603665b898d2ad88f015e9c12022f56474a3277e9440d3dfce302587f8ac87d7fb72f574eed570089aab
    HEAD_REF master
    PATCHES
        Removeseekpos.patch
        fix-zstd.diff
)

set(FEATURE_OPTIONS "")
include("${CMAKE_CURRENT_LIST_DIR}/features.cmake")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
